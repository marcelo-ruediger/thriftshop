"""Integrationstests - Produkte, Kategorien, Zustände und die Rollenprüfung."""

import uuid

# 1x1-Pixel-PNG
PNG = (
    b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00"
    b"\x1f\x15\xc4\x89\x00\x00\x00\rIDATx\x9cc\xf8\xff\xff?\x00\x05\xfe\x02\xfe\xa75\x81\x84"
    b"\x00\x00\x00\x00IEND\xaeB`\x82"
)


# --- Öffentlicher Katalog -----------------------------------------------------


def test_katalog_ist_oeffentlich_und_enthaelt_die_demo_daten(client):
    antwort = client.get("/api/produkte")
    assert antwort.status_code == 200
    produkte = antwort.json()
    assert len(produkte) >= 50
    assert all(p["produkt_aktiv"] for p in produkte)


def test_produkt_per_slug_und_id(client):
    produkt = client.get("/api/produkte").json()[0]
    assert client.get(f"/api/produkte/slug/{produkt['slug']}").json() == produkt
    assert client.get(f"/api/produkte/{produkt['produkt_id']}").json() == produkt
    assert client.get(f"/api/produkte/{uuid.uuid4()}").status_code == 404
    assert client.get("/api/produkte/slug/gibt-es-nicht").status_code == 404


def test_endpreis_beruecksichtigt_den_rabatt(client, produkt_anlegen):
    produkt = produkt_anlegen(preis="50.00", produkt_rabatt="20")
    assert produkt["rabatt_prozent"] == 20
    assert produkt["endpreis"] == 40


def test_kategorierabatt_gilt_wenn_er_hoeher_ist(client, admin, mitarbeiter, produkt_anlegen):
    kategorie = client.post(
        "/api/kategorien",
        headers=mitarbeiter,
        json={"bezeichnung": f"Sale {uuid.uuid4().hex[:6]}", "kategorie_rabatt": "30"},
    ).json()
    produkt = produkt_anlegen(
        preis="10.00", produkt_rabatt="5", kategorie_id=kategorie["kategorie_id"]
    )
    assert produkt["rabatt_prozent"] == 30
    assert produkt["endpreis"] == 7


def test_produktbilder_werden_ausgeliefert(client):
    produkt = next(p for p in client.get("/api/produkte").json() if p["bildpfad"])
    antwort = client.get(f"/bilder/{produkt['bildpfad']}")
    assert antwort.status_code == 200
    assert antwort.headers["content-type"] == "image/webp"
    assert client.get("/bilder/gibt-es-nicht.webp").status_code == 404
    assert client.get("/bilder/..%2Fapp%2Fmain.py").status_code == 404


def test_produktbilder_haben_den_bildtyp_auch_ohne_mime_tabelle(client, monkeypatch):
    """Im schlanken Docker-Image kennt das System keine Dateitypen. Das Bild muss trotzdem
    als Bild ausgeliefert werden, nicht als beliebige Binärdatei."""
    monkeypatch.setattr("starlette.responses.guess_type", lambda *_a, **_k: (None, None))
    produkt = next(p for p in client.get("/api/produkte").json() if p["bildpfad"])
    antwort = client.get(f"/bilder/{produkt['bildpfad']}")
    assert antwort.headers["content-type"] == "image/webp"


def test_produktbilder_werden_beim_server_nachgefragt(client):
    """Ein unter gleichem Namen ausgetauschtes Foto muss sofort sichtbar sein: Der Browser
    fragt jedes Mal nach und bekommt für ein unverändertes Bild nur eine leere 304-Antwort."""
    produkt = next(p for p in client.get("/api/produkte").json() if p["bildpfad"])
    pfad = f"/bilder/{produkt['bildpfad']}"
    antwort = client.get(pfad)
    assert antwort.headers["cache-control"] == "no-cache"

    unveraendert = client.get(pfad, headers={"If-None-Match": antwort.headers["etag"]})
    assert unveraendert.status_code == 304
    assert unveraendert.content == b""

    veraltet = client.get(pfad, headers={"If-None-Match": '"anderes-bild"'})
    assert veraltet.status_code == 200
    assert veraltet.content == antwort.content


# --- Produktverwaltung --------------------------------------------------------


def test_produkt_anlegen_vergibt_nummer_und_slug(client, produkt_anlegen):
    erstes = produkt_anlegen(bezeichnung="Grüner Wollmantel Größe M")
    zweites = produkt_anlegen(bezeichnung="Grüner Wollmantel Größe M")
    assert erstes["slug"] == "gruener-wollmantel-groesse-m"
    assert zweites["slug"] == "gruener-wollmantel-groesse-m-2"
    assert erstes["produktnr"].startswith("P")
    assert erstes["produktnr"] != zweites["produktnr"]


def test_produkt_bearbeiten(client, admin, stammdaten, produkt_anlegen):
    produkt = produkt_anlegen()
    antwort = client.put(
        f"/api/produkte/{produkt['produkt_id']}",
        headers=admin,
        json={
            "bezeichnung": produkt["bezeichnung"],
            "produkt_info": "Neue Beschreibung",
            "preis": "12.50",
            "lagerbestand": 7,
            **stammdaten,
        },
    )
    assert antwort.status_code == 200
    assert antwort.json()["preis"] == 12.5
    assert antwort.json()["lagerbestand"] == 7
    assert antwort.json()["slug"] == produkt["slug"]  # unverändert, da Name gleich


def test_ungueltige_produktdaten_werden_abgelehnt(client, admin, stammdaten):
    basis = {"bezeichnung": "Kaputt", "produkt_info": "x", **stammdaten}
    for felder in (
        {"preis": "-1"},
        {"preis": "10", "lagerbestand": -1},
        {"preis": "10", "produkt_rabatt": "100"},
        {"preis": "10", "kategorie_id": str(uuid.uuid4())},
    ):
        antwort = client.post("/api/produkte", headers=admin, json={**basis, **felder})
        assert antwort.status_code == 422, felder


def test_deaktiviertes_produkt_verschwindet_aus_dem_katalog(client, admin, produkt_anlegen):
    produkt = produkt_anlegen()
    assert client.delete(f"/api/produkte/{produkt['produkt_id']}", headers=admin).status_code == 204

    assert client.get(f"/api/produkte/{produkt['produkt_id']}").status_code == 404
    oeffentlich = {p["produkt_id"] for p in client.get("/api/produkte").json()}
    verwaltung = {p["produkt_id"] for p in client.get("/api/produkte/alle", headers=admin).json()}
    assert produkt["produkt_id"] not in oeffentlich
    assert produkt["produkt_id"] in verwaltung


def test_bearbeiten_und_ausblenden_ueberschreiben_keinen_verkauften_bestand(
    client, admin, kunde, stammdaten, produkt_anlegen
):
    """Die Verwaltung arbeitet mit einem älteren Stand der Produktliste. Wird in der
    Zwischenzeit etwas verkauft, darf das Speichern den Bestand nicht zurücksetzen."""
    produkt = produkt_anlegen(lagerbestand=1)
    pid = produkt["produkt_id"]
    kauf = client.post(
        "/api/bestellungen", headers=kunde, json={"positionen": [{"produkt_id": pid, "menge": 1}]}
    )
    assert kauf.status_code == 201

    # Beschreibung ändern, ohne den Bestand mitzusenden
    geaendert = client.put(
        f"/api/produkte/{pid}",
        headers=admin,
        json={
            "bezeichnung": produkt["bezeichnung"],
            "produkt_info": "Tippfehler korrigiert",
            "preis": "20.00",
            **stammdaten,
        },
    )
    assert geaendert.json()["lagerbestand"] == 0

    # Aus dem Shop nehmen und wieder einstellen
    aus = client.patch(
        f"/api/produkte/{pid}/sichtbarkeit", headers=admin, json={"produkt_aktiv": False}
    )
    assert aus.json()["produkt_aktiv"] is False
    assert client.get(f"/api/produkte/{pid}").status_code == 404
    an = client.patch(
        f"/api/produkte/{pid}/sichtbarkeit", headers=admin, json={"produkt_aktiv": True}
    )
    assert an.json()["produkt_aktiv"] is True
    assert an.json()["lagerbestand"] == 0
    assert an.json()["produkt_info"] == "Tippfehler korrigiert"

    unbekannt = client.patch(
        f"/api/produkte/{uuid.uuid4()}/sichtbarkeit", headers=admin, json={"produkt_aktiv": True}
    )
    assert unbekannt.status_code == 404


def test_bild_hochladen(client, admin):
    antwort = client.post(
        "/api/produkte/bild", headers=admin, files={"datei": ("foto.png", PNG, "image/png")}
    )
    assert antwort.status_code == 201
    bildpfad = antwort.json()["bildpfad"]
    assert bildpfad.startswith("upload_") and bildpfad.endswith(".png")
    assert client.get(f"/bilder/{bildpfad}").content == PNG


def test_bild_upload_lehnt_andere_dateitypen_ab(client, admin):
    antwort = client.post(
        "/api/produkte/bild",
        headers=admin,
        files={"datei": ("skript.html", b"<script>", "text/html")},
    )
    assert antwort.status_code == 415


# --- Rollen -------------------------------------------------------------------


def test_verwaltung_erfordert_anmeldung_und_rolle(client, kunde, stammdaten):
    produkt = client.get("/api/produkte").json()[0]
    neues_produkt = {"bezeichnung": "X-Artikel", "produkt_info": "x", "preis": "1", **stammdaten}
    aufrufe = [
        ("GET", "/api/produkte/alle", None),
        ("POST", "/api/produkte", neues_produkt),
        ("PUT", f"/api/produkte/{produkt['produkt_id']}", neues_produkt),
        ("DELETE", f"/api/produkte/{produkt['produkt_id']}", None),
        ("PATCH", f"/api/produkte/{produkt['produkt_id']}/sichtbarkeit", {"produkt_aktiv": False}),
        ("POST", "/api/kategorien", {"bezeichnung": "X"}),
        ("DELETE", f"/api/kategorien/{stammdaten['kategorie_id']}", None),
        ("POST", "/api/zustaende", {"bezeichnung": "X", "beschreibung": "x"}),
        ("GET", "/api/bestellungen", None),
        ("GET", "/api/bestellungen/statistik", None),
        ("GET", "/api/benutzer", None),
    ]
    for methode, pfad, daten in aufrufe:
        assert client.request(methode, pfad, json=daten).status_code == 401, pfad
        assert client.request(methode, pfad, json=daten, headers=kunde).status_code == 403, pfad


def test_mitarbeiter_duerfen_produkte_aber_keine_benutzer_verwalten(client, mitarbeiter):
    assert client.get("/api/produkte/alle", headers=mitarbeiter).status_code == 200
    assert client.get("/api/bestellungen", headers=mitarbeiter).status_code == 200
    assert client.get("/api/benutzer", headers=mitarbeiter).status_code == 403


def test_admin_vergibt_rollen(client, admin, neuer_kunde):
    header, benutzer, _ = neuer_kunde
    antwort = client.patch(
        f"/api/benutzer/{benutzer['benutzer_id']}/rolle",
        headers=admin,
        json={"rolle": "Mitarbeiter"},
    )
    assert antwort.status_code == 200
    assert antwort.json()["rolle"] == "Mitarbeiter"
    # Die neue Rolle gilt sofort - sie wird bei jeder Anfrage aus der Datenbank gelesen
    assert client.get("/api/produkte/alle", headers=header).status_code == 200


def test_admin_kann_die_eigene_rolle_nicht_aendern(client, admin):
    ich = client.get("/api/auth/me", headers=admin).json()
    antwort = client.patch(
        f"/api/benutzer/{ich['benutzer_id']}/rolle", headers=admin, json={"rolle": "Kunde"}
    )
    assert antwort.status_code == 400


# --- Kategorien & Zustände ------------------------------------------------------


def test_kategorie_anlegen_aendern_loeschen(client, mitarbeiter):
    name = f"Bücher {uuid.uuid4().hex[:6]}"
    kategorie = client.post("/api/kategorien", headers=mitarbeiter, json={"bezeichnung": name})
    assert kategorie.status_code == 201
    kategorie_id = kategorie.json()["kategorie_id"]
    assert kategorie.json()["slug"].startswith("buecher-")
    assert kategorie.json()["steuersatz"] == 19

    doppelt = client.post("/api/kategorien", headers=mitarbeiter, json={"bezeichnung": name})
    assert doppelt.status_code == 409

    geaendert = client.put(
        f"/api/kategorien/{kategorie_id}",
        headers=mitarbeiter,
        json={"bezeichnung": name, "steuersatz": "7", "kategorie_rabatt": "5"},
    )
    assert geaendert.json()["steuersatz"] == 7

    assert client.delete(f"/api/kategorien/{kategorie_id}", headers=mitarbeiter).status_code == 204
    assert client.delete(f"/api/kategorien/{kategorie_id}", headers=mitarbeiter).status_code == 404


def test_verwendete_kategorie_und_zustand_koennen_nicht_geloescht_werden(
    client, admin, stammdaten, produkt_anlegen
):
    produkt_anlegen()
    kategorie = client.delete(f"/api/kategorien/{stammdaten['kategorie_id']}", headers=admin)
    zustand = client.delete(f"/api/zustaende/{stammdaten['zustand_id']}", headers=admin)
    assert kategorie.status_code == 409
    assert zustand.status_code == 409


def test_zustand_anlegen_und_aendern(client, admin):
    zustand = client.post(
        "/api/zustaende",
        headers=admin,
        json={"bezeichnung": f"Defekt {uuid.uuid4().hex[:6]}", "beschreibung": "Für Bastler."},
    )
    assert zustand.status_code == 201
    zustand_id = zustand.json()["zustand_id"]
    geaendert = client.put(
        f"/api/zustaende/{zustand_id}",
        headers=admin,
        json={"bezeichnung": zustand.json()["bezeichnung"], "beschreibung": "Nur Ersatzteile."},
    )
    assert geaendert.json()["beschreibung"] == "Nur Ersatzteile."
    assert client.delete(f"/api/zustaende/{zustand_id}", headers=admin).status_code == 204
