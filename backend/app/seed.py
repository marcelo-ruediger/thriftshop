"""
Demo-Daten - Katalog, Demo-Konten und einige Beispielbestellungen.

Wird beim ersten Start automatisch eingespielt (siehe app.main), damit der Shop
sofort benutzbar ist. Manuell: `python -m app.seed` (nur in eine leere Datenbank).
"""

import os
import random
import sqlite3
from datetime import timedelta
from decimal import Decimal
from uuid import NAMESPACE_URL, UUID, uuid4, uuid5

from app.core.config import einstellungen
from app.core.datenbank import jetzt, schema_erstellen, verbinden
from app.core.sicherheit import (
    ROLLE_ADMIN,
    ROLLE_KUNDE,
    ROLLE_MITARBEITER,
    passwort_hashen,
)
from app.dao.benutzer_dao import BenutzerDAO
from app.dao.kategorie_dao import KategorieDAO
from app.dao.produkt_dao import ProduktDAO
from app.dao.zustand_dao import ZustandDAO
from app.models import Benutzer, Kategorie, Produkt, Zustand
from app.schemas import BestellungAnfrage, PositionAnfrage
from app.services.bestellservice import Bestellservice
from app.services.demo import DEMO_EMAILS
from app.services.slug import slug_erzeugen

# (Vorname, Nachname, E-Mail, Passwort, Rolle)
DEMO_KONTEN = [
    ("Alex", "Admin", "admin@example.com", "admin1234", ROLLE_ADMIN),
    ("Mira", "Mitarbeiterin", "team@example.com", "team1234", ROLLE_MITARBEITER),
    ("Lena", "Sommer", "kunde@example.com", "kunde1234", ROLLE_KUNDE),
    ("Jonas", "Weber", "jonas@example.com", "jonas1234", ROLLE_KUNDE),
]
assert {konto[2] for konto in DEMO_KONTEN} == DEMO_EMAILS

ZUSTAENDE = [
    ("Neu mit Etikett", "Ungetragen bzw. unbenutzt, teilweise noch originalverpackt."),
    ("Sehr gut", "Kaum getragen oder benutzt, keine sichtbaren Mängel."),
    ("Gut", "Leichte Gebrauchsspuren, voll funktionsfähig und gepflegt."),
    ("Mit Charakter", "Deutliche Gebrauchsspuren und Patina – genau das macht den Charme aus."),
]

# (Bezeichnung, Kategorierabatt in %)
KATEGORIEN = [
    ("Damenmode", 0),
    ("Herrenmode", 0),
    ("Schuhe", 10),
    ("Accessoires", 0),
    ("Elektronik & Musik", 0),
    ("Möbel & Wohnen", 0),
]

# (Bild, Bezeichnung, Kategorie, Zustand, Preis, Lagerbestand, Produktrabatt in %, Beschreibung)
PRODUKTE = [
    ("001_gel1", "Haarpomade Classic im Glas", "Accessoires", "Neu mit Etikett", "6.50", 8, 0,
     "Feste Pomade für klassische Scheitel und Tollen. Originalverschlossen, 100 ml im Glastiegel."),
    ("002_gel2", "Styling-Creme Retro Edition", "Accessoires", "Neu mit Etikett", "5.90", 6, 0,
     "Leichte Styling-Creme mit mattem Finish in der Metalldose. Ungeöffnet aus einer Geschäftsauflösung."),
    ("003_hose1", "Straight-Jeans Anthrazit Washed", "Herrenmode", "Gut", "24.00", 1, 0,
     "Gerade geschnittene Jeans in verwaschenem Anthrazit, Größe W32/L32. Kräftiger Denim, keine Löcher."),
    ("004_hose2", "Relaxed-Jeans Grau Stonewashed", "Herrenmode", "Sehr gut", "27.00", 1, 0,
     "Locker sitzende Jeans mit Stonewash-Effekt, Größe W34/L32. Kaum getragen."),
    ("005_jacke1", "Lederjacke Cognac mit Hemdkragen", "Herrenmode", "Mit Charakter", "89.00", 1, 0,
     "Echtleder-Blouson in warmem Cognac mit Brusttasche und Reißverschluss, Größe L. Schöne Patina an Kragen und Bund."),
    ("006_jacke2", "Lederjacke Dunkelbraun Used-Look", "Herrenmode", "Gut", "79.00", 1, 15,
     "Robuste Lederjacke mit Druckknöpfen und gefüttertem Kragen, Größe M. Weiches, eingetragenes Leder."),
    ("007_radio1", "Kofferradio Rotbraun 60er Jahre", "Elektronik & Musik", "Gut", "65.00", 1, 0,
     "Tragbares Radio mit Stoffbespannung und Messingzierleisten. UKW und Mittelwelle, Netzbetrieb geprüft."),
    ("008_radio2", "Transistorradio mit Tragebügel", "Elektronik & Musik", "Mit Charakter", "48.00", 1, 0,
     "Kompaktes Transistorradio im Holzgehäuse mit Metallgitter. Spielt, der Lautstärkeregler kratzt leicht."),
    ("009_tshirts2", "T-Shirt-Set Bunt (6 Stück)", "Herrenmode", "Gut", "22.00", 3, 0,
     "Sechs Baumwoll-T-Shirts in Blau, Grün, Orange und Flieder, Größe M. Teilweise mit Vintage-Print."),
    ("010_tshits1", "T-Shirt-Set Gedeckte Farben (4 Stück)", "Herrenmode", "Sehr gut", "18.00", 4, 0,
     "Vier T-Shirts in Grau, Hellblau, Beige und Navy, Größe L. Formstabil und ohne Flecken."),
    ("011_jacke3", "Jeansjacke Grau Washed", "Damenmode", "Sehr gut", "34.00", 1, 0,
     "Taillierte Jeansjacke mit Brusttaschen in verwaschenem Grau, Größe 38. Alle Knöpfe vorhanden."),
    ("012_tasche1", "Bügeltasche Leder Dunkelbraun", "Accessoires", "Mit Charakter", "42.00", 1, 0,
     "Weiche Lederhandtasche mit Kussverschluss und kurzem Henkel. Innenfutter sauber, außen mit Patina."),
    ("013_tasche2", "Henkeltasche Leder Cognac", "Accessoires", "Gut", "45.00", 1, 0,
     "Geräumige Henkeltasche aus Glattleder mit Messingbügel. Passt Geldbörse, Buch und Schirm."),
    ("014_tasche3", "Arzttasche Leder Kastanie", "Accessoires", "Gut", "58.00", 1, 20,
     "Klassische Arzttasche mit festem Rahmen und Schließe. Stabiler Henkel, innen ein Steckfach."),
    ("015_geldbeutel1", "Bügelbörse Leder Dunkelbraun", "Accessoires", "Mit Charakter", "14.00", 2, 0,
     "Kleine Geldbörse mit Kussverschluss aus genarbtem Leder. Ideal für Münzen und Karten."),
    ("016_geldbeutel2", "Bügelbörse Leder Cognac", "Accessoires", "Gut", "16.00", 2, 0,
     "Bügelbörse aus glattem Leder mit goldfarbenem Rahmen. Verschluss schließt sauber."),
    ("017_pullover1", "Strickpullover Schokobraun", "Herrenmode", "Sehr gut", "26.00", 1, 0,
     "Rundhals-Pullover aus Wollmischung in Schokobraun, Größe L. Kein Pilling, frisch gewaschen."),
    ("018_pullover2", "Strickpullover Graumeliert", "Herrenmode", "Gut", "22.00", 1, 0,
     "Lässiger Pullover in meliertem Grau, Größe M. Weich, mit gerippten Bündchen."),
    ("019_pullover3", "Strickpullover Camel", "Damenmode", "Sehr gut", "28.00", 1, 0,
     "Feinstrick-Pullover in Camel, Größe 40. Leicht und angenehm auf der Haut."),
    ("020_socken1", "Wollsocken Natur", "Accessoires", "Neu mit Etikett", "7.50", 10, 0,
     "Dicke Wollsocken in Naturbeige, Größe 39–42. Ungetragen, warm und kuschelig."),
    ("021_socken2", "Ringelsocken Bunt (4er-Set)", "Accessoires", "Neu mit Etikett", "12.00", 5, 0,
     "Vier Paar farbenfrohe Stricksocken mit Muster, Größe 36–40. Neu und ungetragen."),
    ("022_socken3", "Ringelsocken Regenbogen", "Accessoires", "Neu mit Etikett", "6.00", 7, 0,
     "Ein Paar knallbunte Ringelsocken, Größe 39–42. Macht jeden Montag besser."),
    ("023_pyjamahose1", "Pyjamahose Blumenmuster Bunt", "Damenmode", "Sehr gut", "15.00", 1, 0,
     "Leichte Hose mit großem Blumenprint und Kordelzug, Größe M. Auch als Sommerhose tragbar."),
    ("024_pyjamahose2", "Pyjamahose Rosenmuster Blau", "Damenmode", "Gut", "13.00", 1, 0,
     "Weite Hose mit Rosenmuster auf blauem Grund, Größe L. Elastischer Bund."),
    ("025_rock1", "Midirock Taupe", "Damenmode", "Sehr gut", "21.00", 1, 0,
     "Schwingender Midirock in Taupe mit Kellerfalten, Größe 38. Seitlicher Reißverschluss."),
    ("026_rock2", "Faltenrock Grau", "Damenmode", "Gut", "19.00", 1, 0,
     "Klassischer Faltenrock in Mittelgrau, Größe 36. Fällt knapp unters Knie."),
    ("027_rock3", "A-Linien-Rock Rot", "Damenmode", "Sehr gut", "23.00", 1, 0,
     "Leuchtend roter Rock in A-Linie mit hoher Taille, Größe 38. Stoff ohne Verfärbungen."),
    ("028_kleid1", "Sommerkleid Blumenmuster", "Damenmode", "Sehr gut", "32.00", 1, 0,
     "Ärmelloses Kleid mit Blumenprint in Grau und Rosé, Größe 36. Tailliert, mit schwingendem Rock."),
    ("029_kleid2", "Trägerkleid Anthrazit", "Damenmode", "Gut", "29.00", 1, 0,
     "Schlichtes Kleid in Anthrazit mit V-Ausschnitt, Größe 38. Ein Klassiker fürs Büro."),
    ("030_kleid3", "Etuikleid Royalblau", "Damenmode", "Sehr gut", "36.00", 1, 0,
     "Ärmelloses Kleid in kräftigem Royalblau, Größe 38. Verdeckter Reißverschluss am Rücken."),
    ("031_kleid4", "Kleid Royalblau mit V-Ausschnitt", "Damenmode", "Gut", "33.00", 1, 25,
     "Knielanges Kleid mit kurzen Ärmeln und V-Ausschnitt, Größe 40. Kleine Naht am Saum nachgenäht."),
    ("032_kleid5", "Kleid Rot mit Herzausschnitt", "Damenmode", "Sehr gut", "38.00", 1, 0,
     "Rotes Kleid mit kurzen Ärmeln und Herzausschnitt, Größe 36. Im Stil der 50er Jahre."),
    ("033_kleid6", "Cocktailkleid Rot", "Damenmode", "Neu mit Etikett", "44.00", 1, 0,
     "Ärmelloses Cocktailkleid in Signalrot, Größe 38. Ungetragen, mit Etikett."),
    ("034_boots1", "Lederstiefel Braun Western", "Schuhe", "Mit Charakter", "54.00", 1, 0,
     "Halbhohe Lederstiefel mit Blockabsatz und seitlichem Reißverschluss, Größe 39. Sohle neu besohlt."),
    ("035_boots2", "Stiefel Schwarz Kniehoch", "Schuhe", "Sehr gut", "59.00", 1, 0,
     "Kniehohe Stiefel aus Glattleder mit moderatem Absatz, Größe 38. Kaum Laufspuren."),
    ("036_boots3", "Schnürboots Bordeaux", "Schuhe", "Gut", "49.00", 1, 0,
     "Robuste Schnürstiefel in Bordeaux mit Profilsohle, Größe 43. Leder frisch gepflegt."),
    ("037_boots4", "Schnürboots Dunkelbraun", "Schuhe", "Mit Charakter", "45.00", 1, 0,
     "Knöchelhohe Arbeitsstiefel in Dunkelbraun, Größe 42. Eingelaufen und bequem."),
    ("038_sneakers1", "Sneaker Weiß", "Schuhe", "Sehr gut", "32.00", 2, 0,
     "Weiße Sneaker mit dicker Sohle, Größe 40. Gereinigt, mit neuen Schnürsenkeln."),
    ("039_sneakers2", "Sneaker Hellgrau", "Schuhe", "Gut", "28.00", 1, 0,
     "Leichte Sneaker in Hellgrau mit perforiertem Obermaterial, Größe 41."),
    ("040_boots5", "Stiefeletten Schwarz Flach", "Schuhe", "Sehr gut", "39.00", 1, 0,
     "Schlichte Stiefeletten aus schwarzem Leder mit flachem Absatz, Größe 38."),
    ("041_boots6", "Stiefeletten Schwarz Blockabsatz", "Schuhe", "Gut", "42.00", 1, 0,
     "Stiefeletten mit 6 cm Blockabsatz und Reißverschluss innen, Größe 39."),
    ("042_boots7", "Stiefeletten Schwarz Klassisch", "Schuhe", "Gut", "37.00", 0, 0,
     "Zeitlose Stiefeletten mit kleinem Absatz, Größe 37. Absätze neu gemacht."),
    ("043_spielcontroller", "Gamecontroller Rot-Schwarz", "Elektronik & Musik", "Gut", "19.00", 2, 0,
     "Kabelloser Controller mit zwei Analogsticks. Getestet, alle Tasten reagieren sauber."),
    ("044_videospiel", "Gaming-Set mit Monitor und Arcade-Pad", "Elektronik & Musik", "Gut", "120.00", 1, 0,
     "24-Zoll-Monitor mit Arcade-Controller und Anschlusskabeln. Ideal für Retro-Spieleabende."),
    ("045_gitarre1", "Westerngitarre mit Cutaway", "Elektronik & Musik", "Sehr gut", "135.00", 1, 0,
     "Elektroakustische Westerngitarre mit Tonabnehmer und Cutaway. Neu besaitet und gestimmt."),
    ("046_gitarre2", "Akustikgitarre Natur", "Elektronik & Musik", "Gut", "95.00", 1, 10,
     "Akustikgitarre mit Fichtendecke in Naturoptik. Kleine Lackspuren an der Zarge, klingt warm."),
    ("047_tisch1", "Beistelltisch Eiche klein", "Möbel & Wohnen", "Gut", "35.00", 1, 0,
     "Kleiner Beistelltisch aus Eiche mit Schublade, 40 × 40 × 45 cm. Stabil verleimt."),
    ("048_tisch2", "Nachttisch Massivholz", "Möbel & Wohnen", "Mit Charakter", "55.00", 1, 0,
     "Nachttisch aus Massivholz mit offenem Fach und Schublade, 50 × 40 × 60 cm. Oberfläche geölt."),
    ("049_buerostuhl1", "Chefsessel Leder Cognac", "Möbel & Wohnen", "Mit Charakter", "140.00", 1, 0,
     "Drehstuhl mit Lederbezug, Holzarmlehnen und Rollen. Höhenverstellung funktioniert, Leder mit Patina."),
    ("050_buerostuhl2", "Chefsessel Leder Dunkelbraun", "Möbel & Wohnen", "Gut", "160.00", 1, 0,
     "Schwerer Bürosessel mit Ziernägeln und Mahagoni-Gestell. Sitzpolster fest, Rollen laufen leise."),
]


def feste_id(art: str, schluessel: str) -> UUID:
    """Immer dieselbe UUID für denselben Demo-Datensatz.

    So bleiben Produkt-IDs gleich, wenn die Datenbank neu aufgebaut wird (z.B. bei
    jedem Neustart auf einem kostenlosen Hosting-Tarif) - gespeicherte Warenkörbe
    und Links der Besucher funktionieren weiter.
    """
    return uuid5(NAMESPACE_URL, f"thriftshop-koeln/{art}/{schluessel}")


def ist_leer(db: sqlite3.Connection) -> bool:
    """True, wenn noch in keiner der Stammtabellen ein Datensatz steht."""
    return all(
        db.execute(f"SELECT COUNT(*) FROM {tabelle}").fetchone()[0] == 0
        for tabelle in ("benutzer", "produkt", "kategorie", "zustand")
    )


def demo_datenbank_bereitstellen() -> bool:
    """Füllt eine leere Datenbank mit den Demo-Daten - ganz oder gar nicht.

    Die Daten entstehen in einer zweiten Datei, die erst am Ende an die Stelle der
    eigentlichen Datenbank tritt. Wird der Vorgang unterbrochen, bleibt die
    Datenbank leer und der nächste Start versucht es einfach erneut.
    Gibt True zurück, wenn Daten eingespielt wurden.
    """
    ziel = einstellungen.datenbank_pfad
    verbindung = verbinden()
    try:
        if not ist_leer(verbindung):
            return False
    finally:
        verbindung.close()

    entwurf = ziel.with_name(ziel.name + ".seed")
    entwurf.unlink(missing_ok=True)  # Rest eines abgebrochenen Versuchs
    schema_erstellen(entwurf)
    verbindung = verbinden(entwurf)
    try:
        demo_daten_einspielen(verbindung)
    finally:
        verbindung.close()
    os.replace(entwurf, ziel)
    return True


def administrator_sicherstellen(db: sqlite3.Connection) -> bool:
    """Legt den in ADMIN_EMAIL/ADMIN_PASSWORT angegebenen Administrator an, solange
    es noch keinen gibt - der Einstieg für einen Betrieb ohne Demo-Daten.
    Gibt True zurück, wenn ein Konto angelegt oder hochgestuft wurde."""
    dao = BenutzerDAO(db)
    if not einstellungen.admin_email or dao.anzahl_administratoren() > 0:
        return False
    vorhanden = dao.get_nach_email(einstellungen.admin_email)
    if vorhanden:
        vorhanden.rolle = ROLLE_ADMIN
        dao.aktualisieren_stammdaten(vorhanden)
        return True
    if len(einstellungen.admin_passwort) < 8 or len(einstellungen.admin_passwort.encode()) > 72:
        raise ValueError("ADMIN_PASSWORT muss 8 bis 72 Zeichen lang sein")
    dao.erstellen(
        Benutzer(
            benutzer_id=uuid4(),
            vorname="Admin",
            nachname="Thriftshop",
            email=einstellungen.admin_email,
            passwort_hash=passwort_hashen(einstellungen.admin_passwort),
            rolle=ROLLE_ADMIN,
        )
    )
    return True


def demo_daten_einspielen(db: sqlite3.Connection) -> None:
    """Füllt eine leere Datenbank mit Katalog, Demo-Konten und Beispielbestellungen."""
    zustaende, kategorien = {}, {}
    for bezeichnung, beschreibung in ZUSTAENDE:
        zustaende[bezeichnung] = Zustand(
            feste_id("zustand", bezeichnung), bezeichnung, beschreibung
        )
        ZustandDAO(db).erstellen(zustaende[bezeichnung])
    for bezeichnung, rabatt in KATEGORIEN:
        slug = slug_erzeugen(bezeichnung)
        kategorien[bezeichnung] = Kategorie(
            feste_id("kategorie", slug), bezeichnung, slug, Decimal(rabatt)
        )
        KategorieDAO(db).erstellen(kategorien[bezeichnung])

    # Feste Zufallsreihenfolge: der Katalog wirkt gemischt, ist aber bei jedem Start identisch
    eintraege = PRODUKTE.copy()
    random.Random(2026).shuffle(eintraege)
    produkt_dao = ProduktDAO(db)
    produkte: dict[str, Produkt] = {}
    for index, (bild, bezeichnung, kategorie, zustand, preis, bestand, rabatt, info) in enumerate(eintraege):
        slug = slug_erzeugen(bezeichnung)
        produkt = Produkt(
            produkt_id=feste_id("produkt", slug),
            laufende_nr=0,
            bezeichnung=bezeichnung,
            slug=slug,
            produkt_info=info,
            preis=Decimal(preis),
            produkt_rabatt=Decimal(rabatt),
            lagerbestand=bestand,
            zustand_id=zustaende[zustand].zustand_id,
            kategorie_id=kategorien[kategorie].kategorie_id,
            erstellungsdatum=jetzt() - timedelta(days=len(eintraege) - index),
            bildpfad=f"{bild}.webp",
        )
        produkt_dao.erstellen(produkt)
        produkte[bezeichnung] = produkt
    db.commit()

    benutzer: dict[str, Benutzer] = {}
    for vorname, nachname, email, passwort, rolle in DEMO_KONTEN:
        benutzer[email] = Benutzer(
            benutzer_id=uuid4(),
            vorname=vorname,
            nachname=nachname,
            email=email,
            passwort_hash=passwort_hashen(passwort),
            rolle=rolle,
            erstellt_am=jetzt() - timedelta(days=45),
        )
        BenutzerDAO(db).erstellen(benutzer[email])

    # Beispielbestellungen in verschiedenen Status: (Kunde, Artikel, Statusfolge, vor x Tagen, Zahlungsart)
    service = Bestellservice(db)
    bestellungen = [
        ("kunde@example.com", ["Wollsocken Natur", "T-Shirt-Set Gedeckte Farben (4 Stück)"],
         ["In Bearbeitung", "Abgeschlossen"], 21, "Zahlung bei Abholung"),
        ("jonas@example.com", ["Gamecontroller Rot-Schwarz"],
         ["In Bearbeitung", "Abgeschlossen"], 12, "Rechnung"),
        ("jonas@example.com", ["Sneaker Weiß", "Ringelsocken Regenbogen"],
         ["Storniert"], 8, "Zahlung bei Abholung"),
        ("kunde@example.com", ["Bügelbörse Leder Cognac"], ["In Bearbeitung"], 3, "Rechnung"),
        ("jonas@example.com", ["Haarpomade Classic im Glas", "Ringelsocken Bunt (4er-Set)"],
         [], 1, "Zahlung bei Abholung"),
        ("kunde@example.com", ["Bügelbörse Leder Dunkelbraun", "Styling-Creme Retro Edition"],
         [], 0, "Zahlung bei Abholung"),
    ]
    for email, artikel, statusfolge, tage, zahlungsart in bestellungen:
        bestellung = service.bestellen(
            benutzer[email],
            BestellungAnfrage(
                positionen=[
                    PositionAnfrage(produkt_id=produkte[name].produkt_id, menge=1)
                    for name in artikel
                ],
                zahlungsart=zahlungsart,
            ),
        )
        for status in statusfolge:
            bestellung = service.status_aendern(bestellung, status)
        db.execute(
            "UPDATE bestellung SET bestelldatum = ? WHERE bestellung_id = ?",
            (jetzt() - timedelta(days=tage, hours=3), bestellung.bestellung_id),
        )
        db.commit()


if __name__ == "__main__":
    schema_erstellen()
    if demo_datenbank_bereitstellen():
        print(f"Demo-Daten eingespielt: {len(PRODUKTE)} Produkte, {len(DEMO_KONTEN)} Konten.")
    else:
        print("Die Datenbank enthält bereits Daten - nichts geändert.")
