"""Per-song enrichment orchestration (Task B fallback chain).

Decodes the uploaded audio once (in-memory), then:
  1. Fingerprint via Chromaprint/AcoustID  -> MusicBrainz recording
  2. else MusicBrainz text search (title+artist)
  3. else Last.fm track lookup
  4. else Discogs release lookup
  5. Cover art URL (Cover Art Archive / provider image)
  6. Audio features (BPM, key, valence, energy) + genre/mood
Always returns a structured dict; never raises to the caller.
"""
from __future__ import annotations

import logging

import acoustid_service
import config
import feature_extractor as fx
import musicbrainz_service as mbs
from genre_mood_classifier import GenreMoodClassifier, derive_mood

logger = logging.getLogger(__name__)

# One shared classifier (loads the ONNX model once at process start).
classifier = GenreMoodClassifier(
    config.settings.model_path, config.settings.labels_path
)

# Status values mirror Song.metadataStatus on the device.
_RAW, _ENRICHED, _FINGERPRINTED, _FAILED = (
    "raw",
    "enriched",
    "fingerprinted",
    "failed",
)


def enrich(
    audio_bytes: bytes,
    id3_title: str | None = None,
    id3_artist: str | None = None,
    id3_album: str | None = None,
    id3_genre: str | None = None,
) -> dict:
    s = config.settings
    result: dict = {
        "status": _FAILED,
        "source": "none",
        "title": id3_title,
        "artist": id3_artist,
        "album": id3_album,
        "artist_mbid": None,
        "mb_track_id": None,
        "acoustid_id": None,
        "year": None,
        "decade": None,
        "cover_art_url": None,
        "audio_features": None,
        "classification": None,
        "error": None,
    }

    # --- Decode once, in memory ---
    try:
        y, sr = fx.load_waveform(
            audio_bytes, sr=s.sample_rate, max_seconds=s.feature_seconds
        )
    except Exception as exc:  # noqa: BLE001
        result["error"] = f"decode: {exc}"
        return result

    # --- Metadata resolution chain ---
    meta = None
    try:
        fp_samples = y[: s.fingerprint_seconds * sr]
        ac = acoustid_service.lookup_pcm(fx.to_pcm16(fp_samples), sr, 1)
        if ac and ac.get("mb_track_id"):
            result["acoustid_id"] = ac.get("acoustid_id")
            meta = mbs.get_recording(ac["mb_track_id"]) or ac
            result["source"] = "acoustid"
            result["status"] = _FINGERPRINTED
    except Exception as exc:  # noqa: BLE001
        logger.exception("AcoustID stage error: %s", exc)

    if meta is None:
        meta = mbs.search_recording(id3_title, id3_artist)
        if meta:
            result["source"], result["status"] = "musicbrainz_search", _ENRICHED

    if meta is None:
        meta = mbs.lastfm_track(id3_title, id3_artist)
        if meta:
            result["source"], result["status"] = "lastfm", _ENRICHED

    if meta is None:
        meta = mbs.discogs_release(id3_title, id3_artist)
        if meta:
            result["source"], result["status"] = "discogs", _ENRICHED

    if meta:
        for key in ("title", "artist", "artist_mbid", "album", "mb_track_id", "year"):
            if meta.get(key) is not None:
                result[key] = meta[key]
        if result["year"]:
            result["decade"] = (int(result["year"]) // 10) * 10
        result["cover_art_url"] = meta.get("cover_art_url") or mbs.cover_art_url(
            meta.get("release_mbid")
        )

    # --- Audio features + genre/mood (works fully offline) ---
    try:
        feats = fx.extract_features(y, sr)
        result["audio_features"] = {
            "bpm": feats.bpm,
            "musical_key": feats.musical_key,
            "valence": feats.valence,
            "energy": feats.energy,
            "duration_ms": feats.duration_ms,
        }

        mel = None
        if classifier.available:
            try:
                mel = fx.compute_logmel(y, sr)
            except Exception as exc:  # noqa: BLE001
                logger.warning("log-mel computation failed: %s", exc)

        classification = classifier.classify(mel, id3_genre)
        classification["mood"] = derive_mood(feats.valence, feats.energy)
        result["classification"] = classification

        # Even with no web match we produced local features/genre/mood, so this
        # is a successful (if tag-only) enrichment rather than a failure.
        if result["status"] == _FAILED:
            result["status"] = _ENRICHED
            result["source"] = "local_features"
    except Exception as exc:  # noqa: BLE001
        logger.exception("Feature extraction failed: %s", exc)
        result["error"] = f"feature_extraction: {exc}"

    return result
