"""
Gemeinsame pytest-Fixtures für alle Integrationstests.

Fixtures mit scope="session" werden einmal pro Testlauf erstellt
und am Ende automatisch wieder gelöscht (Teardown via yield).
"""

import uuid
from collections.abc import Iterator
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


@pytest.fixture(scope="session")
def zustand_id() -> Iterator[str]:
    """Legt einen Testzustand an und gibt dessen UUID zurück.
    Wird am Ende des Testlaufs wieder gelöscht."""
    eindeutige_id = str(uuid.uuid4())
    daten = {
        "zustand_id": eindeutige_id,
        "bezeichnung": f"Testzustand {eindeutige_id[:8]}",
        "beschreibung": "Automatisch angelegter Zustand für Tests.",
    }
    antwort = client.post("/zustaende/", json=daten)
    assert antwort.status_code == 201, (
        f"Zustand konnte nicht angelegt werden: {antwort.text}"
    )

    yield eindeutige_id

    # Teardown: Zustand nach dem Testlauf löschen
    client.delete(f"/zustaende/{eindeutige_id}")


@pytest.fixture(scope="session")
def kategorie_id() -> Iterator[str]:
    """Legt eine Testkategorie an und gibt deren UUID zurück.
    Wird am Ende des Testlaufs wieder gelöscht."""
    eindeutige_id = str(uuid.uuid4())
    daten = {
        "kategorie_id": eindeutige_id,
        "bezeichnung": f"Testkategorie {eindeutige_id[:8]}",
        "slug": f"testkategorie-{eindeutige_id[:8]}",
        "kategorie_rabatt": "0.00",
        "steuersatz": "19.00",
    }
    antwort = client.post("/kategorien/", json=daten)
    assert antwort.status_code == 201, (
        f"Kategorie konnte nicht angelegt werden: {antwort.text}"
    )

    yield eindeutige_id

    # Teardown: Kategorie nach dem Testlauf löschen
    client.delete(f"/kategorien/{eindeutige_id}")


@pytest.fixture(scope="session")
def benutzer_id() -> Iterator[str]:
    """Legt einen Testbenutzer an und gibt dessen UUID zurück.
    Wird am Ende des Testlaufs wieder gelöscht."""
    eindeutige_id = str(uuid.uuid4())
    daten = {
        "benutzer_id": eindeutige_id,
        "vorname": "Test",
        "nachname": "Benutzer",
        "email": f"test_{eindeutige_id[:8]}@test.de",
        "telefon": f"0{eindeutige_id[:10].replace('-', '')}",
        "passwort_hash": "testPasswort123",
        "rolle": "Kunde",
    }
    antwort = client.post("/auth/registrieren", json=daten)
    assert antwort.status_code == 201, (
        f"Benutzer konnte nicht angelegt werden: {antwort.text}"
    )

    yield eindeutige_id

    # Teardown: Benutzer nach dem Testlauf löschen
    client.delete(f"/benutzer/{eindeutige_id}")


@pytest.fixture(scope="session")
def auth_token(benutzer_id: str) -> Iterator[str]:
    """Loggt den Testbenutzer ein und gibt den JWT-Token zurück.
    Hängt von der benutzer_id-Fixture ab."""
    # E-Mail aus der benutzer_id-Fixture rekonstruieren ist nicht möglich,
    # daher legen wir einen eigenen Login-Benutzer an.
    eindeutige_id = str(uuid.uuid4())
    email = f"login_{eindeutige_id[:8]}@test.de"
    passwort = "testPasswort123"
    daten = {
        "benutzer_id": eindeutige_id,
        "vorname": "Login",
        "nachname": "Benutzer",
        "email": email,
        "telefon": f"0{eindeutige_id[:10].replace('-', '')}",
        "passwort_hash": passwort,
        "rolle": "Kunde",
    }
    client.post("/auth/registrieren", json=daten)

    antwort = client.post("/auth/login", params={"email": email, "passwort": passwort})
    assert antwort.status_code == 200, f"Login fehlgeschlagen: {antwort.text}"

    yield antwort.json()["access_token"]

    # Teardown: Login-Benutzer nach dem Testlauf löschen
    client.delete(f"/benutzer/{eindeutige_id}")
