"""
Integrationstests für /kategorien-Endpunkte.
Datenbank muss erreichbar sein.

Ausführen aus backend/: pytest tests/test_kategorien.py -v
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


def _neue_kategoriedaten() -> dict:
    """Erzeugt eindeutige Kategoriedaten für jeden Testlauf."""
    eindeutige_id = str(uuid.uuid4())
    return {
        "kategorie_id": eindeutige_id,
        "bezeichnung": f"Testkategorie {eindeutige_id[:8]}",
        "slug": f"testkategorie-{eindeutige_id[:8]}",
        "kategorie_rabatt": "0.00",
        "steuersatz": "19.00",
    }


class TestKategorienAbrufen:
    """Tests für GET /kategorien"""

    def test_alle_kategorien_abrufen(self):
        """Gibt eine Liste zurück - erwartet HTTP 200."""
        antwort = client.get("/kategorien/")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_kategorie_nicht_gefunden(self):
        """Unbekannte UUID - erwartet HTTP 404."""
        antwort = client.get(f"/kategorien/{uuid.uuid4()}")
        assert antwort.status_code == 404

    def test_kategorie_nach_slug(self, kategorie_id: str):
        """Kategorie anhand des SEO-Slugs abrufen - erwartet HTTP 200.
        Holt den Slug der Fixture-Kategorie und sucht danach."""
        # Slug der Fixture-Kategorie ermitteln
        antwort = client.get(f"/kategorien/{kategorie_id}")
        assert antwort.status_code == 200
        slug = antwort.json()["slug"]

        # Dann nach Slug suchen
        antwort = client.get(f"/kategorien/slug/{slug}")
        assert antwort.status_code == 200
        assert antwort.json()["kategorie_id"] == kategorie_id

    def test_slug_nicht_gefunden(self):
        """Unbekannter Slug - erwartet HTTP 404."""
        antwort = client.get("/kategorien/slug/dieser-slug-existiert-nicht")
        assert antwort.status_code == 404


class TestKategorienSchreiben:
    """Tests für POST, PUT, DELETE /kategorien."""

    def test_kategorie_erstellen(self):
        """Neue Kategorie anlegen - erwartet HTTP 201."""
        antwort = client.post("/kategorien/", json=_neue_kategoriedaten())
        assert antwort.status_code == 201

    def test_kategorie_aktualisieren(self):
        """Kategorie anlegen und dann aktualisieren - erwartet HTTP 200."""
        daten = _neue_kategoriedaten()
        client.post("/kategorien/", json=daten)
        daten["bezeichnung"] = "Aktualisierte Kategorie"
        antwort = client.put(f"/kategorien/{daten['kategorie_id']}", json=daten)
        assert antwort.status_code == 200

    def test_kategorie_loeschen(self):
        """Kategorie anlegen und löschen - erwartet HTTP 204.
        Eigene Kategorie ohne Produkte, damit ON DELETE RESTRICT nicht greift."""
        daten = _neue_kategoriedaten()
        client.post("/kategorien/", json=daten)
        antwort = client.delete(f"/kategorien/{daten['kategorie_id']}")
        assert antwort.status_code == 204

    def test_kategorie_loeschen_mit_produkt_schlaegt_fehl(self, kategorie_id: str):
        """Kategorie mit zugeordneten Produkten kann nicht gelöscht werden.
        Die konftest-Kategorie wird von Produkt-Tests verwendet - erwartet HTTP 500."""
        antwort = client.delete(f"/kategorien/{kategorie_id}")
        # ON DELETE RESTRICT: DB verweigert das Löschen
        assert antwort.status_code == 500
