"""Runtime configuration for the Sonata enrichment service.

Secrets come from environment variables (optionally loaded from a local ``.env``);
nothing is hard-coded. See ``.env.example``.
"""
from __future__ import annotations

import os
import shutil
from pathlib import Path

try:  # python-dotenv is optional; absence just means rely on real env vars.
    from dotenv import load_dotenv

    load_dotenv()
except Exception:  # pragma: no cover - optional dependency
    pass

BASE_DIR = Path(__file__).resolve().parent


def _get(name: str, default: str = "") -> str:
    return os.environ.get(name, default).strip()


def _get_int(name: str, default: int) -> int:
    raw = _get(name, str(default))
    try:
        return int(raw)
    except ValueError:
        return default


class Settings:
    """Process-wide settings, read once at import time."""

    def __init__(self) -> None:
        self.host: str = _get("SONATA_HOST", "0.0.0.0")
        self.port: int = _get_int("SONATA_PORT", 8973)

        # External API credentials (all optional; the pipeline degrades).
        self.acoustid_api_key: str = _get("ACOUSTID_API_KEY")
        self.lastfm_api_key: str = _get("LASTFM_API_KEY")
        self.discogs_token: str = _get("DISCOGS_TOKEN")

        # MusicBrainz requires a descriptive User-Agent (no key needed).
        self.mb_app_name: str = _get("MB_APP_NAME", "SonataMusicPlayer")
        self.mb_app_version: str = _get("MB_APP_VERSION", "0.1.0")
        self.mb_contact: str = _get("MB_CONTACT", "founder@helprevx.com")

        # Per-service rate limits (requests/second) — honored by RateLimiter.
        self.acoustid_rps: float = 3.0
        self.musicbrainz_rps: float = 1.0
        self.lastfm_rps: float = 5.0

        # ONNX genre/mood model.
        self.model_path: Path = Path(
            _get("SONATA_MODEL_PATH", str(BASE_DIR / "models" / "genre_model.onnx"))
        )
        self.labels_path: Path = Path(
            _get("SONATA_LABELS_PATH", str(BASE_DIR / "models" / "genre_labels.txt"))
        )

        # Audio handling.
        self.sample_rate: int = 22050        # decode/analysis sample rate
        self.fingerprint_seconds: int = 30   # AcoustID uses the first 30s
        self.feature_seconds: int = 120      # cap analysis window for speed
        self.max_upload_mb: int = _get_int("SONATA_MAX_UPLOAD_MB", 60)

        # Chromaprint fpcalc executable. We feed it raw PCM over stdin, so no
        # temp file is ever written. Resolution order:
        #   $FPCALC  ->  bundled service/fpcalc(.exe)  ->  PATH.
        env_fpcalc = _get("FPCALC")
        bundled = BASE_DIR / ("fpcalc.exe" if os.name == "nt" else "fpcalc")
        if env_fpcalc:
            self.fpcalc_path: str = env_fpcalc
        elif bundled.exists():
            self.fpcalc_path = str(bundled)
        else:
            self.fpcalc_path = shutil.which("fpcalc") or "fpcalc"


settings = Settings()
