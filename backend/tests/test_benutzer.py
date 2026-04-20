"""
Integrationstests für /benutzer-Endpunkte.
Datenbank muss erreichbar sein.

Ausführen aus backend/: pytest tests/test_benutzer.py -v
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


def _neue_benutzerdaten() -> dict:
    """Erzeugt eindeutige Benutzerdaten für jeden Testlauf."""
    eindeutige_id = str(uuid.uuid4())
    return {
        "benutzer_id": eindeutige_id,
        "vorname": "Test",
        "nachname": "Benutzer",
        "email": f"benutzer_{eindeutige_id[:8]}@test.de",
        "telefon": f"0{eindeutige_id[:10].replace('-', '')}",
        "passwort_hash": "testHash123",
        "rolle": "Kunde",
        "erstellt_am": None,
        "letzte_aenderung": None,
        "letzter_login": None,
    }


class TestBenutzerAbrufen:
    """Tests für GET /benutzer"""

    def test_alle_benutzer_abrufen(self) -> None:
        """Gibt eine Liste zurück - erwartet HTTP 200."""
        antwort = client.get("/benutzer/")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_benutzer_nach_id_abrufen(self, benutzer_id: str) -> None:
        """Vorhandenen Benutzer anhand der UUID abrufen - erwartet HTTP 200."""
        antwort = client.get(f"/benutzer/{benutzer_id}")
        assert antwort.status_code == 200
        assert antwort.json()["benutzer_id"] == benutzer_id

    def test_benutzer_nicht_gefunden(self) -> None:
        """Unbekannte UUID - erwartet HTTP 404."""
        antwort = client.get(f"/benutzer/{uuid.uuid4()}")
        assert antwort.status_code == 404


class TestBenutzerSchreiben:
    """Tests für POST, PUT, PATCH, DELETE /benutzer."""

    def test_benutzer_erstellen(self) -> None:
        """Neuen Benutzer anlegen - erwartet HTTP 201."""
        daten = _neue_benutzerdaten()
        antwort = client.post("/benutzer/", json=daten)
        assert antwort.status_code == 201
        assert antwort.json()["benutzer_id"] == daten["benutzer_id"]

    def test_benutzer_aktualisieren(self) -> None:
        """Benutzer anlegen und dann Stammdaten aktualisieren - erwartet HTTP 200."""
        daten = _neue_benutzerdaten()
        client.post("/benutzer/", json=daten)

        daten["vorname"] = "Aktualisiert"
        daten["nachname"] = "Name"
        daten["email"] = f"neu_{str(uuid.uuid4()).replace('-', '')[:8]}@test.de"

        antwort = client.put(f"/benutzer/{daten['benutzer_id']}", json=daten)
        assert antwort.status_code == 200
        assert antwort.json()["vorname"] == "Aktualisiert"
        assert antwort.json()["nachname"] == "Name"

    def test_passwort_setzen(self) -> None:
        """Passwort-Hash aktualisieren - erwartet HTTP 200."""
        daten = _neue_benutzerdaten()
        client.post("/benutzer/", json=daten)

        antwort = client.patch(
            f"/benutzer/{daten['benutzer_id']}/passwort",
            params={"neues_passwort_hash": "neuerHash456"},
        )
        assert antwort.status_code == 200
        assert antwort.json() == {
            "benutzer_id": daten["benutzer_id"],
            "passwort_aktualisiert": True,
        }

    def test_benutzer_loeschen(self) -> None:
        """Benutzer anlegen und löschen - erwartet HTTP 204."""
        daten = _neue_benutzerdaten()
        client.post("/benutzer/", json=daten)

        antwort = client.delete(f"/benutzer/{daten['benutzer_id']}")
        assert antwort.status_code == 204
