"""
Zentrale Konfiguration - liest alle Einstellungen aus Umgebungsvariablen (optional aus backend/.env).

Jede Einstellung hat einen sinnvollen Standardwert, damit das Projekt ohne
weitere Einrichtung startet (`uvicorn app.main:app`).
"""

import os
import secrets
from pathlib import Path

from dotenv import load_dotenv

BACKEND_DIR = Path(__file__).resolve().parents[2]
load_dotenv(BACKEND_DIR / ".env")


def _bool(name: str, standard: bool) -> bool:
    wert = os.getenv(name)
    if wert is None:
        return standard
    return wert.strip().lower() in {"1", "true", "yes", "ja", "on"}


def _liste(name: str) -> list[str]:
    return [teil.strip() for teil in os.getenv(name, "").split(",") if teil.strip()]


class Einstellungen:
    def __init__(self) -> None:
        # SQLite-Datei; das Verzeichnis wird beim Start angelegt
        self.datenbank_pfad = Path(
            os.getenv("DATABASE_PATH", BACKEND_DIR / "data" / "thriftshop.db")
        )
        # Vom Admin hochgeladene Produktbilder
        self.upload_verzeichnis = Path(
            os.getenv("UPLOAD_DIR", self.datenbank_pfad.parent / "uploads")
        )
        # Mitgelieferte Produktbilder der Demo-Daten
        self.bilder_verzeichnis = BACKEND_DIR / "static" / "produktbilder"
        # Gebautes Flutter-Web-Frontend (optional) - wird vom Backend mit ausgeliefert
        self.web_verzeichnis = Path(os.getenv("WEB_DIR", BACKEND_DIR / "static" / "web"))

        # Ohne JWT_SECRET wird pro Prozessstart ein zufälliges Geheimnis erzeugt.
        # Tokens verlieren dann bei jedem Neustart ihre Gültigkeit.
        self.jwt_secret = os.getenv("JWT_SECRET") or secrets.token_urlsafe(48)
        self.token_ablauf_minuten = int(os.getenv("TOKEN_ABLAUF_MINUTEN", 60 * 24))

        # Zusätzliche erlaubte Origins (kommagetrennt); localhost ist immer erlaubt
        self.cors_origins = _liste("CORS_ORIGINS")

        # Erster Administrator für einen Betrieb ohne Demo-Daten: wird beim Start angelegt,
        # solange es noch keinen Administrator gibt
        self.admin_email = os.getenv("ADMIN_EMAIL", "").strip().lower()
        self.admin_passwort = os.getenv("ADMIN_PASSWORT", "")

        # Demo-Daten (Katalog + Demo-Konten) beim ersten Start einspielen
        self.demo_daten = _bool("SEED_DEMO_DATA", True)
        # Im Demo-Modus sind die Demo-Konten vor Passwort-/E-Mail-Änderung und Löschung geschützt
        self.demo_modus = _bool("DEMO_MODUS", True)


einstellungen = Einstellungen()
