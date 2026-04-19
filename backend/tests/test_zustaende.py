"""
Integrationstests für /zustaende-Endpunkte.
Datenbank muss erreichbar sein.

Ausführen aus backend/: pytest tests/test_zustaende.py -v
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


def _neue_zustandsdaten() -> dict:
    """Erzeugt eindeutige Zustandsdaten für jeden Testlauf."""
    eindeutige_id = str(uuid.uuid4())
    return {
        "zustand_id": eindeutige_id,
        "bezeichnung": f"Testzustand {eindeutige_id[:8]}",
        "beschreibung": "Automatisch angelegter Zustand für Tests.",
    }


class TestZustaendeAbrufen:
    """Test für GET /zustaende"""

    def test_alle_zustaende_abrufen(self):
        """Gibt eine Liste zurück - erwartet HTTP 200."""
        antwort = client.get("/zustaende/")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_zustand_nicht_gefunden(self):
        """Unbekannte UUID - erwartet HTTP 404."""
        antwort = client.get(f"/zustaende/{uuid.uuid4()}")
        assert antwort.status_code == 404

    def test_zustand_nach_bezeichnung(self, zustand_id: str):
        """Zustand anhand der Bezeichnung abrufen - erwartet HTTP 200."""
        # Bezeichnung der Fixture-Zustand ermitteln
        antwort = client.get(f"/zustaende/{zustand_id}")
        assert antwort.status_code == 200
        bezeichnung = antwort.json()["bezeichnung"]

        # Dann nach Bezeichnung suchen
        antwort = client.get(f"/zustaende/bezeichnung/{bezeichnung}")
        assert antwort.status_code == 200
        assert antwort.json()["zustand_id"] == zustand_id

    def test_bezeichnung_nicht_gefunden(self):
        """Unbekannte Bezeichnung - erwartet HTTP 404."""
        antwort = client.get("/zustaende/bezeichnung/diese-bezeichnung-existiert-nicht")
        assert antwort.status_code == 404


class TestZustaendeSchreiben:
    """Tests für POST, PUT, DELETE /zustaende."""

    def test_zustand_erstellen(self):
        """Neuen Zustand anlegen - erwartet HTTP 201."""
        antwort = client.post("/zustaende/", json=_neue_zustandsdaten())
        assert antwort.status_code == 201

    def test_zustand_aktualisieren(self):
        """Zustand anlegen und dann aktualisieren - erwartet HTTP 200."""
        daten = _neue_zustandsdaten()
        client.post("/zustaende/", json=daten)
        daten["bezeichnung"] = "Aktualisierter Zustand"
        antwort = client.put(f"/zustaende/{daten['zustand_id']}", json=daten)
        assert antwort.status_code == 200

    def test_zustand_loeschen(self):
        """Zustand anlegen und löschen - erwartet HTTP 204.
        Eigener Zustand ohne Produkte, damit ON DELETE RESTRICT nicht greift."""
        daten = _neue_zustandsdaten()
        client.post("/zustaende/", json=daten)
        antwort = client.delete(f"/zustaende/{daten['zustand_id']}")
        assert antwort.status_code == 204

    def test_zustand_loeschen_mit_produkt_schlaegt_fehl(self, zustand_id: str):
        """Zustand mit zugeordneten Produkten kann nicht gelöscht werden.
        Die conftest-Zustand wird von Produkt-Tests verwendet - erwartet HTTP 500."""
        antwort = client.delete(f"/zustaende/{zustand_id}")
        # ON DELETE RESTRICT: DB verweigert das Löschen
        assert antwort.status_code == 500
