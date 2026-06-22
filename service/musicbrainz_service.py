"""MusicBrainz lookup/search + Cover Art Archive, with Last.fm and Discogs
text-metadata fallbacks. Rate-limited per service. No audio involved here — only
identifiers and text queries.
"""
from __future__ import annotations

import logging

import musicbrainzngs as mb
import requests

import config
from rate_limiter import RateLimiter

logger = logging.getLogger(__name__)
_s = config.settings

_mb_limiter = RateLimiter(_s.musicbrainz_rps)
_lastfm_limiter = RateLimiter(_s.lastfm_rps)
_discogs_limiter = RateLimiter(1.0)

mb.set_useragent(_s.mb_app_name, _s.mb_app_version, _s.mb_contact)

COVERART_BASE = "https://coverartarchive.org"
LASTFM_BASE = "https://ws.audioscrobbler.com/2.0/"
DISCOGS_BASE = "https://api.discogs.com/database/search"


def get_recording(mbid: str) -> dict | None:
    _mb_limiter.acquire()
    try:
        data = mb.get_recording_by_id(mbid, includes=["artists", "releases", "tags"])
    except Exception as exc:  # noqa: BLE001
        logger.warning("MB get_recording failed: %s", exc)
        return None
    return _parse_recording(data.get("recording", {}))


def search_recording(title: str | None, artist: str | None) -> dict | None:
    if not title:
        return None
    _mb_limiter.acquire()
    query = {"recording": title}
    if artist:
        query["artist"] = artist
    try:
        res = mb.search_recordings(limit=5, **query)
    except Exception as exc:  # noqa: BLE001
        logger.warning("MB search failed: %s", exc)
        return None
    recs = res.get("recording-list") or []
    return _parse_recording(recs[0]) if recs else None


def cover_art_url(release_mbid: str | None) -> str | None:
    """Cover Art Archive front image URL. The device fetches/caches it; we only
    hand over the URL (CAA redirects to the actual image host)."""
    if not release_mbid:
        return None
    return f"{COVERART_BASE}/release/{release_mbid}/front-500"


def lastfm_track(title: str | None, artist: str | None) -> dict | None:
    if not _s.lastfm_api_key or not title:
        return None
    _lastfm_limiter.acquire()
    params = {
        "method": "track.getInfo",
        "api_key": _s.lastfm_api_key,
        "track": title,
        "format": "json",
    }
    if artist:
        params["artist"] = artist
    try:
        r = requests.get(LASTFM_BASE, params=params, timeout=10)
        r.raise_for_status()
        data = r.json()
    except Exception as exc:  # noqa: BLE001
        logger.warning("Last.fm error: %s", exc)
        return None

    track = data.get("track")
    if not track:
        return None
    album = (track.get("album") or {}).get("title")
    images = (track.get("album") or {}).get("image") or []
    art = images[-1]["#text"] if images and images[-1].get("#text") else None
    return {
        "title": track.get("name"),
        "artist": (track.get("artist") or {}).get("name"),
        "artist_mbid": None,
        "album": album,
        "mb_track_id": None,
        "release_mbid": None,
        "year": None,
        "cover_art_url": art,
    }


def discogs_release(title: str | None, artist: str | None) -> dict | None:
    if not _s.discogs_token or not title:
        return None
    _discogs_limiter.acquire()
    params = {"type": "release", "track": title, "token": _s.discogs_token}
    if artist:
        params["artist"] = artist
    try:
        r = requests.get(
            DISCOGS_BASE,
            params=params,
            headers={"User-Agent": f"{_s.mb_app_name}/{_s.mb_app_version}"},
            timeout=10,
        )
        r.raise_for_status()
        results = r.json().get("results") or []
    except Exception as exc:  # noqa: BLE001
        logger.warning("Discogs error: %s", exc)
        return None
    if not results:
        return None
    top = results[0]
    year = top.get("year")
    return {
        "title": title,
        "artist": artist,
        "artist_mbid": None,
        "album": top.get("title"),
        "mb_track_id": None,
        "release_mbid": None,
        "year": int(year) if str(year).isdigit() else None,
        "cover_art_url": top.get("cover_image") or top.get("thumb"),
    }


def _parse_recording(rec: dict) -> dict | None:
    if not rec:
        return None

    artist_name, artist_mbid = None, None
    for credit in rec.get("artist-credit") or []:
        if isinstance(credit, dict) and "artist" in credit:
            artist_name = credit["artist"].get("name")
            artist_mbid = credit["artist"].get("id")
            break

    release_mbid, album, year = None, None, None
    releases = rec.get("release-list") or rec.get("releases") or []
    if releases:
        rel = releases[0]
        release_mbid = rel.get("id")
        album = rel.get("title")
        year = _year(rel.get("date") or "")

    return {
        "title": rec.get("title"),
        "artist": artist_name,
        "artist_mbid": artist_mbid,
        "album": album,
        "mb_track_id": rec.get("id"),
        "release_mbid": release_mbid,
        "year": year,
        "cover_art_url": None,
    }


def _year(date: str) -> int | None:
    if date and len(date) >= 4 and date[:4].isdigit():
        return int(date[:4])
    return None
