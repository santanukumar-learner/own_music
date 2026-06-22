"""AcoustID fingerprint lookup from in-memory PCM.

Fingerprinting is done by piping raw s16le PCM to the Chromaprint ``fpcalc``
executable via **stdin** — nothing is written to disk. (We use fpcalc rather than
``acoustid.fingerprint()`` because the Windows Chromaprint release ships the
``fpcalc.exe`` tool, not the ``libchromaprint`` shared library that the in-process
API requires.) Only the resulting fingerprint hash + duration are sent to
AcoustID; ``acoustid.lookup`` is a plain HTTP call and needs no native library.

If ``fpcalc`` is missing or no API key is set, lookup is skipped (returns None)
and the pipeline falls back to MusicBrainz text search.
"""
from __future__ import annotations

import json
import logging
import subprocess

import config
from rate_limiter import RateLimiter

logger = logging.getLogger(__name__)
_limiter = RateLimiter(config.settings.acoustid_rps)

try:
    import acoustid  # only acoustid.lookup() is used (no chromaprint lib needed)

    _ACOUSTID = True
except Exception as exc:  # noqa: BLE001 - optional dependency
    acoustid = None  # type: ignore[assignment]
    _ACOUSTID = False
    logger.warning("pyacoustid unavailable; AcoustID lookup disabled: %s", exc)


def _fingerprint_pcm(pcm: bytes, sample_rate: int, channels: int) -> str | None:
    """Return the compressed Chromaprint fingerprint for raw s16le PCM, computed
    by fpcalc reading from stdin (no temp file). None on any failure."""
    s = config.settings
    cmd = [
        s.fpcalc_path,
        "-rate", str(sample_rate),
        "-channels", str(channels),
        "-format", "s16le",
        "-length", str(s.fingerprint_seconds),
        "-json",
        "-",  # read raw PCM from stdin
    ]
    try:
        proc = subprocess.run(cmd, input=pcm, capture_output=True, timeout=60)
    except FileNotFoundError:
        logger.warning("fpcalc not found at %r; skipping fingerprint.", s.fpcalc_path)
        return None
    except subprocess.TimeoutExpired:
        logger.warning("fpcalc timed out; skipping fingerprint.")
        return None

    if proc.returncode != 0:
        logger.warning(
            "fpcalc failed (rc=%s): %s",
            proc.returncode,
            proc.stderr[:200].decode("utf-8", "replace"),
        )
        return None
    try:
        data = json.loads(proc.stdout.decode("utf-8", "replace"))
        return data.get("fingerprint") or None
    except Exception as exc:  # noqa: BLE001
        logger.warning("could not parse fpcalc output: %s", exc)
        return None


def lookup_pcm(pcm: bytes, sample_rate: int, channels: int = 1) -> dict | None:
    s = config.settings
    if not _ACOUSTID:
        return None
    if not s.acoustid_api_key:
        logger.info("No ACOUSTID_API_KEY; skipping fingerprint lookup.")
        return None

    fingerprint = _fingerprint_pcm(pcm, sample_rate, channels)
    if not fingerprint:
        return None

    # Duration computed from the PCM ourselves (fpcalc reports 0 for piped input).
    duration = int(len(pcm) / (2 * channels * sample_rate)) or 1

    _limiter.acquire()
    try:
        resp = acoustid.lookup(
            s.acoustid_api_key, fingerprint, duration, meta="recordings releasegroups"
        )
    except Exception as exc:  # noqa: BLE001
        logger.warning("AcoustID lookup error: %s", exc)
        return None

    return _parse(resp)


def _parse(resp: dict) -> dict | None:
    if not resp or resp.get("status") != "ok":
        return None
    results = resp.get("results") or []
    if not results:
        return None

    best = max(results, key=lambda r: r.get("score", 0.0))
    recordings = best.get("recordings") or []
    rec = recordings[0] if recordings else {}
    artists = rec.get("artists") or []

    return {
        "acoustid_id": best.get("id"),
        "score": best.get("score"),
        "mb_track_id": rec.get("id"),
        "title": rec.get("title"),
        "artist": artists[0]["name"] if artists else None,
        "artist_mbid": artists[0]["id"] if artists else None,
    }
