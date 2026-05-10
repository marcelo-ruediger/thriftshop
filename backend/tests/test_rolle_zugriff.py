"""
Automatisierte Integrationstests für rollenbasierte Zugriffskontrolle.

Testet, dass Kunden (Rolle "Kunde") keine Admin-Routen aufrufen können
und HTTP 403 erhalten.

Voraussetzungen:
    pip install pytest httpx
    Ausführen aus backend/: pytest tests/test_rolle_zugriff.py -v
"""

import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)


def _registriere_kunde() -> tuple:
    """Registriert einen Kunden und gibt (benutzer_id, email, token) zurück."""
    eindeutige_id = str(uuid.uuid4())
    email = f"kunde_{eindeutige_id[:8]}@test.de"
    passwort = "testPasswort123"
    daten = {
        "benutzer_id": eindeutige_id,
        "vorname": "Kunde",
        "nachname": "Test",
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
    assert antwort.status_code == 200
    token = antwort.json()["access_token"]
    return eindeutige_id, email, token


def _registriere_admin() -> tuple:
    """Registriert einen Admin und gibt (benutzer_id, email, token) zurück."""
    eindeutige_id = str(uuid.uuid4())
    email = f"admin_zugriff_{eindeutige_id[:8]}@test.de"
    passwort = "adminPasswort123"
    daten = {
        "benutzer_id": eindeutige_id,
        "vorname": "Admin",
        "nachname": "Zugriff",
        "email": email,
        "telefon": f"0{eindeutige_id[:10].replace('-', '')}",
        "passwort_hash": passwort,
        "rolle": "Administrator",
    }
    client.post("/auth/registrieren", json=daten)
    antwort = client.post(
        "/auth/login",
        params={"email": email, "passwort": passwort},
    )
    assert antwort.status_code == 200
    token = antwort.json()["access_token"]
    return eindeutige_id, email, token


class TestKundeDarfKeinAdmin:
    """Tests: Kunde erhält 403 bei Admin-Routen."""

    def test_kunde_darf_keine_alle_bestellungen_sehen(self, auth_token: str) -> None:
        """Kunde kann alle Bestellungen nicht aufrufen - erwartet HTTP 403."""
        antwort = client.get(
            "/bestellungen/",
            headers={"Authorization": f"Bearer {auth_token}"},
        )
        assert antwort.status_code == 403
        assert antwort.json()["detail"] == "Keine Berechtigung"

    def test_kunde_darf_kein_bestellstatus_andern(
        self, auth_token: str, admin_token: str, benutzer_id: str
    ) -> None:
        """Kunde kann Bestellstatus nicht ändern - erwartet HTTP 403."""
        # Zuerst eine Bestellung als Admin anlegen
        bestellung = {
            "bestellung_id": str(uuid.uuid4()),
            "laufende_nr": uuid.uuid4().int % 100000,
            "status": "Offen",
            "bestelldatum": "2026-05-09T10:00:00",
            "benutzer_id": benutzer_id,
        }
        client.post(
            "/bestellungen/",
            json={"bestellung": bestellung, "positionen": []},
            headers={"Authorization": f"Bearer {admin_token}"},
        )

        antwort = client.patch(
            f"/bestellungen/{bestellung['bestellung_id']}/status",
            params={"neuer_status": "In Bearbeitung"},
            headers={"Authorization": f"Bearer {auth_token}"},
        )
        assert antwort.status_code == 403
        assert antwort.json()["detail"] == "Keine Berechtigung"

    def test_kunde_darf_kein_bestellstatus_filtern(
        self, auth_token: str
    ) -> None:
        """Kunde kann Bestellungen nach Status nicht aufrufen - erwartet HTTP 403."""
        antwort = client.get(
            "/bestellungen/status/Offen",
            headers={"Authorization": f"Bearer {auth_token}"},
        )
        assert antwort.status_code == 403
        assert antwort.json()["detail"] == "Keine Berechtigung"

    def test_kunde_darf_keine_kunden_abrufen(
        self, auth_token: str, benutzer_id: str
    ) -> None:
        """Kunde kann Bestellungen eines anderen Benutzers nicht aufrufen - erwartet HTTP 403."""
        antwort = client.get(
            f"/bestellungen/benutzer/{benutzer_id}",
            headers={"Authorization": f"Bearer {auth_token}"},
        )
        assert antwort.status_code == 403
        assert antwort.json()["detail"] == "Keine Berechtigung"


class TestAdminDarfAlles:
    """Tests: Admin kann alle Admin-Routen aufrufen."""

    def test_admin_darf_alle_bestellungen_sehen(self, admin_token: str) -> None:
        """Admin kann alle Bestellungen aufrufen - erwartet HTTP 200."""
        antwort = client.get(
            "/bestellungen/",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_admin_darf_status_andern(
        self, admin_token: str, produkt_id: str, zustand_id: str, kategorie_id: str
    ) -> None:
        """Admin kann Bestellstatus ändern - erwartet HTTP 200."""
        # Bestellung im neuen Frontend-Format erstellen
        antwort = client.post(
            "/bestellungen/",
            json={
                "bestellpositionen": [
                    {
                        "produkt_id": produkt_id,
                        "menge": 1,
                        "preis": "9.99",
                    }
                ],
                "gesamtpreis": 9.99,
            },
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 201, f"Bestellung konnte nicht erstellt werden: {antwort.text}"
        bestell_data = antwort.json()
        bestellung_id = bestell_data["bestellung_id"]

        # Status ändern
        antwort = client.patch(
            f"/bestellungen/{bestellung_id}/status",
            params={"neuer_status": "In Bearbeitung"},
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 200
        assert antwort.json()["status"] == "In Bearbeitung"

    def test_admin_darf_bestellungen_nach_status_sehen(
        self, admin_token: str
    ) -> None:
        """Admin kann Bestellungen nach Status filtern - erwartet HTTP 200."""
        antwort = client.get(
            "/bestellungen/status/Offen",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)

    def test_admin_darf_kunden_bestellungen_sehen(
        self, admin_token: str, benutzer_id: str
    ) -> None:
        """Admin kann Bestellungen eines Kunden aufrufen - erwartet HTTP 200."""
        antwort = client.get(
            f"/bestellungen/benutzer/{benutzer_id}",
            headers={"Authorization": f"Bearer {admin_token}"},
        )
        assert antwort.status_code == 200
        assert isinstance(antwort.json(), list)
