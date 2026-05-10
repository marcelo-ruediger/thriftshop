"""
Integrationstest für /bestellungen-Endpunkte.
Datenbank muss erreichbar sein.

Ausführen aus backend/: pytest tests/test_bestellungen.py -v
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


def _neue_bestelldaten(benutzer_id: str, produkt_id: str = None) -> dict:
    """Erzeugt eindeutige Bestelldaten für jeden Testlauf im neuen Frontend-Format.
    
    Gibt ein Dict mit bestellpositionen und gesamtpreis zurück, wie vom
    Backend-POST /bestellungen erwartet.
    """
    preis = 9.99
    menge = 2
    if produkt_id:
        return {
            "bestellpositionen": [
                {
                    "produkt_id": produkt_id,
                    "menge": menge,
                    "preis": str(preis),
                }
            ],
            "gesamtpreis": preis * menge,
        }
    # Ohne produkt_id: leere Bestellung für Status-Tests
    return {
        "bestellpositionen": [],
        "gesamtpreis": 0,
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

    def test_alle_bestellungen_abrufen(self, admin_token: str) -> None:
        antwort = client.get(
            "/bestellungen/",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_bestellung_nicht_gefunden(self, auth_token: str) -> None:
        antwort = client.get(
            f"/bestellungen/{uuid.uuid4()}",
            headers={"Authorization": f"Bearer {auth_token}"},
        )
        assert antwort.status_code == 404

    def test_bestellungen_nach_benutzer(self, admin_token: str) -> None:
        antwort = client.get(
            f"/bestellungen/benutzer/{uuid.uuid4()}",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_bestellungen_nach_status(self, admin_token: str) -> None:
        antwort = client.get(
            "/bestellungen/status/Offen",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)


class TestBestellungenSchreiben:
    """Tests für POST und PATCH /bestellungen."""

    def test_bestellungen_erstellen_mit_position(
        self, auth_token: str, benutzer_id: str, zustand_id: str, kategorie_id: str
    ) -> None:
        # 1) Produkt für die Position anlegen
        produkt = _neue_produktdaten(zustand_id, kategorie_id)
        produkt_antwort = client.post("/produkte", json=produkt)
        assert produkt_antwort.status_code == 201

        # 2) Bestellung mit Position im Frontend-Format erstellen
        antwort = client.post(
            "/bestellungen/",
            json=_neue_bestelldaten(benutzer_id, produkt["produkt_id"]),
            headers={"Authorization": f"Bearer {auth_token}"},
        )
        assert antwort.status_code == 201
        antwort_data = antwort.json()
        assert "bestellung_id" in antwort_data
        # 3) Verify die Bestellung hat mindestens eine Position
        position_antwort = client.get(
            f"/bestellpositionen/bestellung/{antwort_data['bestellung_id']}"
        )
        assert position_antwort.status_code == 200
        positionen = position_antwort.json()
        assert len(positionen) >= 1
        assert positionen[0]["produkt_id"] == produkt["produkt_id"]

    def test_bestellstatus_aktualisieren(
        self, auth_token: str, admin_token: str, benutzer_id: str, zustand_id: str, kategorie_id: str
    ) -> None:
        # Zuerst ein Produkt erstellen
        produkt = _neue_produktdaten(zustand_id, kategorie_id)
        produkt_antwort = client.post("/produkte", json=produkt)
        assert produkt_antwort.status_code == 201

        # Dann eine Bestellung im Frontend-Format erstellen
        antwort = client.post(
            "/bestellungen/",
            json=_neue_bestelldaten(benutzer_id, produkt["produkt_id"]),
            headers={"Authorization": f"Bearer {auth_token}"},
        )
        assert antwort.status_code == 201
        bestell_data = antwort.json()
        bestellung_id = bestell_data["bestellung_id"]

        # Status auf "In Bearbeitung" setzen
        antwort = client.patch(
            f"/bestellungen/{bestellung_id}/status",
            params={"neuer_status": "In Bearbeitung"},
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 200
        assert antwort.json() == {
            "bestellung_id": bestellung_id,
            "status": "In Bearbeitung",
        }
