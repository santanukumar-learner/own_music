"""Genre classification (ONNX) + mood derivation (Russell circumplex).

The classifier returns the top-3 genres, their confidences, and a 128-d genre
embedding (the device assembles the final 134-d feature vector). Mood is derived
from valence/energy, not the model. If the ONNX model can't load or inference
fails, it degrades to a rule-based genre from the ID3 genre tag (per spec).
"""
from __future__ import annotations

import logging
from pathlib import Path

import numpy as np

logger = logging.getLogger(__name__)

EMBED_DIM = 128

# Russell circumplex quadrant labels used by Song.mood.
MOODS = ["euphoric", "happy", "calm", "melancholic", "angry", "dark"]


class GenreMoodClassifier:
    def __init__(self, model_path: Path, labels_path: Path) -> None:
        self.model_path = Path(model_path)
        self.labels_path = Path(labels_path)
        self._session = None
        self._labels: list[str] = []
        self._load()

    def _load(self) -> None:
        try:
            import onnxruntime as ort

            if not self.model_path.exists():
                logger.warning(
                    "ONNX model not found at %s; using rule-based genre fallback.",
                    self.model_path,
                )
                return
            self._session = ort.InferenceSession(
                str(self.model_path), providers=["CPUExecutionProvider"]
            )
            if self.labels_path.exists():
                self._labels = [
                    ln.strip()
                    for ln in self.labels_path.read_text(encoding="utf-8").splitlines()
                    if ln.strip()
                ]
            logger.info("Loaded genre ONNX model with %d labels.", len(self._labels))
        except Exception as exc:  # noqa: BLE001 - log and degrade, never crash
            logger.exception("Failed to load ONNX model: %s", exc)
            self._session = None

    @property
    def available(self) -> bool:
        return self._session is not None

    def classify(self, mel: np.ndarray | None, id3_genre: str | None) -> dict:
        if self._session is not None and mel is not None:
            try:
                return self._run_model(mel)
            except Exception as exc:  # noqa: BLE001
                logger.exception("ONNX inference failed; falling back: %s", exc)
        return self._rule_based(id3_genre)

    def _run_model(self, mel: np.ndarray) -> dict:
        inp = self._session.get_inputs()[0]
        x = _fit_to_shape(mel.astype(np.float32), inp.shape)
        outputs = self._session.run(None, {inp.name: x})

        logits = np.asarray(outputs[0]).reshape(-1)
        probs = _softmax(logits)
        top = probs.argsort()[::-1][:3]
        genres = [self._label(int(i)) for i in top]
        confidences = [round(float(probs[i]), 4) for i in top]

        # Prefer a real embedding output if the model exposes one; else derive
        # a stable 128-d vector from the probability distribution.
        embedding = None
        for out in outputs[1:]:
            arr = np.asarray(out).reshape(-1)
            if arr.size >= EMBED_DIM:
                embedding = arr[:EMBED_DIM]
                break
        if embedding is None:
            embedding = _resize_vector(probs, EMBED_DIM)

        return {
            "genres": genres,
            "genre_confidences": confidences,
            "genre_embedding": [float(v) for v in embedding],
            "source": "onnx",
        }

    def _rule_based(self, id3_genre: str | None) -> dict:
        genre = (id3_genre or "").strip() or "Unknown"
        # Deterministic pseudo-embedding so the same tag maps to the same vector.
        seed = float(abs(hash(genre)) % 1000) / 1000.0
        embedding = _resize_vector(np.full(EMBED_DIM, seed, dtype=np.float32), EMBED_DIM)
        return {
            "genres": [genre, "Unknown", "Unknown"],
            "genre_confidences": [1.0, 0.0, 0.0],
            "genre_embedding": [float(v) for v in embedding],
            "source": "id3_fallback",
        }

    def _label(self, i: int) -> str:
        if 0 <= i < len(self._labels):
            return self._labels[i]
        return f"genre_{i}"


def derive_mood(valence: float, energy: float) -> str:
    """Map valence/energy onto the six mood labels (Russell circumplex)."""
    if energy >= 0.6 and valence >= 0.6:
        return "euphoric"
    if valence >= 0.6:
        return "happy"
    if energy < 0.4 and valence >= 0.4:
        return "calm"
    if energy >= 0.6 and valence < 0.4:
        return "angry"
    if valence < 0.4 and energy < 0.5:
        return "melancholic"
    return "dark"


def _softmax(x: np.ndarray) -> np.ndarray:
    x = x - np.max(x)
    e = np.exp(x)
    return e / (np.sum(e) + 1e-12)


def _resize_vector(v: np.ndarray, dim: int) -> np.ndarray:
    v = np.asarray(v, dtype=np.float32).reshape(-1)
    if v.size == dim:
        return v
    if v.size > dim:
        return v[:dim]
    out = np.zeros(dim, dtype=np.float32)
    out[: v.size] = v
    return out


def _fit_to_shape(x: np.ndarray, target_shape) -> np.ndarray:
    """Best-effort adaptation of ``[1, n_mels, frames]`` to the model's input
    rank. Models that want ``[1, 1, n_mels, frames]`` get a channel axis added.
    """
    rank = len(target_shape)
    if rank == 4 and x.ndim == 3:
        return x[:, np.newaxis, :, :]
    return x
