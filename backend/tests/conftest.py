"""
Gemeinsame pytest-Fixtures.

Die Tests laufen gegen eine frische SQLite-Datenbank in einem temporären Verzeichnis,
die beim Start mit den Demo-Daten gefüllt wird. Die Umgebungsvariablen müssen gesetzt
sein, bevor die App importiert wird.
"""

import os
import tempfile
import uuid
from pathlib import Path

_TMP = Path(tempfile.mkdtemp(prefix="thriftshop-tests-"))
os.environ["DATABASE_PATH"] = str(_TMP / "test.db")
os.environ["UPLOAD_DIR"] = str(_TMP / "uploads")
os.environ["JWT_SECRET"] = "nur-fuer-tests"
os.environ["SEED_DEMO_DATA"] = "true"
os.environ["DEMO_MODUS"] = "true"

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402


@pytest.fixture(scope="session")
def client():
    # Der Kontextmanager führt den Lifespan aus (Schema + Demo-Daten)
    with TestClient(app) as test_client:
        yield test_client


def _anmelden(client: TestClient, email: str, passwort: str) -> dict[str, str]:
    antwort = client.post("/api/auth/login", json={"email": email, "passwort": passwort})
    assert antwort.status_code == 200, antwort.text
    return {"Authorization": f"Bearer {antwort.json()['access_token']}"}


@pytest.fixture(scope="session")
def admin(client) -> dict[str, str]:
    """Authorization-Header des Demo-Administrators."""
    return _anmelden(client, "admin@example.com", "admin1234")


@pytest.fixture(scope="session")
def mitarbeiter(client) -> dict[str, str]:
    """Authorization-Header der Demo-Mitarbeiterin."""
    return _anmelden(client, "team@example.com", "team1234")


@pytest.fixture
def ohne_demo_modus(monkeypatch):
    """Schaltet den Demo-Modus für einen Test ab (kein Schutz und keine Maskierung)."""
    from app.core.config import einstellungen

    monkeypatch.setattr(einstellungen, "demo_modus", False)


@pytest.fixture
def neuer_kunde(client):
    """Registriert einen frischen Kunden und gibt (Header, Benutzerdaten, Passwort) zurück."""
    kennung = uuid.uuid4().hex[:10]
    daten = {
        "vorname": "Test",
        "nachname": "Kundin",
        "email": f"test-{kennung}@example.com",
        "telefon": "0221 123456",
        "passwort": "geheim1234",
    }
    antwort = client.post("/api/auth/registrieren", json=daten)
    assert antwort.status_code == 201, antwort.text
    inhalt = antwort.json()
    return {"Authorization": f"Bearer {inhalt['access_token']}"}, inhalt["benutzer"], daten["passwort"]


@pytest.fixture
def kunde(neuer_kunde) -> dict[str, str]:
    """Authorization-Header eines frisch registrierten Kunden."""
    return neuer_kunde[0]


@pytest.fixture
def stammdaten(client) -> dict[str, str]:
    """IDs einer vorhandenen Kategorie und eines vorhandenen Zustands."""
    return {
        "kategorie_id": client.get("/api/kategorien").json()[0]["kategorie_id"],
        "zustand_id": client.get("/api/zustaende").json()[0]["zustand_id"],
    }


@pytest.fixture
def produkt_anlegen(client, admin, stammdaten):
    """Fabrik: legt ein Produkt mit eindeutigem Namen an und gibt es zurück."""

    def _anlegen(**felder) -> dict:
        daten = {
            "bezeichnung": f"Testartikel {uuid.uuid4().hex[:8]}",
            "produkt_info": "Automatisch angelegt für einen Test.",
            "preis": "20.00",
            "lagerbestand": 3,
            **stammdaten,
            **felder,
        }
        antwort = client.post("/api/produkte", json=daten, headers=admin)
        assert antwort.status_code == 201, antwort.text
        return antwort.json()

    return _anlegen
