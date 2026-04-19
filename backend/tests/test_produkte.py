"""
Integrationstests für /produkte-Endpunkte.
Datenbank muss erreichbar sein.

Ausführen aus backend/: pytest tests/test_produkte.py -v
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


def _neue_produktdaten(zustand_id: str, kategorie_id: str) -> dict:
    """Erzeugt eindeutige Produktdaten für jeden Testlauf."""
    eindeutige_id = str(uuid.uuid4())
    return {
        "produkt_id": eindeutige_id,
        "laufende_nr": uuid.uuid4().int
        % 100000,  # zufällige laufende Nummer - maximal 5-stellige Ganzzahl
        "bezeichnung": f"Testprodukt {eindeutige_id[:8]}",
        "slug": f"testprodukt-{eindeutige_id[:8]}",
        "produkt_info": "Ein Testprodukt für automatisierte Tests.",
        "preis": "9.99",
        "produkt_rabatt": "0.00",
        "lagerbestand": 5,
        "zustand_id": zustand_id,
        "kategorie_id": kategorie_id,
        "produkt_aktiv": True,
    }


class TestProdukteAbrufen:
    """Test für GET /produkte"""

    def test_alle_produkte_abrufen(self):
        """Gibt eine Liste zurück - erwartet HTTP 200."""
        antwort = client.get("/produkte")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_aktive_produkte_abrufen(self):
        """Gibt nur aktive Produkte zurück - erwartet HTTP 200."""
        antwort = client.get("/produkte/aktiv")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_produkt_nicht_gefunden(self):
        """Unbekannte UUID - erwartet HTTP 404."""
        antwort = client.get(f"/produkte/{uuid.uuid4()}")
        assert antwort.status_code == 404


class TestProdukteSchreiben:
    """Tests für POST, PUT, DELETE /produkte."""

    def test_produkt_erstellen(self, zustand_id, kategorie_id):
        """Neues Produkt anlegen - erwartet HTTP 201."""
        antwort = client.post(
            "/produkte", json=_neue_produktdaten(zustand_id, kategorie_id)
        )
        assert antwort.status_code == 201

    def test_produkt_aktualisieren(self, zustand_id, kategorie_id):
        """Produkt anlegen und dann aktualisieren - erwartet HTTP 200."""
        daten = _neue_produktdaten(zustand_id, kategorie_id)
        client.post("/produkte/", json=daten)
        daten["bezeichnung"] = "Aktualisierter Name"
        antwort = client.put(f"/produkte/{daten['produkt_id']}", json=daten)
        assert antwort.status_code == 200

    def test_produkt_deaktivieren(self, zustand_id, kategorie_id):
        """Produkt anlegen und deaktivieren - erwartet HTTP 204."""
        daten = _neue_produktdaten(zustand_id, kategorie_id)
        client.post("/produkte/", json=daten)
        antwort = client.delete(f"/produkte/{daten['produkt_id']}")
        assert antwort.status_code == 204
