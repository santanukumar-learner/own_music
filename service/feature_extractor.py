"""Audio feature extraction with librosa — all in-memory, no temp files.

Decodes an audio buffer once into a mono waveform, then derives BPM, musical
key, valence/energy (Russell circumplex axes), and a log-mel spectrogram for the
genre model. The same waveform is reused to compute the Chromaprint fingerprint
(see ``acoustid_service``), so the file is decoded exactly once.
"""
from __future__ import annotations

import io
import logging
from dataclasses import dataclass

import librosa
import numpy as np

logger = logging.getLogger(__name__)

# Krumhansl–Schmuckler key profiles (major/minor), used for key estimation.
_MAJOR_PROFILE = np.array(
    [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88]
)
_MINOR_PROFILE = np.array(
    [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17]
)
KEYS = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


@dataclass
class AudioFeatures:
    bpm: float
    musical_key: str
    is_major: bool
    valence: float
    energy: float
    duration_ms: int
    spectral_centroid: float
    rms: float


def load_waveform(source, sr: int, max_seconds: int):
    """Decode a path OR in-memory bytes/file-like to a mono float32 waveform.

    In-memory buffers are read directly (via soundfile) — nothing is written to
    disk. Raises ValueError on empty/undecodable audio.
    """
    if isinstance(source, (bytes, bytearray)):
        source = io.BytesIO(bytes(source))
    y, sr = librosa.load(source, sr=sr, mono=True, duration=max_seconds)
    if y is None or y.size == 0:
        raise ValueError("decoded empty audio")
    return y.astype(np.float32), int(sr)


def extract_features(y: np.ndarray, sr: int) -> AudioFeatures:
    duration_ms = int(len(y) / sr * 1000)

    tempo, _ = librosa.beat.beat_track(y=y, sr=sr)
    bpm = float(np.atleast_1d(tempo)[0])

    chroma = librosa.feature.chroma_cqt(y=y, sr=sr)
    chroma_mean = chroma.mean(axis=1)
    key_idx, is_major = _estimate_key(chroma_mean)

    rms = float(np.mean(librosa.feature.rms(y=y)))
    centroid = float(np.mean(librosa.feature.spectral_centroid(y=y, sr=sr)))

    energy = _energy(rms, centroid, bpm)
    valence = _valence(is_major, bpm, centroid, chroma_mean)

    return AudioFeatures(
        bpm=round(bpm, 2),
        musical_key=KEYS[key_idx],
        is_major=is_major,
        valence=round(valence, 4),
        energy=round(energy, 4),
        duration_ms=duration_ms,
        spectral_centroid=round(centroid, 2),
        rms=round(rms, 6),
    )


def compute_logmel(
    y: np.ndarray,
    sr: int,
    n_mels: int = 128,
    n_fft: int = 2048,
    hop_length: int = 512,
    max_frames: int = 1024,
) -> np.ndarray:
    """Normalized log-mel spectrogram shaped ``[1, n_mels, frames]`` (float32).

    NOTE: the exact preprocessing a given ONNX model expects (n_mels, hop,
    normalization, framing) varies. Adjust these defaults to match your model.
    """
    mel = librosa.feature.melspectrogram(
        y=y, sr=sr, n_mels=n_mels, n_fft=n_fft, hop_length=hop_length
    )
    logmel = librosa.power_to_db(mel, ref=np.max)
    logmel = (logmel - logmel.mean()) / (logmel.std() + 1e-9)
    if logmel.shape[1] > max_frames:
        logmel = logmel[:, :max_frames]
    return logmel[np.newaxis, :, :].astype(np.float32)


def to_pcm16(y: np.ndarray) -> bytes:
    """Convert a float32 [-1, 1] mono waveform to signed 16-bit little-endian PCM
    for Chromaprint fingerprinting."""
    clipped = np.clip(y, -1.0, 1.0)
    return (clipped * 32767.0).astype("<i2").tobytes()


def _estimate_key(chroma_mean: np.ndarray) -> tuple[int, bool]:
    best_corr, best_idx, best_major = -np.inf, 0, True
    for i in range(12):
        maj = np.nan_to_num(np.corrcoef(np.roll(_MAJOR_PROFILE, i), chroma_mean)[0, 1])
        minr = np.nan_to_num(np.corrcoef(np.roll(_MINOR_PROFILE, i), chroma_mean)[0, 1])
        if maj > best_corr:
            best_corr, best_idx, best_major = maj, i, True
        if minr > best_corr:
            best_corr, best_idx, best_major = minr, i, False
    return best_idx, best_major


def _energy(rms: float, centroid: float, bpm: float) -> float:
    """Map loudness + brightness + tempo to a 0..1 energy axis."""
    loud = np.clip(rms / 0.2, 0, 1)
    bright = np.clip(centroid / 5000.0, 0, 1)
    pace = np.clip((bpm - 60) / 120.0, 0, 1)
    return float(np.clip(0.5 * loud + 0.3 * bright + 0.2 * pace, 0, 1))


def _valence(is_major: bool, bpm: float, centroid: float, chroma_mean: np.ndarray) -> float:
    """Heuristic 0..1 valence (librosa exposes no ground-truth valence): major
    mode, faster tempo, brighter timbre and stronger tonality read as happier."""
    mode = 0.6 if is_major else 0.3
    pace = np.clip((bpm - 70) / 100.0, 0, 1)
    bright = np.clip(centroid / 5000.0, 0, 1)
    tonal = float(np.clip(chroma_mean.max() / (chroma_mean.mean() + 1e-9) / 3.0, 0, 1))
    return float(np.clip(0.45 * mode + 0.25 * pace + 0.2 * bright + 0.1 * tonal, 0, 1))
