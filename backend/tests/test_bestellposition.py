"""
Automatisierte Integrationstests für /bestellpositionen-Endpunkte.

Voraussetzungen:
    pip install pytest httpx
    Ausführen aus backend/: pytest tests/test_bestellposition.py -v

Hinweis: Diese Tests verwenden einen TestClient der die FastAPI-App direkt
aufruft - kein laufender Server nötig. Die Datenbank muss jedoch erreichbar sein.
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


def _registriere_kunde() -> tuple:
    """Registriert einen Kunden und gibt (benutzer_id, email, token)."""
    eindeutige_id = str(uuid.uuid4())
    email = f"kunde_bp_{uuid.uuid4().hex}@nowhere.com"
    passwort = "testPasswort123"
    daten = {
        "benutzer_id": eindeutige_id,
        "vorname": "BP",
        "nachname": "Kunde",
        "email": email,
        "telefon": f"0{eindeutige_id[:10].replace('-', '')}",
        "passwort_hash": passwort,
        "rolle": "Kunde",
    }
    client.post("/auth/registrieren", json=daten)
    antwort = client.post(
        "/auth/login",
        params={"email": email, "passwort": passwort},
    )
    assert antwort.status_code == 200, f"Login fehlgeschlagen: {antwort.text}"
    return eindeutige_id, antwort.json()["access_token"]


def _erzeuge_testprodukt(zustand_id: str, kategorie_id: str) -> str:
    """Erzeugt ein Testprodukt und gibt seine ID zurück."""
    eindeutige_id = str(uuid.uuid4())
    daten = {
        "produkt_id": eindeutige_id,
        "laufende_nr": uuid.uuid4().int % 100000,
        "bezeichnung": f"BP-Testprodukt {eindeutige_id[:8]}",
        "slug": f"bp-testprodukt-{eindeutige_id[:8]}",
        "produkt_info": "Testprodukt für Bestellpositionen-Tests",
        "preis": "9.99",
        "produkt_rabatt": "0.00",
        "lagerbestand": 10,
        "zustand_id": zustand_id,
        "kategorie_id": kategorie_id,
        "produkt_aktiv": True,
    }
    antwort = client.post("/produkte", json=daten)
    assert antwort.status_code == 201, f"Produkt fehlgeschlagen: {antwort.text}"
    return eindeutige_id


def _neue_bestelldaten(benutzer_id: str, produkt_id: str, token: str) -> tuple:
    """Erzeugt eine Bestellung im neuen Frontend-Format und gibt (bestellung_id, produkt_id) zurück.
    
    Sendet bestellpositionen und gesamtpreis, wie vom Backend-POST /bestellungen erwartet.
    Extrahiert bestellung_id aus der Backend-Antwort.
    """
    antwort = client.post(
        "/bestellungen/",
        json={
            "bestellpositionen": [
                {
                    "produkt_id": produkt_id,
                    "menge": 2,
                    "preis": "15.99",
                }
            ],
            "gesamtpreis": 31.98,
        },
        headers={"Authorization": f"Bearer {token}"},
    )
    assert antwort.status_code == 201, f"Bestellung konnte nicht erstellt werden: {antwort.text}"
    antwort_data = antwort.json()
    bestellung_id = antwort_data["bestellung_id"]

    return bestellung_id, produkt_id


class TestBestellpositionenAbrufen:
    """Tests für GET /bestellpositionen-Endpunkte."""

    def test_positionen_nach_bestellung_erfolgreich(
        self, zustand_id: str, kategorie_id: str
    ):
        """Gibt alle Positionen einer Bestellung zurück - erwartet HTTP 200."""
        benutzer_id, token = _registriere_kunde()
        produkt_id = _erzeuge_testprodukt(zustand_id, kategorie_id)
        bestellung_id, _ = _neue_bestelldaten(benutzer_id, produkt_id, token)

        antwort = client.get(f"/bestellpositionen/bestellung/{bestellung_id}")
        assert antwort.status_code == 200
        positionen = antwort.json()
        assert isinstance(positionen, list)
        assert len(positionen) >= 1
        assert positionen[0]["bestellung_id"] == bestellung_id

    def test_positionen_nach_produkt_leere_liste(self):
        """Gibt Positionen zu einem nicht existierenden Produkt zurück - erwartet HTTP 200."""
        produkt_id = str(uuid.uuid4())
        antwort = client.get(f"/bestellpositionen/produkt/{produkt_id}")
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_position_nicht_gefunden(self):
        """Gibt eine nicht existierende Position zurück - erwartet HTTP 404."""
        falsche_id = str(uuid.uuid4())
        antwort = client.get(f"/bestellpositionen/{falsche_id}")
        assert antwort.status_code == 404
        assert antwort.json()["detail"] == "Bestellposition nicht gefunden"
