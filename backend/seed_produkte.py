#!/usr/bin/env python3
"""
Seed-Skript für die ThriftShop-Datenbank.
Erstellt standardisierte Zustände und Kategorien, sowie 50 Produkte mit sinnvollen Preisen und Bildzuweisungen.

Ausführen mit: python backend/seed_produkte.py
"""

import mysql.connector
import os
import uuid
from decimal import Decimal
from dotenv import load_dotenv

load_dotenv()

# Produkt-Daten: Dateiname, Bezeichnung, Kategorie, Preis, Info, Lagerbestand
PRODUKTE = [
    # --- Kleidung: Herren (1-10) ---
    {
        "datei": "001_hose1.png",
        "bezeichnung": "Herren-Jeans Classic Blue",
        "kategorie_slug": "kleidung-herren",
        "preis": "24.99",
        "info": "Klassische blaue Herren-Jeans, gut erhaltener Zustand.",
        "lagerbestand": 1,
    },
    {
        "datei": "002_hose2.png",
        "bezeichnung": "Herren-Chino Hose Beige",
        "kategorie_slug": "kleidung-herren",
        "preis": "19.99",
        "info": "Beigene Chino-Hose, bequem und vielseitig kombinierbar.",
        "lagerbestand": 1,
    },
    {
        "datei": "003_jacke1.png",
        "bezeichnung": "Lederjacke Schwarz Herren",
        "kategorie_slug": "kleidung-herren",
        "preis": "49.99",
        "info": "Echte Lederjacke, stilvoll und warm. Kleine Gebrauchsspuren.",
        "lagerbestand": 1,
    },
    {
        "datei": "004_jacke2.png",
        "bezeichnung": "Windbreaker Synthetik Blau",
        "kategorie_slug": "kleidung-herren",
        "preis": "22.99",
        "info": "Leichte Windjacke, wasserabweisend, ideal für den Frühling.",
        "lagerbestand": 1,
    },
    {
        "datei": "005_tshirt1.png",
        "bezeichnung": "T-Shirt Basic Weiß",
        "kategorie_slug": "kleidung-herren",
        "preis": "9.99",
        "info": "Klassisches weißes T-Shirt, 100% Baumwolle.",
        "lagerbestand": 2,
    },
    {
        "datei": "006_tshirt2.png",
        "bezeichnung": "Print-T-Shirt Grafik",
        "kategorie_slug": "kleidung-herren",
        "preis": "12.99",
        "info": "T-Shirt mit aufgedrucktem Grafik-Design, modisch.",
        "lagerbestand": 2,
    },
    {
        "datei": "007_pullover1.png",
        "bezeichnung": "Wolle-Pullover Grau",
        "kategorie_slug": "kleidung-herren",
        "preis": "27.99",
        "info": " warmer Wolle-Pullover, ideal für den Winter.",
        "lagerbestand": 1,
    },
    {
        "datei": "008_pullover2.png",
        "bezeichnung": "Strickpullover Vintage Braun",
        "kategorie_slug": "kleidung-herren",
        "preis": "29.99",
        "info": "Retro Strickpullover in Braun, gemütlich und stylisch.",
        "lagerbestand": 1,
    },
    {
        "datei": "009_pullover3.png",
        "bezeichnung": "Kapuzenpulli Hoodie Schwarz",
        "kategorie_slug": "kleidung-herren",
        "preis": "25.99",
        "info": "Schwarzer Hoodie mit Kapuze und Beuteltasche.",
        "lagerbestand": 1,
    },
    {
        "datei": "010_hemd1.png",
        "bezeichnung": "Hemd Karo Rot-Weiß",
        "kategorie_slug": "kleidung-herren",
        "preis": "16.99",
        "info": "Klassisches kariertes Hemd, rot-weiß, aus Baumwolle.",
        "lagerbestand": 1,
    },
    # --- Kleidung: Damen (11-20) ---
    {
        "datei": "011_rock1.png",
        "bezeichnung": "Faltenrock Marineblau",
        "kategorie_slug": "kleidung-damen",
        "preis": "18.99",
        "info": "Eleganter Faltenrock in Marineblau, mittlerer Länge.",
        "lagerbestand": 1,
    },
    {
        "datei": "012_rock2.png",
        "bezeichnung": "Minirock Schwarz Jeans",
        "kategorie_slug": "kleidung-damen",
        "preis": "14.99",
        "info": "Kurzer schwarzer Jeans-Rock, sommerlich und lässig.",
        "lagerbestand": 1,
    },
    {
        "datei": "013_kleid1.png",
        "bezeichnung": "Sommerkleid Blumen Rosa",
        "kategorie_slug": "kleidung-damen",
        "preis": "28.99",
        "info": "Wunderschönes Sommerkleid mit Blumenmuster in Rosa.",
        "lagerbestand": 1,
    },
    {
        "datei": "014_kleid2.png",
        "bezeichnung": "Partykleid Cocktail Schwarz",
        "kategorie_slug": "kleidung-damen",
        "preis": "39.99",
        "info": "Elegantes schwarzes Cocktailkleid für besondere Anlässe.",
        "lagerbestand": 1,
    },
    {
        "datei": "015_kleid3.png",
        "bezeichnung": "Maxikleid Boho Print",
        "kategorie_slug": "kleidung-damen",
        "preis": "34.99",
        "info": "Langes Boho-Kleid mit amazing Print, perfekt für den Sommer.",
        "lagerbestand": 1,
    },
    {
        "datei": "016_bluse1.png",
        "bezeichnung": "Bluse Seide Creme",
        "kategorie_slug": "kleidung-damen",
        "preis": "21.99",
        "info": "Elegante Seidenbluse in Creme, fein und leicht.",
        "lagerbestand": 1,
    },
    {
        "datei": "017_stola1.png",
        "bezeichnung": "Strickjacke OverSize Beige",
        "kategorie_slug": "kleidung-damen",
        "preis": "26.99",
        "info": "Bequeme OverSize Strickjacke, warm und modisch.",
        "lagerbestand": 1,
    },
    {
        "datei": "018_mantel1.png",
        "bezeichnung": "Trenchcoat Beige Classic",
        "kategorie_slug": "kleidung-damen",
        "preis": "49.99",
        "info": "Klassischer Trenchcoat in Beige, wasserabweisend.",
        "lagerbestand": 1,
    },
    {
        "datei": "019_jeans_damen1.png",
        "bezeichnung": "Slim-Fit Jeans Damen Schwarz",
        "kategorie_slug": "kleidung-damen",
        "preis": "23.99",
        "info": "Schmale Slim-Fit Jeans in Schwarz, sehr schmeichelhaft.",
        "lagerbestand": 1,
    },
    {
        "datei": "020_schal1.png",
        "bezeichnung": "Wollschal Gemustert",
        "kategorie_slug": "kleidung-damen",
        "preis": "12.99",
        "info": "Warmer Wollschal mit klassischem Muster.",
        "lagerbestand": 2,
    },
    # --- Accessoires (21-30) ---
    {
        "datei": "021_gurt1.png",
        "bezeichnung": "Leder-Gürtel Braun Classic",
        "kategorie_slug": "accessoires",
        "preis": "14.99",
        "info": "Echter Ledergürtel in Braun, klassisches Design.",
        "lagerbestand": 2,
    },
    {
        "datei": "022_krawatte1.png",
        "bezeichnung": "Krawatte Seide Dunkelblau",
        "kategorie_slug": "accessoires",
        "preis": "11.99",
        "info": "Elegante Seidenkrawatte in Dunkelblau, für Geschäft und Feier.",
        "lagerbestand": 2,
    },
    {
        "datei": "023_muetze1.png",
        "bezeichnung": "Strickmütze Winter Grau",
        "kategorie_slug": "accessoires",
        "preis": "9.99",
        "info": "Warme Strickmütze in Grau, perfekt für kalte Tage.",
        "lagerbestand": 3,
    },
    {
        "datei": "024_schal_tuch1.png",
        "bezeichnung": "Halstuch Bandana Rot",
        "kategorie_slug": "accessoires",
        "preis": "7.99",
        "info": "Vielseitiges Bandana-Tuch in Rot, multifunktional einsetzbar.",
        "lagerbestand": 3,
    },
    {
        "datei": "025_sonnentue1.png",
        "bezeichnung": "Sun Hat Strohhut",
        "kategorie_slug": "accessoires",
        "preis": "15.99",
        "info": "Breiter Strohhut als Sonnenschutz, sommerlich und stylisch.",
        "lagerbestand": 2,
    },
    {
        "datei": "026_brille1.png",
        "bezeichnung": "Sonnenbrille Round Metal",
        "kategorie_slug": "accessoires",
        "preis": "18.99",
        "info": "Runde Sonnenbrille mit Metallgestell, UV-Schutz.",
        "lagerbestand": 1,
    },
    {
        "datei": "027_geldbeutel1.png",
        "bezeichnung": "Geldbeutel Leder Braun",
        "kategorie_slug": "accessoires",
        "preis": "12.99",
        "info": "Kompakter Geldbeutel aus echt Leder, viele Fächer.",
        "lagerbestand": 2,
    },
    {
        "datei": "028_rucksack1.png",
        "bezeichnung": "Rucksack Campus Braun",
        "kategorie_slug": "taschen",
        "preis": "29.99",
        "info": "Klassischer Rucksack aus Kunststoff, geräumig und praktisch.",
        "lagerbestand": 1,
    },
    {
        "datei": "029_handtasche1.png",
        "bezeichnung": "Einkaufstasche Canvas Beige",
        "kategorie_slug": "taschen",
        "preis": "9.99",
        "info": "Wiederverwendbare Canvas-Einkaufstasche, robust und stylisch.",
        "lagerbestand": 3,
    },
    {
        "datei": "030_mappe1.png",
        "bezeichnung": "Klappmappe Damen Vintage",
        "kategorie_slug": "taschen",
        "preis": "19.99",
        "info": "Elegante Klappmappe in Vintage-Optik, mit Metallverschluss.",
        "lagerbestand": 1,
    },
    # --- Schuhe (31-40) ---
    {
        "datei": "031_sneaker1.png",
        "bezeichnung": "Sneaker Canvas Weiß",
        "kategorie_slug": "schuhe",
        "preis": "24.99",
        "info": "Klassische weiße Sneaker aus Leinwand, bequem und vielseitig.",
        "lagerbestand": 1,
    },
    {
        "datei": "032_sneaker2.png",
        "bezeichnung": "Sportschuhe Trail Schwarz",
        "kategorie_slug": "schuhe",
        "preis": "34.99",
        "info": "Leichte Sportschuhe für das Training, atmungsaktiv.",
        "lagerbestand": 1,
    },
    {
        "datei": "033_boots1.png",
        "bezeichnung": "Stiefel Leder Braun",
        "kategorie_slug": "schuhe",
        "preis": "44.99",
        "info": "Hochwertige braune Leder-Stiefel, robust und langlebig.",
        "lagerbestand": 1,
    },
    {
        "datei": "034_stiefelette1.png",
        "bezeichnung": "Stiefelette Schnürer Schwarz",
        "kategorie_slug": "schuhe",
        "preis": "38.99",
        "info": "Schwarze Schnür-Stiefeletten, elegant und praktisch.",
        "lagerbestand": 1,
    },
    {
        "datei": "035_pantoffel1.png",
        "bezeichnung": "Hausschuh Pantoffel Grau",
        "kategorie_slug": "schuhe",
        "preis": "12.99",
        "info": "Bequeme Pantoffeln aus weichem Material, für drinnen.",
        "lagerbestand": 2,
    },
    {
        "datei": "036_ballerschuhe1.png",
        "bezeichnung": "Ballerschuhe Chukka Camel",
        "kategorie_slug": "schuhe",
        "preis": "36.99",
        "info": "Klassische Chukka-Ballerschuhe in Camel, aus feinem Leder.",
        "lagerbestand": 1,
    },
    {
        "datei": "037_loafer1.png",
        "bezeichnung": "Loafer Slip-On Braun",
        "kategorie_slug": "schuhe",
        "preis": "29.99",
        "info": "Bequeme Slip-On Loafers in Braun, eleganter Allrounder.",
        "lagerbestand": 1,
    },
    {
        "datei": "038_schuh_brown.png",
        "bezeichnung": "Halbschuh City Braun",
        "kategorie_slug": "schuhe",
        "preis": "32.99",
        "info": "Stilvolle Halbschuhe für den Alltag, braun, gut erhalten.",
        "lagerbestand": 1,
    },
    {
        "datei": "039_fusslinge1.png",
        "bezeichnung": "Fußlinge Antirutsch Beige",
        "kategorie_slug": "schuhe",
        "preis": "5.99",
        "info": "Set aus zwei Paar Fußlinge mit Antirutsch-Sohle.",
        "lagerbestand": 3,
    },
    {
        "datei": "040_socken1.png",
        "bezeichnung": "Socken Set 3 Paar Weiß",
        "kategorie_slug": "schuhe",
        "preis": "6.99",
        "info": "Grundlegende weiße Socken, 3er Pack, Baumwolle.",
        "lagerbestand": 5,
    },
    # --- Spielzeug & Elektronik (41-45) ---
    {
        "datei": "041_lego1.png",
        "bezeichnung": "Legobauset Classic 300 Teile",
        "kategorie_slug": "spielzeug",
        "preis": "18.99",
        "info": "Klassisches Lego-Bauset mit 300 Teilen, kreativ und lehrreich.",
        "lagerbestand": 1,
    },
    {
        "datei": "042_puppe1.png",
        "bezeichnung": "Stoffpuppe Kuscheltier",
        "kategorie_slug": "spielzeug",
        "preis": "11.99",
        "info": "Weiche Kuschelpuppe, perfekt zum Träumen und Schlafen.",
        "lagerbestand": 2,
    },
    {
        "datei": "043_controller1.png",
        "bezeichnung": "Gamepad USB Controller",
        "kategorie_slug": "elektronik",
        "preis": "14.99",
        "info": "Klassischer USB-Gamecontroller, kompatibel mit PC und Konsole.",
        "lagerbestand": 1,
    },
    {
        "datei": "044_spielkarte1.png",
        "bezeichnung": "Spielkartenspiel Strategie",
        "kategorie_slug": "spielzeug",
        "preis": "8.99",
        "info": "Kartenspiel für die ganze Familie, strategiespielspaß pur.",
        "lagerbestand": 2,
    },
    {
        "datei": "045_radio1.png",
        "bezeichnung": "DAB+ Radiodigital Compact",
        "kategorie_slug": "elektronik",
        "preis": "22.99",
        "info": "Kompaktes digitales Radio mit DAB+-Unterstützung, gut erhalten.",
        "lagerbestand": 1,
    },
    # --- Bücher & Medien (46-48) ---
    {
        "datei": "046_buch1.png",
        "bezeichnung": "Roman Taschenbuch Beststeller",
        "kategorie_slug": "buecher",
        "preis": "7.99",
        "info": "Spannendes Roman-Taschenbuch, ehemaliger Beststeller.",
        "lagerbestand": 2,
    },
    {
        "datei": "047_buch2.png",
        "bezeichnung": "Kochbuch International",
        "kategorie_slug": "buecher",
        "preis": "12.99",
        "info": "Kochbuch mit internationalen Rezepten, farbig und ansprechend.",
        "lagerbestand": 2,
    },
    {
        "datei": "048_cd_musik1.png",
        "bezeichnung": "CD Sammlering Rock Classics",
        "kategorie_slug": "medien",
        "preis": "9.99",
        "info": "CD-Mix mit Rock-Klassikern, ideale Mischung.",
        "lagerbestand": 1,
    },
    # --- Hausrat (49-50) ---
    {
        "datei": "049_teekanne1.png",
        "bezeichnung": "Teekanne Keramik Vintage",
        "kategorie_slug": "hausrat",
        "preis": "16.99",
        "info": "Schöne Vintage-Teekanne aus Keramik, mit feinem Muster.",
        "lagerbestand": 1,
    },
    {
        "datei": "050_teller1.png",
        "bezeichnung": "Teller-Set Porzellan 6 Teile",
        "kategorie_slug": "hausrat",
        "preis": "19.99",
        "info": "6-teiliges Porzellanteller-Set, klassisches Design, gut erhalten.",
        "lagerbestand": 1,
    },
]


# --- Standardwerte ---
ZUSTAENDE = [
    {
        "bezeichnung": "Neuwertig",
        "beschreibung": "Artikel ist praktisch neuwertig, keine sichtbaren Gebrauchsspuren.",
    },
    {
        "bezeichnung": "Gut",
        "beschreibung": "Artikel ist gut erhalten, minimale Gebrauchsspuren.",
    },
    {
        "bezeichnung": "Akzeptabel",
        "beschreibung": "Artikel ist voll funktionsfähig, erkennbare Gebrauchsspuren.",
    },
]

KATEGORIEN = [
    {
        "bezeichnung": "Kleidung Herren",
        "slug": "kleidung-herren",
        "rabatt": "0.00",
        "steuersatz": "19.00",
    },
    {
        "bezeichnung": "Kleidung Damen",
        "slug": "kleidung-damen",
        "rabatt": "0.00",
        "steuersatz": "19.00",
    },
    {
        "bezeichnung": "Accessoires",
        "slug": "accessoires",
        "rabatt": "0.00",
        "steuersatz": "19.00",
    },
    {
        "bezeichnung": "Taschen",
        "slug": "taschen",
        "rabatt": "0.00",
        "steuersatz": "19.00",
    },
    {
        "bezeichnung": "Schuhe",
        "slug": "schuhe",
        "rabatt": "0.00",
        "steuersatz": "19.00",
    },
    {
        "bezeichnung": "Spielzeug",
        "slug": "spielzeug",
        "rabatt": "0.00",
        "steuersatz": "19.00",
    },
    {
        "bezeichnung": "Elektronik",
        "slug": "elektronik",
        "rabatt": "0.00",
        "steuersatz": "19.00",
    },
    {
        "bezeichnung": "Bücher",
        "slug": "buecher",
        "rabatt": "0.00",
        "steuersatz": "7.00",  # Bücher haben ermäßigten Steuersatz
    },
    {
        "bezeichnung": "Medien",
        "slug": "medien",
        "rabatt": "0.00",
        "steuersatz": "7.00",
    },
    {
        "bezeichnung": "Hausrat",
        "slug": "hausrat",
        "rabatt": "0.00",
        "steuersatz": "19.00",
    },
]


def get_db_connection():
    """Stellt eine Verbindung zur Datenbank her."""
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "thriftshop"),
    )


def erstelle_zustaende(cursor):
    """Erstellt die Standard-Zustände, falls nicht vorhanden."""
    zustand_ids = {}
    for zs in ZUSTAENDE:
        cursor.execute(
            "SELECT zustand_id FROM zustand WHERE bezeichnung = %s",
            (zs["bezeichnung"],),
        )
        existierend = cursor.fetchone()
        if existierend:
            zustand_ids[zs["bezeichnung"]] = existierend[0]
        else:
            zustand_id = str(uuid.uuid4())
            cursor.execute(
                "INSERT INTO zustand (zustand_id, bezeichnung, beschreibung) VALUES (%s, %s, %s)",
                (zustand_id, zs["bezeichnung"], zs["beschreibung"]),
            )
            zustand_ids[zs["bezeichnung"]] = zustand_id
    return zustand_ids


def erstelle_kategorien(cursor):
    """Erstellt die Standard-Kategorien, falls nicht vorhanden."""
    kategorie_ids = {}
    for kat in KATEGORIEN:
        cursor.execute(
            "SELECT kategorie_id FROM kategorie WHERE slug = %s",
            (kat["slug"],),
        )
        existierend = cursor.fetchone()
        if existierend:
            kategorie_ids[kat["slug"]] = existierend[0]
        else:
            kategorie_id = str(uuid.uuid4())
            cursor.execute(
                "INSERT INTO kategorie (kategorie_id, bezeichnung, slug, kategorie_rabatt, steuersatz) VALUES (%s, %s, %s, %s, %s)",
                (
                    kategorie_id,
                    kat["bezeichnung"],
                    kat["slug"],
                    kat["rabatt"],
                    kat["steuersatz"],
                ),
            )
            kategorie_ids[kat["slug"]] = kategorie_id
    return kategorie_ids


def erstelle_produkte(
    cursor, zustand_ids, kategorie_ids, bilder_ordner="frontend/assets/produktbilder"
):
    """Erstellt alle Produkte mit Bildzuweisung."""
    produkte_count = 0
    fehler = []

    # Prüfe, ob Bilder vorhanden sind
    try:
        import os

        vorhandene_bilder = os.listdir(bilder_ordner)
    except FileNotFoundError:
        print(
            f"⚠️  Bilder-Ordner '{bilder_ordner}' nicht gefunden. Produkte werden ohne Bildpfad erstellt."
        )
        vorhandene_bilder = []

    for idx, prod in enumerate(PRODUKTE, start=1):
        try:
            # Finde die passende Zustand-ID (verteile auf die 3 Zustände)
            zustand_name = ["Neuwertig", "Gut", "Akzeptabel"][idx % 3]
            zustand_id = zustand_ids[zustand_name]

            # Finde die Kategorie-ID
            kategorie_id = kategorie_ids.get(prod["kategorie_slug"])
            if not kategorie_id:
                raise KeyError(f"Kategorie '{prod['kategorie_slug']}' nicht gefunden!")

            # Erstelle Bildpfad
            bildpfad = f"/assets/produktbilder/{prod['datei']}"
            if prod["datei"] in vorhandene_bilder:
                bildpfad = f"/assets/produktbilder/{prod['datei']}"
            else:
                bildpfad = "/assets/produktbilder/default.png"  # Fallback

            # Erstelle Produkt-ID
            produkt_id = str(uuid.uuid4())

            # Erstelle Slug aus Bezeichnung
            slug = prod["bezeichnung"].lower()
            slug = slug.replace(" ", "-")
            slug = slug.replace(".", "-")
            slug = slug.replace(",", "-")
            slug = slug.replace("&", "-und-")

            cursor.execute(
                """
                INSERT INTO produkt (
                    produkt_id, bezeichnung, slug, produkt_info, preis,
                    produkt_rabatt, produkt_aktiv, lagerbestand,
                    zustand_id, kategorie_id
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    produkt_id,
                    prod["bezeichnung"],
                    slug,
                    prod["info"],
                    prod["preis"],
                    "0.00",
                    True,
                    prod["lagerbestand"],
                    zustand_id,
                    kategorie_id,
                ),
            )
            produkte_count += 1
            print(
                f"  ✓ {prod['datei']:25s} → {prod['bezeichnung']:40s} | {prod['preis']:>6s} € | {prod['kategorie_slug']}"
            )
        except Exception as e:
            fehler.append(f"  ✗ Fehler bei '{prod['datei']}': {e}")

    return produkte_count, fehler


def main():
    """Hauptfunktion: Seed-Daten in die Datenbank eintragen."""
    print("=" * 80)
    print("ThriftShop - Produkt-Seed-Skript")
    print("=" * 80)

    # Schritt 1: Datenbankverbindung
    print("\n[1/4] Stelle Datenbankverbindung her...")
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        print("  ✓ Verbunden mit Datenbank 'thriftshop'")
    except Exception as e:
        print(f"  ✗ Fehler bei der Datenbankverbindung: {e}")
        print(
            "\n   Prüfe bitte deine .env-Datei (DB_HOST, DB_USER, DB_PASSWORD, DB_NAME)"
        )
        return

    # Schritt 2: Zustand erstellen
    print("\n[2/4] Erstelle Zustände...")
    zustand_ids = erstelle_zustaende(cursor)
    for name, zid in zustand_ids.items():
        print(f"  ✓ {name:15s} ({zid[:8]}...)")

    # Schritt 3: Kategorien erstellen
    print("\n[3/4] Erstelle Kategorien...")
    kategorie_ids = erstelle_kategorien(cursor)
    for slug, kid in kategorie_ids.items():
        print(f"  ✓ {slug:20s} ({kid[:8]}...)")

    # Schritt 4: Produkte erstellen
    print("\n[4/4] Erstelle 50 Produkte...")
    produkte_count, fehler = erstelle_produkte(cursor, zustand_ids, kategorie_ids)

    # Transaktion abschließen
    conn.commit()
    cursor.close()
    conn.close()

    # Ergebnis
    print("\n" + "=" * 80)
    print("Ergebnis:")
    print(f"  ✓ {produkte_count} Produkte erfolgreich erstellt")
    if fehler:
        print(f"  ⚠ {len(fehler)} Fehler aufgetreten:")
        for f in fehler:
            print(f)
    print("=" * 80)
    print("\n🎉 Alles erledigt! Die Produkte sind jetzt in der Datenbank.")


if __name__ == "__main__":
    main()
