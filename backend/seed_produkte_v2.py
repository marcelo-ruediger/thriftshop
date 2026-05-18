"""
Seed-Skript für ThriftShop-Datenbank.
Erstellt Testdaten: Zustände, Kategorien und 50 Produkte mit korrekten Bildernamen.
"""

import mysql.connector
import uuid
import os
from decimal import Decimal
from dotenv import load_dotenv

# Umgebung laden
load_dotenv()


def get_db_connection():
    """Stellt eine Verbindung zur MySQL-Datenbank her."""
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "thriftshop"),
    )


def erstelle_zustaende(cursor):
    """Erstellt oder verwendet vorhandene Zustände."""
    print("\nStelle Zustände bereit...")
    zustaende = [
        ("Neu", "Noch nie benutzt, originalverpackt"),
        ("Wie neu", "Wenig benutzt, kaum sichtbare Spuren"),
        ("Gut", "Gebraucht, aber funktionsfähig"),
        ("Akzeptabel", "Sichtbare Gebrauchsspuren, aber voll funktionsfähig"),
    ]

    zustand_ids = {}
    for bezeichnung, beschreibung in zustaende:
        cursor.execute("SELECT zustand_id FROM zustand WHERE bezeichnung = %s", (bezeichnung,))
        row = cursor.fetchone()
        if row:
            zustand_id = row[0]
            print(f"  Zustand '{bezeichnung}' vorhanden (ID: {zustand_id})")
        else:
            zustand_id = str(uuid.uuid4())
            cursor.execute(
                "INSERT INTO zustand (zustand_id, bezeichnung, beschreibung) VALUES (%s, %s, %s)",
                (zustand_id, bezeichnung, beschreibung),
            )
            print(f"  Zustand '{bezeichnung}' erstellt (ID: {zustand_id})")
        zustand_ids[bezeichnung] = zustand_id

    print("Zustände bereitgestellt.\n")
    return zustand_ids


def erstelle_kategorien(cursor):
    """Erstellt oder verwendet vorhandene Kategorien."""
    print("\nStelle Kategorien bereit...")
    kategorien = [
        ("Kleidung Herren", "kleidung-herren"),
        ("Kleidung Damen", "kleidung-damen"),
        ("Schuhe", "schuhe"),
        ("Accessoires", "accessoires"),
        ("Taschen", "taschen"),
        ("Elektronik", "elektronik"),
        ("Möbel", "moebel"),
    ]

    kategorie_ids = {}
    for bezeichnung, slug in kategorien:
        cursor.execute("SELECT kategorie_id FROM kategorie WHERE slug = %s", (slug,))
        row = cursor.fetchone()
        if row:
            kategorie_id = row[0]
            print(f"  Kategorie '{bezeichnung}' vorhanden (ID: {kategorie_id})")
        else:
            kategorie_id = str(uuid.uuid4())
            cursor.execute(
                "INSERT INTO kategorie (kategorie_id, bezeichnung, slug, kategorie_rabatt, steuersatz) VALUES (%s, %s, %s, %s, %s)",
                (kategorie_id, bezeichnung, slug, Decimal("0.00"), Decimal("19.00")),
            )
            print(f"  Kategorie '{bezeichnung}' erstellt (ID: {kategorie_id})")
        kategorie_ids[slug] = kategorie_id

    print("Kategorien bereitgestellt.\n")
    return kategorie_ids


# Produkt-Daten basierend auf den tatsächlichen Dateinamen
PRODUKTE = [
    # Gürtel (001_gel1.png, 002_gel2.png) - Kategorie: Accessoires
    {
        "datei": "001_gel1.png",
        "bezeichnung": "Leder-Gürtel Braun Classic",
        "kategorie_slug": "accessoires",
        "preis": Decimal("12.99"),
        "info": "Klassischer Leder-Gürtel in Braun, Größe M/L",
        "lager": 5,
    },
    {
        "datei": "002_gel2.png",
        "bezeichnung": "Leder-Gürtel Schwarz Elegant",
        "kategorie_slug": "accessoires",
        "preis": Decimal("14.50"),
        "info": "Eleganter Schwarz leder Gürtel mit silberner Schnalle",
        "lager": 3,
    },
    # Hose (003_hose1.png, 004_hose2.png) - Kategorie: Kleidung Herren
    {
        "datei": "003_hose1.png",
        "bezeichnung": "Jeans-Hose Blau Slim Fit",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("22.99"),
        "info": "Slim-Fit Jeans in Blau, Größe 32/34",
        "lager": 4,
    },
    {
        "datei": "004_hose2.png",
        "bezeichnung": "Chino-Hose Beige Classic",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("19.99"),
        "info": "Beigene Chino-Hose, bequem und stylisch, Größe 30/32",
        "lager": 6,
    },
    # Jacke (005_jacke1.png, 006_jacke2.png, 011_jacke3.png) - Kategorie: Kleidung Herren
    {
        "datei": "005_jacke1.png",
        "bezeichnung": "Lederjacke Schwarz Biker",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("49.99"),
        "info": "Klassische Lederjacke im Biker-Stil, Größe L",
        "lager": 2,
    },
    {
        "datei": "006_jacke2.png",
        "bezeichnung": "Winterjacke Grün Parka",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("45.00"),
        "info": "Warme Winterparka in Olivgrün, Größe M/L",
        "lager": 3,
    },
    {
        "datei": "011_jacke3.png",
        "bezeichnung": "Windbreaker Jacke Blau Leicht",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("25.00"),
        "info": "Leichter Windbreaker in Himmelblau, perfekt für Übergangszeiten",
        "lager": 4,
    },
    # Radio (007_radio1.png, 008_radio2.png) - Kategorie: Elektronik
    {
        "datei": "007_radio1.png",
        "bezeichnung": "Kiphörer Radio Vintage Retro",
        "kategorie_slug": "elektronik",
        "preis": Decimal("35.00"),
        "info": "Vintage-Kipper Hörer mit integriertem Radio, guter Zustand",
        "lager": 1,
    },
    {
        "datei": "008_radio2.png",
        "bezeichnung": "Bluetooth Radio Modern Weiß",
        "kategorie_slug": "elektronik",
        "preis": Decimal("28.99"),
        "info": "Modernes Bluetooth-Radio in Weiß, voll funktionsfähig",
        "lager": 2,
    },
    # T-Shirt (009_tshirts2.png, 010_tshits1.png) - Kategorie: Kleidung Herren
    {
        "datei": "009_tshirts2.png",
        "bezeichnung": "T-Shirt Graphic Print Grau",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("12.99"),
        "info": "Graues T-Shirt mit Grafik-Print, Größe L",
        "lager": 8,
    },
    {
        "datei": "010_tshits1.png",
        "bezeichnung": "T-Shirt Basic Schwarz Rundhals",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("8.99"),
        "info": "Klassisches schwarzes Basic-T-Shirt, rundhals, Größe M",
        "lager": 10,
    },
    # Tasche (012_tasche1.png, 013_tasche2.png, 014_tasche3.png) - Kategorie: Taschen
    {
        "datei": "012_tasche1.png",
        "bezeichnung": "Lederhandtasche Braun Elegant",
        "kategorie_slug": "taschen",
        "preis": Decimal("29.99"),
        "info": "Elegante Lederhandtasche in Braun, perfekt für den Alltag",
        "lager": 3,
    },
    {
        "datei": "013_tasche2.png",
        "bezeichnung": "Rucksack Grün Outdoor",
        "kategorie_slug": "taschen",
        "preis": Decimal("24.99"),
        "info": "Robuster Outdoor-Rucksack in Grün, 30L Volumen",
        "lager": 5,
    },
    {
        "datei": "014_tasche3.png",
        "bezeichnung": "Umhängetasche Beige Canvas",
        "kategorie_slug": "taschen",
        "preis": Decimal("18.50"),
        "info": "Lässige Canvas-Umhängetasche in Beige",
        "lager": 4,
    },
    # Geldbeutel (015_geldbeutel1.png, 016_geldbeutel2.png) - Kategorie: Accessoires
    {
        "datei": "015_geldbeutel1.png",
        "bezeichnung": "Geldbeutel Braun Leder Klappet",
        "kategorie_slug": "accessoires",
        "preis": Decimal("9.99"),
        "info": "Klassischer Klapp-Geldbeutel aus Leder, braun",
        "lager": 7,
    },
    {
        "datei": "016_geldbeutel2.png",
        "bezeichnung": "Portmonnaie Schwarz Compact",
        "kategorie_slug": "accessoires",
        "preis": Decimal("7.50"),
        "info": "Kompaktes Portmonnaie in Schwarz, viele Fächer",
        "lager": 6,
    },
    # Pullover (017_pullover1.png, 018_pullover2.png, 019_pullover3.png) - Kategorie: Kleidung Herren
    {
        "datei": "017_pullover1.png",
        "bezeichnung": "Pullover Wolle Naturbraun",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("27.99"),
        "info": "Warmer Wolle-Pullover in Naturbraun, Größe L",
        "lager": 4,
    },
    {
        "datei": "018_pullover2.png",
        "bezeichnung": "Strickpullover Grau Meliert",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("22.00"),
        "info": "Bequemer Strickpullover in Grau Meliert, Größe M",
        "lager": 5,
    },
    {
        "datei": "019_pullover3.png",
        "bezeichnung": "Kapuzenpullover Schwarz Hoodie",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("24.99"),
        "info": "Skateboard Kapuzenpullover in Schwarz, oversized",
        "lager": 6,
    },
    # Socken (020_socken1.png, 021_socken2.png, 022_socken3.png) - Kategorie: Kleidung Herren
    {
        "datei": "020_socken1.png",
        "bezeichnung": "Socken White Sport 3er-Pack",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("5.99"),
        "info": "3er-Pack weiße Sportsocken, Größe 39-42",
        "lager": 15,
    },
    {
        "datei": "021_socken2.png",
        "bezeichnung": "Socken Schwarz Anzug 5er-Pack",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("7.99"),
        "info": "5er-Pack schwarze Anzugsocken, Größe 40-44",
        "lager": 12,
    },
    {
        "datei": "022_socken3.png",
        "bezeichnung": "Wollsocken Gemustert Winter",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("6.50"),
        "info": "Gemusterte Wollsocken für den Winter, Größe 38-42",
        "lager": 10,
    },
    # Pyjamahose (023_pyjamahose1.png, 024_pyjamahose2.png) - Kategorie: Kleidung Herren
    {
        "datei": "023_pyjamahose1.png",
        "bezeichnung": "Pyjamahose Blau kariert",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("12.99"),
        "info": "Bequeme Pyjamahose in Blau kariert, Größe L",
        "lager": 8,
    },
    {
        "datei": "024_pyjamahose2.png",
        "bezeichnung": "Pyjamahose Grau Meliert Soft",
        "kategorie_slug": "kleidung-herren",
        "preis": Decimal("10.50"),
        "info": "Weiche Baumwoll-Pyjamahose in Grau Meliert, Größe M",
        "lager": 6,
    },
    # Rock (025_rock1.png, 026_rock2.png, 027_rock3.png) - Kategorie: Kleidung Damen
    {
        "datei": "025_rock1.png",
        "bezeichnung": "Minirock Schwarz Classic",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("15.99"),
        "info": "Klassischer Minirock in Schwarz, Größe 36/38",
        "lager": 4,
    },
    {
        "datei": "026_rock2.png",
        "bezeichnung": "Midirock Blumen gemustert",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("18.50"),
        "info": "Eleganter Midirock mit Blumenmuster, Größe 38/40",
        "lager": 3,
    },
    {
        "datei": "027_rock3.png",
        "bezeichnung": "Jogging Rock Dunkelblau Soft",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("14.00"),
        "info": "Bequemer Jogging-Rock in Dunkelblau, weich und dehnbars",
        "lager": 5,
    },
    # Kleid (028_kleid1.png, 029_kleid2.png, 030_kleid3.png, 031_kleid4.png, 032_kleid5.png, 033_kleid6.png) - Kategorie: Kleidung Damen
    {
        "datei": "028_kleid1.png",
        "bezeichnung": "Sommerkleid Blumen Rosa Kurz",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("28.99"),
        "info": "Leichtes Sommerkleid mit Blumenprint, rosa, Größe 36",
        "lager": 4,
    },
    {
        "datei": "029_kleid2.png",
        "bezeichnung": "Kleid Schwarz Elegant Abend",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("42.00"),
        "info": "Elegantes schwarzes Abendkleid, Länge knielang, Größe 38",
        "lager": 2,
    },
    {
        "datei": "030_kleid3.png",
        "bezeichnung": "Bluse Maxirock Grün Lang",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("25.00"),
        "info": "Bequemer Maxirock in Grün, lang, Größe M",
        "lager": 3,
    },
    {
        "datei": "031_kleid4.png",
        "bezeichnung": "Kleid Blau Streifen Casual",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("22.50"),
        "info": "Lässiges Kleiber mit Streifen-Optik, blau, Größe 34/36",
        "lager": 5,
    },
    {
        "datei": "032_kleid5.png",
        "bezeichnung": "Kleid Rot Cocktail Party",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("35.99"),
        "info": "Auffälliges rotes Cocktailkleid für besondere Anlässe, Größe 38",
        "lager": 2,
    },
    {
        "datei": "033_kleid6.png",
        "bezeichnung": "Kleid Weiß Braut Hochzeit",
        "kategorie_slug": "kleidung-damen",
        "preis": Decimal("45.00"),
        "info": "Elegantes weißes Brautkleid, voll保持t, Größe 36/38",
        "lager": 1,
    },
    # Boots/Schuhe (034_boots1.png through 042_boots7.png) - Kategorie: Schuhe
    {
        "datei": "034_boots1.png",
        "bezeichnung": "Stiefel Braun Leder High",
        "kategorie_slug": "schuhe",
        "preis": Decimal("39.99"),
        "info": "Hochwertige Leder-Stiefel in Braun, Größe 40",
        "lager": 3,
    },
    {
        "datei": "035_boots2.png",
        "bezeichnung": "Chelsea-Boots Schwarz Classic",
        "kategorie_slug": "schuhe",
        "preis": Decimal("35.00"),
        "info": "Klassische Chelsea-Boots in Schwarz, Größe 42",
        "lager": 4,
    },
    {
        "datei": "036_boots3.png",
        "bezeichnung": "Winter-Boots Grau Warm",
        "kategorie_slug": "schuhe",
        "preis": Decimal("42.50"),
        "info": "Warme Winter-Boots in Grau mit Fellfutter, Größe 41",
        "lager": 2,
    },
    {
        "datei": "037_boots4.png",
        "bezeichnung": "Schnür-Boots Camel Brau",
        "kategorie_slug": "schuhe",
        "preis": Decimal("38.00"),
        "info": "Robuste Schnür-Boots in Camelbraun, Größe 43",
        "lager": 3,
    },
    {
        "datei": "040_boots5.png",
        "bezeichnung": "Platz-Boots Outdoor Trekking",
        "kategorie_slug": "schuhe",
        "preis": Decimal("44.99"),
        "info": "Trekkingschuhe für Outdoor-Aktivitäten, wasserdicht, Größe 42",
        "lager": 2,
    },
    {
        "datei": "041_boots6.png",
        "bezeichnung": "Low-Boots Beige Canvas",
        "kategorie_slug": "schuhe",
        "preis": Decimal("29.99"),
        "info": "Leichte Canvas-Boots in Beige, Größe 39",
        "lager": 5,
    },
    {
        "datei": "042_boots7.png",
        "bezeichnung": "Classic-Boots Schwarz Leder",
        "kategorie_slug": "schuhe",
        "preis": Decimal("41.00"),
        "info": "Klassische schwarze Leder-Boots, Größe 44",
        "lager": 2,
    },
    # Sneaker (038_sneakers1.png, 039_sneakers2.png) - Kategorie: Schuhe
    {
        "datei": "038_sneakers1.png",
        "bezeichnung": "Sneaker Canvas Weiß Classic",
        "kategorie_slug": "schuhe",
        "preis": Decimal("24.99"),
        "info": "Klassische weiße Canvas-Sneaker, Größe 42",
        "lager": 6,
    },
    {
        "datei": "039_sneakers2.png",
        "bezeichnung": "Sneaker Schwarz Sportlich",
        "kategorie_slug": "schuhe",
        "preis": Decimal("28.50"),
        "info": "Sportliche Sneaker in Schwarz, Größe 41",
        "lager": 4,
    },
    # Spielcontroller (043_spielcontroller.png) - Kategorie: Elektronik
    {
        "datei": "043_spielcontroller.png",
        "bezeichnung": "Spielcontroller PS5 Wireless",
        "kategorie_slug": "elektronik",
        "preis": Decimal("22.99"),
        "info": "Wireless-Controller für PlayStation 5, schwarz",
        "lager": 3,
    },
    # Videospiel (044_videospiel.png) - Kategorie: Elektronik
    {
        "datei": "044_videospiel.png",
        "bezeichnung": "Videospiel Adventure XP10",
        "kategorie_slug": "elektronik",
        "preis": Decimal("15.99"),
        "info": "Abenteuervideospiel für XP10-Konsole, gebraucht",
        "lager": 2,
    },
    # Gitarre (045_gitarre1.png, 046_gitarre2.png) - Kategorie: Elektronik
    {
        "datei": "045_gitarre1.png",
        "bezeichnung": "Akustikgitarre Natur Holz",
        "kategorie_slug": "elektronik",
        "preis": Decimal("65.00"),
        "info": "Klassische Akustikgitarre aus Naturholz, voll保持t",
        "lager": 1,
    },
    {
        "datei": "046_gitarre2.png",
        "bezeichnung": "E-Gitarre Schwarz Stratocaster",
        "kategorie_slug": "elektronik",
        "preis": Decimal("79.99"),
        "info": "Elektro-Gitarre im Stratocaster-Stil, schwarz",
        "lager": 1,
    },
    # Tisch (047_tisch1.png, 048_tisch2.png) - Kategorie: Möbel
    {
        "datei": "047_tisch1.png",
        "bezeichnung": "Schreibtisch Holz Natur Weiß",
        "kategorie_slug": "moebel",
        "preis": Decimal("55.00"),
        "info": "Holz-Schreibtisch in Natur/Weiß, 120x60cm",
        "lager": 1,
    },
    {
        "datei": "048_tisch2.png",
        "bezeichnung": "Esstisch Ausziehbar Braun",
        "kategorie_slug": "moebel",
        "preis": Decimal("75.00"),
        "info": "Ausziehbarer Esstisch in Braun, 120-180cm",
        "lager": 1,
    },
    # Bürostuhl (049_buerostuhl1.png, 050_buerostuhl2.png) - Kategorie: Möbel
    {
        "datei": "049_buerostuhl1.png",
        "bezeichnung": "Bürostuhl ergonomisch Schwarz",
        "kategorie_slug": "moebel",
        "preis": Decimal("89.99"),
        "info": "Ergonomischer Bürostuhl mit Rückenstütze, schwarz",
        "lager": 1,
    },
    {
        "datei": "050_buerostuhl2.png",
        "bezeichnung": "Drehstuhl Grau Comfort",
        "kategorie_slug": "moebel",
        "preis": Decimal("45.00"),
        "info": "Bequemer Drehstuhl in Grau, verstellbar",
        "lager": 1,
    },
]


def erstelle_produkte(cursor, conn, zustands_map, kategorien_map):
    """Erstellt die 50 Produkte basierend auf den echten Bild-Dateinamen."""
    print("Erstelle Produkte...")

    # Prüfen, ob bereits Produkte existieren
    cursor.execute("SELECT COUNT(*) FROM produkt")
    anzahl = cursor.fetchone()[0]
    if anzahl > 0:
        print(f"  Datenbank enthält bereits {anzahl} Produkte!")
        print("  Überspringe das Löschen bestehender Produkte.")

    # zustands_map und kategorien_map werden als Parameter übergeben

    for p in PRODUKTE:
        produkt_id = str(uuid.uuid4())
        bezeichnung = p["bezeichnung"]
        slug = bezeichnung.lower().replace(" ", "-").replace("'", "").replace("ä", "ae").replace("ö", "oe").replace("ü", "ue").replace("ß", "ss")
        info = p["info"]
        preis = p["preis"]
        lager = p["lager"]
        zustand_id = zustands_map["Gut"]  # Standard: Gut
        kategorie_id = kategorien_map[p["kategorie_slug"]]

        # Prüfen, ob Produkt bereits existiert
        cursor.execute("SELECT COUNT(*) FROM produkt WHERE slug = %s", (slug,))
        if cursor.fetchone()[0] > 0:
            print(f"  Überspringe '{bezeichnung}' (bereits existierend)")
            continue

        cursor.execute(
            """
            INSERT INTO produkt (
                produkt_id, laufende_nr, bezeichnung, slug, produkt_info,
                preis, produkt_rabatt, lagerbestand,
                zustand_id, kategorie_id, produkt_aktiv
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (
                produkt_id,
                uuid.uuid4().int % 100000,
                bezeichnung,
                slug,
                info,
                preis,
                Decimal("0.00"),
                lager,
                zustand_id,
                kategorie_id,
                True,
            ),
        )
        conn.commit()
        print(f"  '{bezeichnung}' hinzugefügt ({p['datei']})")

    print(f"\nProdukt-Erstellung abgeschlossen!")


def main():
    """Hauptfunktion zum Ausführen des Seeds."""
    print("=" * 60)
    print("ThriftShop Datenbank-Seed")
    print("=" * 60)

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        zustand_ids = erstelle_zustaende(cursor)
        kategorie_ids = erstelle_kategorien(cursor)
        erstelle_produkte(cursor, conn, zustand_ids, kategorie_ids)

        print("\n" + "=" * 60)
        print("Seed abgeschlossen!")
        print("=" * 60)
    except Exception as e:
        print(f"\nFehler: {e}")
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    main()
