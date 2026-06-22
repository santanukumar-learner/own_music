# Sonata Enrichment Service (LAN)

A small FastAPI service that runs on **your PC** on the local network. The phone
streams each audio file to it during the enrichment pass; the service identifies
the track (Chromaprint → AcoustID → MusicBrainz, with Last.fm/Discogs fallbacks),
extracts audio features (librosa: BPM, key, valence, energy), classifies
genre/mood (ONNX), and returns JSON. After enrichment the phone works fully
offline.

## Privacy model

- Audio is uploaded **only to this service on your LAN**, held in RAM, and
  **never written to disk** here.
- Only the **Chromaprint fingerprint hash** + duration leave to AcoustID, and
  only **text queries** (title/artist, MBIDs) go to MusicBrainz/Last.fm/Discogs.
- No audio ever reaches any cloud or third party.

## Prerequisites

- **Python 3.11 or 3.12**
- **Chromaprint `fpcalc`** executable (for fingerprinting). Raw PCM is piped to
  it over **stdin**, so no temp files are written.
  - Download from https://acoustid.org/chromaprint and place `fpcalc`
    (`fpcalc.exe` on Windows) in this `service/` folder, **or** set
    `FPCALC=/path/to/fpcalc`, **or** put it on PATH.
  - macOS: `brew install chromaprint`; Linux: `apt install libchromaprint-tools`.
  - If `fpcalc` is missing (or no AcoustID key is set), fingerprinting is skipped
    and the pipeline falls back to MusicBrainz text search — lower hit rate, still
    works.
- **ffmpeg** (recommended) for broad audio-format decoding support.
- Optional: an [AcoustID API key](https://acoustid.org/new-application),
  [Last.fm key](https://www.last.fm/api/account/create),
  [Discogs token](https://www.discogs.com/settings/developers).

## Setup

```bash
cd service
python -m venv .venv
# Windows:  .venv\Scripts\activate
# Unix:     source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env        # then fill in API keys (or leave blank)
```

Optionally drop a genre model into `models/` (see `models/README.md`).

## Run

```bash
uvicorn app:app --host 0.0.0.0 --port 8973
```

Find your PC's LAN IP (`ipconfig` / `ifconfig`) and set it in the app's Settings
screen, e.g. `http://192.168.1.20:8973`.

## API

### `GET /health`
```json
{ "status": "ok", "version": "0.1.0", "model_loaded": false,
  "providers": { "acoustid": true, "lastfm": false, "discogs": false } }
```

### `POST /enrich` (multipart/form-data)
Fields: `file` (audio, required), `title`, `artist`, `album`, `genre` (optional
ID3 hints). Response contract:

```jsonc
{
  "status": "fingerprinted | enriched | failed",
  "source": "acoustid | musicbrainz_search | lastfm | discogs | local_features | none",
  "title": "Blinding Lights",
  "artist": "The Weeknd",
  "artist_mbid": "c8b03190-306c-4120-bb0b-6f2ebfc06ea9",
  "album": "After Hours",
  "mb_track_id": "…",
  "acoustid_id": "…",
  "year": 2020,
  "decade": 2020,
  "cover_art_url": "https://coverartarchive.org/release/…/front-500",
  "audio_features": {
    "bpm": 171.0, "musical_key": "C#", "valence": 0.72,
    "energy": 0.81, "duration_ms": 200040
  },
  "classification": {
    "genres": ["synthpop", "pop", "new wave"],
    "genre_confidences": [0.61, 0.22, 0.07],
    "mood": "euphoric",
    "genre_embedding": [/* 128 floats */],
    "source": "onnx | id3_fallback"
  },
  "error": null
}
```

The device assembles the final 134-d `Song.featureVector` from
`classification.genre_embedding` (128) + `[valence, energy]` + `bpm_norm` +
`key_index` + `artist_hash` + `decade_norm`, L2-normalizes it, and inserts it
into the on-device HNSW index (deliverables 6 & 8).

## Rate limits

Enforced in-process: AcoustID 3 req/s, MusicBrainz 1 req/s, Last.fm 5 req/s.
