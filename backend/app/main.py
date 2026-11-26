"""
Startpunkt der FastAPI-Anwendung.

- Die REST-API liegt unter /api (interaktive Dokumentation: /api/docs).
- Produktbilder werden unter /bilder ausgeliefert.
- Liegt ein gebautes Flutter-Web-Frontend vor, wird es unter / mit ausgeliefert,
  sodass Shop und API als ein einziger Dienst laufen.
"""

import logging
import re
import sqlite3
from contextlib import asynccontextmanager

from fastapi import APIRouter, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse, Response

from app.api import auth, benutzer, bestellungen, kategorien, produkte, zustaende
from app.core.config import einstellungen
from app.core.datenbank import schema_erstellen, verbinden
from app.seed import administrator_sicherstellen, demo_datenbank_bereitstellen

log = logging.getLogger("uvicorn.error")


@asynccontextmanager
async def lebenszyklus(_app: FastAPI):
    """Beim Start: Tabellen anlegen, eine leere Datenbank mit Demo-Daten füllen und
    bei Bedarf den ersten Administrator anlegen."""
    schema_erstellen()
    if einstellungen.demo_daten and demo_datenbank_bereitstellen():
        log.info("Demo-Daten eingespielt (%s)", einstellungen.datenbank_pfad)
    verbindung = verbinden()
    try:
        if administrator_sicherstellen(verbindung):
            log.info("Administrator %s angelegt", einstellungen.admin_email)
    finally:
        verbindung.close()
    yield


app = FastAPI(
    title="Thriftshop Köln API",
    description="REST-API für den Second-Hand-Webshop Thriftshop Köln.",
    version="1.0.0",
    lifespan=lebenszyklus,
    docs_url="/api/docs",
    redoc_url=None,
    openapi_url="/api/openapi.json",
)

# Das Flutter-Frontend läuft in der Entwicklung auf einem eigenen Port (localhost:xxxx)
app.add_middleware(
    CORSMiddleware,
    allow_origins=einstellungen.cors_origins,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(sqlite3.IntegrityError)
async def integritaetsfehler(_request: Request, fehler: sqlite3.IntegrityError):
    """Verletzte UNIQUE- oder Fremdschlüsselregeln werden zu HTTP 409 statt 500."""
    if "FOREIGN KEY" in str(fehler):
        nachricht = "Der Datensatz wird noch verwendet und kann nicht gelöscht werden"
    elif "UNIQUE" in str(fehler):
        nachricht = "Ein Datensatz mit dieser Bezeichnung existiert bereits"
    else:
        nachricht = "Die Daten verletzen eine Regel der Datenbank"
    return JSONResponse(status_code=409, content={"detail": nachricht})


api = APIRouter(prefix="/api")
for modul in (auth, produkte, kategorien, zustaende, bestellungen, benutzer):
    api.include_router(modul.router)


@api.get("/health", tags=["System"])
def health():
    """Einfache Erreichbarkeitsprüfung (z.B. für den Hosting-Anbieter)."""
    return {"status": "ok"}


app.include_router(api)

_BILDNAME = re.compile(r"^[\w-]+\.(webp|png|jpe?g)$")
# Der Typ wird hier festgelegt statt aus der MIME-Tabelle des Systems gelesen: Im schlanken
# Docker-Image fehlt diese Tabelle, und .webp ginge sonst als "application/octet-stream" raus.
_BILDTYPEN = {".webp": "image/webp", ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg"}


@app.get("/bilder/{dateiname}", include_in_schema=False)
def produktbild(dateiname: str, request: Request):
    """Liefert ein Produktbild - erst aus den Uploads, dann aus den mitgelieferten Bildern.

    Der Browser darf das Bild speichern, fragt aber jedes Mal nach, ob es noch aktuell ist
    (ETag). So erscheint ein unter gleichem Namen ausgetauschtes Foto sofort, und ein
    unverändertes kostet nur eine leere 304-Antwort.
    """
    if _BILDNAME.fullmatch(dateiname):
        for verzeichnis in (einstellungen.upload_verzeichnis, einstellungen.bilder_verzeichnis):
            pfad = verzeichnis / dateiname
            if pfad.is_file():
                stand = pfad.stat()
                kopf = {
                    "Cache-Control": "no-cache",
                    "ETag": f'"{stand.st_mtime_ns:x}-{stand.st_size:x}"',
                }
                if request.headers.get("if-none-match") == kopf["ETag"]:
                    return Response(status_code=304, headers=kopf)
                return FileResponse(
                    pfad, headers=kopf, stat_result=stand, media_type=_BILDTYPEN[pfad.suffix]
                )
    raise HTTPException(status_code=404, detail="Bild nicht gefunden")


@app.get("/{pfad:path}", include_in_schema=False)
def web_frontend(pfad: str):
    """Liefert das gebaute Flutter-Web-Frontend aus (falls vorhanden).

    Unbekannte Pfade erhalten die index.html, damit Deep-Links wie /produkt/xyz
    vom Router im Browser aufgelöst werden können.
    """
    web = einstellungen.web_verzeichnis.resolve()
    # API- und Bildpfade gehören nie zum Frontend - dort ist 404 die richtige Antwort
    if pfad.startswith(("api/", "bilder/")) or not (web / "index.html").is_file():
        raise HTTPException(status_code=404, detail="Nicht gefunden")
    datei = (web / pfad).resolve()
    if pfad and datei.is_file() and datei.is_relative_to(web):
        return FileResponse(datei)
    # index.html nie cachen, damit neue Versionen sofort ankommen
    return FileResponse(web / "index.html", headers={"Cache-Control": "no-cache"})
