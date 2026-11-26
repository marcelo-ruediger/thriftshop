"""Integrationstests - Bestellen, Lagerbuchung, Stornieren und Statusübergänge."""

import uuid

import pytest


def _bestellen(client, header, *positionen, **felder):
    return client.post(
        "/api/bestellungen",
        headers=header,
        json={
            "positionen": [{"produkt_id": pid, "menge": menge} for pid, menge in positionen],
            **felder,
        },
    )


def _bestand(client, admin, produkt_id) -> int:
    alle = client.get("/api/produkte/alle", headers=admin).json()
    return next(p["lagerbestand"] for p in alle if p["produkt_id"] == produkt_id)


def test_bestellen_erfordert_anmeldung(client, produkt_anlegen):
    produkt = produkt_anlegen()
    assert _bestellen(client, {}, (produkt["produkt_id"], 1)).status_code == 401


def test_bestellung_bucht_preise_serverseitig_und_reduziert_den_bestand(
    client, kunde, admin, produkt_anlegen
):
    jacke = produkt_anlegen(preis="50.00", produkt_rabatt="20", lagerbestand=3)
    socken = produkt_anlegen(preis="5.95", lagerbestand=10)

    antwort = _bestellen(
        client,
        kunde,
        (jacke["produkt_id"], 2),
        (socken["produkt_id"], 1),
        zahlungsart="Rechnung",
        anmerkung="Bitte bis Samstag zurücklegen",
    )
    assert antwort.status_code == 201, antwort.text
    bestellung = antwort.json()

    assert bestellung["status"] == "Offen"
    assert bestellung["bestellnr"].startswith("B")
    assert bestellung["zahlungsart"] == "Rechnung"
    assert bestellung["artikel_anzahl"] == 3
    # 2 x (50,00 - 20 %) + 5,95
    assert bestellung["gesamtpreis"] == 85.95
    assert bestellung["enthaltene_mwst"] == pytest.approx(13.72)

    position = next(p for p in bestellung["positionen"] if p["produkt_id"] == jacke["produkt_id"])
    assert position["einzelpreis_gebucht"] == 50
    assert position["rabatt_angewendet"] == 10
    assert position["steuersatz_gebucht"] == 19
    assert position["bezeichnung"] == jacke["bezeichnung"]

    assert _bestand(client, admin, jacke["produkt_id"]) == 1
    assert _bestand(client, admin, socken["produkt_id"]) == 9


def test_vom_client_gesendete_preise_werden_ignoriert(client, kunde, produkt_anlegen):
    produkt = produkt_anlegen(preis="80.00")
    antwort = client.post(
        "/api/bestellungen",
        headers=kunde,
        json={
            "positionen": [{"produkt_id": produkt["produkt_id"], "menge": 1, "preis": "0.01"}],
            "gesamtpreis": "0.01",
        },
    )
    assert antwort.status_code == 201
    assert antwort.json()["gesamtpreis"] == 80


def test_spaetere_preisaenderung_aendert_die_bestellung_nicht(
    client, kunde, admin, stammdaten, produkt_anlegen
):
    produkt = produkt_anlegen(preis="30.00")
    bestellung = _bestellen(client, kunde, (produkt["produkt_id"], 1)).json()

    client.put(
        f"/api/produkte/{produkt['produkt_id']}",
        headers=admin,
        json={
            "bezeichnung": produkt["bezeichnung"],
            "produkt_info": "teurer",
            "preis": "99.00",
            **stammdaten,
        },
    )
    erneut = client.get(f"/api/bestellungen/{bestellung['bestellung_id']}", headers=kunde).json()
    assert erneut["gesamtpreis"] == 30


def test_mehr_als_der_lagerbestand_wird_abgelehnt(client, kunde, admin, produkt_anlegen):
    vorhanden = produkt_anlegen(lagerbestand=5)
    knapp = produkt_anlegen(lagerbestand=1)

    antwort = _bestellen(client, kunde, (vorhanden["produkt_id"], 1), (knapp["produkt_id"], 2))
    assert antwort.status_code == 409
    assert knapp["bezeichnung"] in antwort.json()["detail"]
    # Atomar: auch der verfügbare Artikel wurde nicht ausgebucht
    assert _bestand(client, admin, vorhanden["produkt_id"]) == 5
    assert _bestand(client, admin, knapp["produkt_id"]) == 1


def test_doppelte_positionen_werden_fuer_die_bestandspruefung_zusammengefasst(
    client, kunde, produkt_anlegen
):
    produkt = produkt_anlegen(lagerbestand=2)
    pid = produkt["produkt_id"]
    assert _bestellen(client, kunde, (pid, 2), (pid, 1)).status_code == 409
    antwort = _bestellen(client, kunde, (pid, 1), (pid, 1))
    assert antwort.status_code == 201
    assert antwort.json()["positionen"][0]["menge"] == 2


def test_deaktivierte_und_unbekannte_produkte_koennen_nicht_bestellt_werden(
    client, kunde, admin, produkt_anlegen
):
    produkt = produkt_anlegen()
    client.delete(f"/api/produkte/{produkt['produkt_id']}", headers=admin)
    assert _bestellen(client, kunde, (produkt["produkt_id"], 1)).status_code == 409
    assert _bestellen(client, kunde, (str(uuid.uuid4()), 1)).status_code == 409


def test_leere_bestellung_und_menge_null_sind_ungueltig(client, kunde, produkt_anlegen):
    produkt = produkt_anlegen()
    assert _bestellen(client, kunde).status_code == 422
    assert _bestellen(client, kunde, (produkt["produkt_id"], 0)).status_code == 422


def test_kunde_sieht_nur_eigene_bestellungen(client, kunde, neuer_kunde, produkt_anlegen):
    produkt = produkt_anlegen()
    bestellung = _bestellen(client, kunde, (produkt["produkt_id"], 1)).json()

    meine = client.get("/api/bestellungen/meine", headers=kunde).json()
    assert [b["bestellung_id"] for b in meine] == [bestellung["bestellung_id"]]

    # `neuer_kunde` liefert im selben Test denselben Benutzer - also einen zweiten registrieren
    fremd = client.post(
        "/api/auth/registrieren",
        json={
            "vorname": "Fremde",
            "nachname": "Person",
            "email": f"fremd-{uuid.uuid4().hex[:10]}@example.com",
            "passwort": "geheim1234",
        },
    ).json()
    fremder_header = {"Authorization": f"Bearer {fremd['access_token']}"}
    assert client.get("/api/bestellungen/meine", headers=fremder_header).json() == []
    pfad = f"/api/bestellungen/{bestellung['bestellung_id']}"
    assert client.get(pfad, headers=fremder_header).status_code == 404
    assert client.patch(f"{pfad}/stornieren", headers=fremder_header).status_code == 404


def test_stornieren_bucht_die_ware_zurueck(client, kunde, admin, produkt_anlegen):
    produkt = produkt_anlegen(lagerbestand=2)
    bestellung = _bestellen(client, kunde, (produkt["produkt_id"], 2)).json()
    assert _bestand(client, admin, produkt["produkt_id"]) == 0

    antwort = client.patch(
        f"/api/bestellungen/{bestellung['bestellung_id']}/stornieren", headers=kunde
    )
    assert antwort.status_code == 200
    assert antwort.json()["status"] == "Storniert"
    assert _bestand(client, admin, produkt["produkt_id"]) == 2

    # Ein zweites Mal geht nicht - und bucht auch nichts doppelt zurück
    erneut = client.patch(
        f"/api/bestellungen/{bestellung['bestellung_id']}/stornieren", headers=kunde
    )
    assert erneut.status_code == 409
    assert _bestand(client, admin, produkt["produkt_id"]) == 2


def test_kunde_kann_nur_offene_bestellungen_stornieren(client, kunde, mitarbeiter, produkt_anlegen):
    produkt = produkt_anlegen()
    bestellung = _bestellen(client, kunde, (produkt["produkt_id"], 1)).json()
    pfad = f"/api/bestellungen/{bestellung['bestellung_id']}"
    client.patch(f"{pfad}/status", headers=mitarbeiter, json={"status": "In Bearbeitung"})

    assert client.patch(f"{pfad}/stornieren", headers=kunde).status_code == 409


def test_statusuebergaenge(client, kunde, mitarbeiter, admin, produkt_anlegen):
    produkt = produkt_anlegen(lagerbestand=1)
    bestellung = _bestellen(client, kunde, (produkt["produkt_id"], 1)).json()
    pfad = f"/api/bestellungen/{bestellung['bestellung_id']}/status"

    def wechsel(status):
        return client.patch(pfad, headers=mitarbeiter, json={"status": status})

    assert wechsel("Abgeschlossen").status_code == 422  # Schritt übersprungen
    assert wechsel("In Bearbeitung").status_code == 200
    assert wechsel("Offen").status_code == 422  # kein Zurück
    assert wechsel("Abgeschlossen").status_code == 200
    assert _bestand(client, admin, produkt["produkt_id"]) == 0

    assert wechsel("Erstattet").json()["status"] == "Erstattet"  # Rückgabe
    assert _bestand(client, admin, produkt["produkt_id"]) == 1
    assert wechsel("Offen").status_code == 422  # Endzustand
    assert wechsel("Unsinn").status_code == 422


def test_erstattung_nach_storno_bucht_nicht_doppelt_zurueck(
    client, kunde, mitarbeiter, admin, produkt_anlegen
):
    produkt = produkt_anlegen(lagerbestand=1)
    bestellung = _bestellen(client, kunde, (produkt["produkt_id"], 1)).json()
    pfad = f"/api/bestellungen/{bestellung['bestellung_id']}/status"

    client.patch(pfad, headers=mitarbeiter, json={"status": "Storniert"})
    client.patch(pfad, headers=mitarbeiter, json={"status": "Erstattet"})
    assert _bestand(client, admin, produkt["produkt_id"]) == 1


def test_bestellverwaltung_listet_und_filtert(client, kunde, mitarbeiter, produkt_anlegen):
    produkt = produkt_anlegen()
    bestellung = _bestellen(client, kunde, (produkt["produkt_id"], 1)).json()

    alle = client.get("/api/bestellungen", headers=mitarbeiter).json()
    eintrag = next(b for b in alle if b["bestellung_id"] == bestellung["bestellung_id"])
    assert eintrag["kunde_name"] == "Test Kundin"
    assert eintrag["kunde_email"].endswith("@example.com")

    offene = client.get("/api/bestellungen?status=Offen", headers=mitarbeiter).json()
    assert offene and all(b["status"] == "Offen" for b in offene)
    assert client.get("/api/bestellungen?status=Unsinn", headers=mitarbeiter).status_code == 422


def test_statistik(client, kunde, admin, produkt_anlegen):
    vorher = client.get("/api/bestellungen/statistik", headers=admin).json()
    produkt = produkt_anlegen(preis="10.00", lagerbestand=1)
    _bestellen(client, kunde, (produkt["produkt_id"], 1))
    nachher = client.get("/api/bestellungen/statistik", headers=admin).json()

    assert nachher["umsatz"] == pytest.approx(vorher["umsatz"] + 10)
    assert nachher["bestellungen_gesamt"] == vorher["bestellungen_gesamt"] + 1
    assert nachher["bestellungen_je_status"]["Offen"] == vorher["bestellungen_je_status"]["Offen"] + 1
    assert nachher["produkte_ausverkauft"] == vorher["produkte_ausverkauft"] + 1


def test_frontend_fallback_liefert_kein_html_fuer_unbekannte_api_pfade(client):
    assert client.get("/api/gibt-es-nicht").status_code == 404
    assert client.get("/api/health").json() == {"status": "ok"}
