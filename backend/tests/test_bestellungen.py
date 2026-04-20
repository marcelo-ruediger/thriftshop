"""
Integrationstest für /bestellungen-Endpunkte.
Datenbank muss erreichbar sein.

Ausführen aus backend/: pytest tests/test_bestellungen.py -v
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


def _neue_bestelldaten(benutzer_id: str) -> dict:
    """Erzeugt eindeutige Bestelldaten für jeden Testlauf."""
    eindeutige_id = str(uuid.uuid4())
    return {
        "bestellung_id": eindeutige_id,
        "laufende_nr": uuid.uuid4().int % 100000,
        "status": "Offen",
        "bestelldatum": "2026-04-20T10:00:00",
        "benutzer_id": benutzer_id,
    }


def _neue_bestellposition(bestellung_id: str, produkt_id: str) -> dict:
    """Erzeugt eine gültige Bestellposition mit Snapshot-Feldern."""
    return {
        "bestellposition_id": str(uuid.uuid4()),
        "menge": 2,
        "einzelpreis_gebucht": "9.99",
        "rabatt_angewendet": "0.00",
        "steuersatz_gebucht": "19.00",
        "produkt_id": produkt_id,
        "bestellung_id": bestellung_id,
    }


def _neue_produktdaten(zustand_id: str, kategorie_id: str) -> dict:
    """Erzeugt ein Produkt für Bestelltests."""
    eindeutige_id = str(uuid.uuid4())
    return {
        "produkt_id": eindeutige_id,
        "laufende_nr": uuid.uuid4().int % 100000,
        "bezeichnung": f"Bestelltestprodukt {eindeutige_id[:8]}",
        "slug": f"bestelltestprodukt-{eindeutige_id[:8]}",
        "produkt_info": "Produkt für Bestelltests",
        "preis": "9.99",
        "produkt_rabatt": "0.00",
        "lagerbestand": 10,
        "zustand_id": zustand_id,
        "kategorie_id": kategorie_id,
        "produkt_aktiv": True,
    }


class TestBestellungenAbrufen:
    """Tests für GET /bestellungen"""

    def test_alle_bestellungen_abrufen(self) -> None:
        antwort = client.get("/bestellungen/")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_bestellung_nicht_gefunden(self) -> None:
        antwort = client.get(f"/bestellungen/{uuid.uuid4()}")
        assert antwort.status_code == 404

    def test_bestellungen_nach_benutzer(self, benutzer_id: str) -> None:
        antwort = client.get(f"/bestellungen/benutzer/{benutzer_id}")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_bestellungen_nach_status(self) -> None:
        antwort = client.get("/bestellungen/status/Offen")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)


class TestBestellungenSchreiben:
    """Tests für POST und PATCH /bestellungen."""

    def test_bestellungen_erstellen_mit_position(
        self, benutzer_id: str, zustand_id: str, kategorie_id: str
    ) -> None:
        # 1) Produkt für die Position anlegen
        produkt = _neue_produktdaten(zustand_id, kategorie_id)
        produkt_antwort = client.post("/produkte", json=produkt)
        assert produkt_antwort.status_code == 201

        # 2) Bestellung + Position erstellen
        bestellung = _neue_bestelldaten(benutzer_id)
        position = _neue_bestellposition(
            bestellung["bestellung_id"], produkt["produkt_id"]
        )

        antwort = client.post(
            "/bestellungen/",
            json={"bestellung": bestellung, "positionen": [position]},
        )
        assert antwort.status_code == 201
        assert antwort.json()["bestellung_id"] == bestellung["bestellung_id"]

    def test_bestellstatus_aktualisieren(self, benutzer_id: str) -> None:
        # Für den Status-Test reichen leere Positionen
        bestellung = _neue_bestelldaten(benutzer_id)
        erstellen = client.post(
            "/bestellungen/",
            json={"bestellung": bestellung, "positionen": []},
        )
        assert erstellen.status_code == 201

        antwort = client.patch(
            f"/bestellungen/{bestellung['bestellung_id']}/status",
            params={"neuer_status": "In Bearbeitung"},
        )
        assert antwort.status_code == 200
        assert antwort.json() == {
            "bestellung_id": bestellung["bestellung_id"],
            "status": "In Bearbeitung",
        }
