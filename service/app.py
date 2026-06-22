"""FastAPI app for the Sonata enrichment service.

Run from this directory:
    uvicorn app:app --host 0.0.0.0 --port 8973

Endpoints:
    GET  /health   -> liveness + which providers are configured
    POST /enrich   -> multipart: file=<audio>, optional form fields
                      title/artist/album/genre (ID3 hints). Returns the
                      enrichment JSON contract (see README).

Privacy: the uploaded audio lives only in RAM for the duration of the request
and is never written to disk; only the Chromaprint fingerprint hash leaves to
AcoustID.
"""
from __future__ import annotations

import logging

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.concurrency import run_in_threadpool
from fastapi.responses import JSONResponse

import config
import enrichment_pipeline as pipeline

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger("sonata.service")

app = FastAPI(title="Sonata Enrichment Service", version="0.1.0")


@app.get("/health")
def health() -> dict:
    s = config.settings
    return {
        "status": "ok",
        "version": app.version,
        "model_loaded": pipeline.classifier.available,
        "providers": {
            "acoustid": bool(s.acoustid_api_key),
            "lastfm": bool(s.lastfm_api_key),
            "discogs": bool(s.discogs_token),
        },
    }


@app.post("/enrich")
async def enrich(
    file: UploadFile = File(...),
    title: str | None = Form(None),
    artist: str | None = Form(None),
    album: str | None = Form(None),
    genre: str | None = Form(None),
) -> JSONResponse:
    max_bytes = config.settings.max_upload_mb * 1024 * 1024
    data = bytearray()
    while chunk := await file.read(1 << 20):
        data.extend(chunk)
        if len(data) > max_bytes:
            raise HTTPException(status_code=413, detail="audio file too large")

    if not data:
        raise HTTPException(status_code=400, detail="empty upload")

    # librosa/onnx are blocking + CPU-bound; keep the event loop responsive.
    result = await run_in_threadpool(
        pipeline.enrich, bytes(data), title, artist, album, genre
    )
    return JSONResponse(result)
