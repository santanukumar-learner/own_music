"""A tiny thread-safe minimum-interval rate limiter.

Spaces calls at least ``1/rps`` apart so we respect external API limits
(MusicBrainz 1 req/s, AcoustID 3 req/s) even under concurrent enrichment.
"""
from __future__ import annotations

import threading
import time


class RateLimiter:
    def __init__(self, rps: float) -> None:
        self._min_interval = 1.0 / rps if rps > 0 else 0.0
        self._lock = threading.Lock()
        self._next_allowed = 0.0

    def acquire(self) -> None:
        """Block until the next call is permitted, then reserve the slot."""
        with self._lock:
            now = time.monotonic()
            wait = self._next_allowed - now
            if wait > 0:
                time.sleep(wait)
                now = time.monotonic()
            self._next_allowed = max(now, self._next_allowed) + self._min_interval
