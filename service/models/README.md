# Genre/Mood ONNX model

This folder holds the genre classifier. It is **not committed** (kept out of git
and out of the APK to stay under the 80 MB target).

Place two files here (or point to them via `.env`):

- `genre_model.onnx` — the ONNX genre classifier (e.g. an export of
  `moises-labs/music-genre` from Hugging Face, or any equivalent that takes a
  log-mel spectrogram and outputs genre logits, optionally plus an embedding).
- `genre_labels.txt` — one genre label per line, in the model's output order.

If the model is absent or fails to load, the service automatically falls back to
a rule-based genre derived from the ID3 genre tag (see
`genre_mood_classifier.py`), so enrichment still works — just with coarser
genres.

## Matching your model's preprocessing

`feature_extractor.compute_logmel()` produces a normalized log-mel of shape
`[1, n_mels=128, frames]`. If your model expects different `n_mels`, hop length,
framing, normalization, or a `[1, 1, n_mels, frames]` channel axis, adjust
`compute_logmel()` and `_fit_to_shape()` in `genre_mood_classifier.py` to match.

## Mood

Mood is **not** taken from the model — it's derived from the librosa-computed
valence/energy via the Russell circumplex (`derive_mood()`), yielding one of:
`euphoric | happy | calm | melancholic | angry | dark`.
