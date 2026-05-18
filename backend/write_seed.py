#!/usr/bin/env python3
import os

content = []
content.append('#!/usr/bin/env python3')
content.append('"""')
content.append('Seed-Skript für die ThriftShop-Datenbank.')
content.append('Erstellt standardisierte Zustände und Kategorien, sowie 50 Produkte mit sinnvollen Preisen und Bildzuweisungen.')
content.append('')
content.append('Ausführen mit: cd backend && python seed_produkte.py')
content.append('"""')
content.append('')
content.append('import mysql.connector')
content.append('import os')
content.append('import uuid')
content.append('from decimal import Decimal')
content.append('from dotenv import load_dotenv')
content.append('')
content.append('# Lade .env für Datenbankverbindung')
content.append('load_dotenv()')
content.append('')
content.append('# Produkt-Daten: Basierend auf den TATSÄCHLICHEN Dateien in frontend/assets/produktbilder/')
content.append('PRODUKTE = [')

produkte = [
    # --- Gürtel (001-002) → Accessoires, 8-15€ ---
    ("001_gel1.png", "Leder-Gürtel Braun Classic", "accessoires", "12.99", "Klassischer Ledergürtel in Braun, perfekt für den Alltag.", 2),
    ("002_gel2.png", "Gürtel Schwarz Kunstleder", "accessoires", "8.99", "Schwarzer Gürtel aus Kunstleder, schlicht und funktional.", 2),
    # --- Hose (003-004) → Kleidung Herren, 10-25€ ---
    ("003_hose1.png", "Jeans-Hose Blau Slim Fit", "kleidung-herren", "22.99", "Blaue Slim-Fit Jeans, bequemer Schnitt, gute Qualität.", 1),
    ("004_hose2.png", "Chino-Hose Beige Regular", "kleidung-herren", "18.99", "Beige Chino-Hose, regular fit, bequem und vielseitig.", 1),
    # --- Jacke (005-006, 011) → Kleidung Herren, 20-50€ ---
    ("005_jacke1.png", "Winterjacke Daunen Schwarz", "kleidung-herren", "45.99", "Warme Daunen-Winterjacke, leicht und isolierend.", 1),
    ("006_jacke2.png", "Lederjacke Braun Vintage", "kleidung-herren", "49.99", "Echte Lederjacke in Vintage-Braun, robuster Reißverschluss.", 1),
    ("011_jacke3.png", "Windjacke Leicht Blau", "kleidung-herren", "24.99", "Leichte Windjacke in Blau, wind- und wasserabweisend.", 1),
    # --- Radio (007-008) → Elektronik, 15-40€ ---
    ("007_radio1.png", "Kompaktradio Digital DAB+", "elektronik", "29.99", "Kompaktes digitales Radio mit DAB+-Unterstützung und USB-Anschluss.", 1),
    ("008_radio2.png", "Vintage Radio Holz Kunststoff", "elektronik", "35.99", "Vintage-Radio im Retro-Design aus Holz und Kunststoff, funktionstüchtig.", 1),
    # --- T-Shirt (009-010) → Kleidung Herren, 8-20€ ---
    ("009_tshirts2.png", "T-Shirt Graphic Print Grau", "kleidung-herren", "12.99", "Graues T-Shirt mit Graphic Print, modernes Design.", 2),
    ("010_tshits1.png", "T-Shirt Basic Weiß Cotton", "kleidung-herren", "9.99", "Klassisches weißes Basic-T-Shirt, 100% Baumwolle.", 2),
    # --- Tasche (012-014) → Taschen, 10-30€ ---
    ("012_tasche1.png", "Einkaufstasche Canvas Grau", "taschen", "9.99", "Robuste Canvas-Einkaufstasche in Grau, wiederverwendbar.", 3),
    ("013_tasche2.png", "Rucksack Outdoor Braun", "taschen", "28.99", "Geräumiger Outdoor-Rucksack in Braun, mehrere Fächer.", 1),
    ("014_tasche3.png", "Umhängetasche Leder Schwarz", "taschen", "24.99", "Schwarze Umhängetasche aus Kunstleder, elegant und praktisch.", 1),
    # --- Geldbeutel (015-016) → Accessoires, 5-12€ ---
    ("015_geldbeutel1.png", "Geldbeutel Leder Braun Klapp", "accessoires", "11.99", "Klassischer Klapp-Geldbeutel aus Leder in Braun.", 2),
    ("016_geldbeutel2.png", "Geldbeutel Slim Schwarz", "accessoires", "8.99", "Schlanker Geldbeutel in Schwarz, Platz für Karten und Bargeld.", 2),
    # --- Pullover (017-019) → Kleidung Herren, 12-30€ ---
    ("017_pullover1.png", "Pullover Wolle Naturbraun", "kleidung-herren", "27.99", "Warmer Wolle-Pullover in Naturbraun, klassisches Design.", 1),
    ("018_pullover2.png", "Strickpullover Kabelstrick Grau", "kleidung-herren", "29.99", "Gemütlicher Strickpullover mit Kabelstrick-Muster, grau.", 1),
    ("019_pullover3.png", "Kapuzenpulli Hoodie Schwarz", "kleidung-herren", "25.99", "Schwarzer Hoodie mit Kapuze und Beuteltasche, bequem.", 1),
    # --- Socken (020-022) → Accessoires, 3-8€ ---
    ("020_socken1.png", "Socken Set 3 Paar Winterwarm", "accessoires", "6.99", "3er-Pack warme Wintersocken, perfekt für kalte Tage.", 5),
    ("021_socken2.png", "Socken Set 5 Paar Basic Weiß", "accessoires", "5.99", "5er-Pack Basic-Socken in Weiß, Baumwolle, alltäglich.", 5),
    ("022_socken3.png", "Socken bunt gestreift", "accessoires", "4.99", "Bunte gestreifte Socken, lustiges Design für drinnen.", 5),
    # --- Pyjamahose (023-024) → Kleidung Herren, 8-15€ ---
    ("023_pyjamahose1.png", "Pyjamahose Caribou blau", "kleidung-herren", "12.99", "Bequeme Pyjamahose in Blau, weiches Material zum Schlafen.", 2),
    ("024_pyjamahose2.png", "Pyjamahose Samt Grau", "kleidung-herren", "14.99", "Luxuriöse Pyjamahose aus Samt in Grau, extra weich.", 2),
    # --- Rock (025-027) → Kleidung Damen, 10-30€ ---
    ("025_rock1.png", "Faltenrock Marineblau Lang", "kleidung-damen", "22.99", "Eleganter langer Faltenrock in Marineblau.", 1),
    ("026_rock2.png", "Minirock Jeans Schwarz", "kleidung-damen", "16.99", "Kurzer modischer Jeans-Minirock, sommerlich und lässig.", 1),
    ("027_rock3.png", "Rock Plissee Beige Midi", "kleidung-damen", "19.99", "Midi-Rock mit feinem Plisséé in Beige, elegant und feminin.", 1),
    # --- Kleid (028-033) → Kleidung Damen, 15-45€ ---
    ("028_kleid1.png", "Sommerkleid Blumen Rosa Kurz", "kleidung-damen", "28.99", "Wunderschönes Sommerkleid mit Blumenmuster, kurz und leicht.", 1),
    ("029_kleid2.png", "Partykleid Cocktail Schwarz", "kleidung-damen", "39.99", "Elegantes schwarzes Cocktailkleid für besondere Anlässe.", 1),
    ("030_kleid3.png", "Maxikleid Boho Print Lang", "kleidung-damen", "34.99", "Langes Boho-Kleid mit floralem Print, ideal für den Sommer.", 1),
    ("031_kleid4.png", "Bluse Seide Creme Langarm", "kleidung-damen", "24.99", "Elegante Seidenbluse in Creme, langärmlig und leicht.", 1),
    ("032_kleid5.png", "Strickjacke OverSize Beige", "kleidung-damen", "26.99", "Bequeme OverSize Strickjacke in Beige, warm und modisch.", 1),
    ("033_kleid6.png", "Mantel Trenchcoat Classic Beige", "kleidung-damen", "48.99", "Klassischer Trenchcoat in Beige, wasserabweisend und stilvoll.", 1),
    # --- Boots/Schuhe (034-042) → Schuhe, 12-45€ ---
    ("034_boots1.png", "Stiefel Schnürer Braun Leder", "schuhe", "42.99", "Robuste braune Leder-Stiefel mit Schnürung, perfekt für den Herbst.", 1),
    ("035_boots2.png", "Stiefelette Schwarz Schnürer", "schuhe", "38.99", "Schwarze Schnür-Stiefeletten, elegant und vielseitig.", 1),
    ("036_boots3.png", "Chelsea Boots Camel Velour", "schuhe", "44.99", "Klassische Chelsea-Boots in Camel Velours-Leder.", 1),
    ("037_boots4.png", "Halbstiefel City Schwarz", "schuhe", "34.99", "Schwarze Halbstiefel für den Alltag, bequem und praktisch.", 1),
    ("038_sneakers1.png", "Sneaker Canvas Weiß Classic", "schuhe", "24.99", "Klassische weiße Canvas-Sneaker, bequem und vielseitig.", 1),
    ("039_sneakers2.png", "Sportschuhe Trail Schwarz", "schuhe", "36.99", "Leichte Sportschuhe für das Training, atmungsaktiv und flexibel.", 1),
    ("040_boots5.png", "Pantoffel Hausschuh Grau", "schuhe", "12.99", "Bequeme Pantoffeln aus weichem Material, ideal für drinnen.", 2),
    ("041_boots6.png", "Baller Schuhe Chukka Camel", "schuhe", "32.99", "Klassische Chukka-Baller-Schuhe in Camel, aus feinem Leder.", 1),
    ("042_boots7.png", "Loafer Slip-On Braun Elegant", "schuhe", "29.99", "Bequeme Slip-On Loafers in Braun, eleganter Allrounder.", 1),
    # --- Spielcontroller (043) → Elektronik, 10-25€ ---
    ("043_spielcontroller.png", "Gamepad USB Controller Schwarz", "elektronik", "14.99", "Klassischer USB-Gamecontroller, kompatibel mit PC und Konsole.", 1),
    # --- Videospiel (044) → Elektronik, 5-20€ ---
    ("044_videospiel.png", "Videospiel Classic Action", "elektronik", "9.99", "Klassisches Action-Videospiel, perfekt für Abenteuerliebhaber.", 2),
    # --- Gitarre (045-046) → Elektronik, 30-80€ ---
    ("045_gitarre1.png", "Akustikgitarre Natur Holz", "elektronik", "65.99", "Schöne Akustikgitarre aus massivem Holz, warmes Klangbild.", 1),
    ("046_gitarre2.png", "E-Gitarre Stratocaster Schwarz", "elektronik", "79.99", "Elektrische Stratocaster-Gitarre in Schwarz, mit Tonabnehmern.", 1),
    # --- Tisch (047-048) → Möbel, 20-80€ ---
    ("047_tisch1.png", "Kochtisch Holz Natur Massiv", "moebel", "59.99", "Solider Massivholz-Kochtisch, natürlich und robust.", 1),
    ("048_tisch2.png", "Beistelltisch Rund Holz", "moebel", "34.99", "Kleiner runder Beistelltisch aus Holz, perfekt als Side-Table.", 1),
    # --- Bürostuhl (049-050) → Möbel, 40-120€ ---
    ("049_buerostuhl1.png", "Bürostuhl ergonomisch Schwarz", "moebel", "89.99", "Ergonomischer Bürostuhl mit Lordosenstütze und verstellbarer Höhe.", 1),
    ("050_buerostuhl2.png", "Drehstuhl Gaming Grau", "moebel", "109.99", "Gaming-Drehstuhl mit hoher Rückenlehne und Fußstütze, grau.", 1),
]

for datei, bezeichnung, kategorie_slug, preis, info, lagerbestand in produkte:
    content.append('    {')
    content.append(f'        "datei": "{datei}",')
    content.append(f'        "bezeichnung": "{bezeichnung}",')
    content.append(f'        "kategorie_slug": "{kategorie_slug}",')
    content.append(f'        "preis": Decimal("{preis}"),')
    content.append(f'        "info": "{info}",')
    content.append(f'        "lagerbestand": {lagerbestand},')
    content.append('    },')

content.append(']')
content.append('')
content.append('')
content.append('def get_db_connection():')
content.append('    """Erstelle eine Verbindung zur MySQL-Datenbank."""')
content.append('    return mysql.connector.connect(')
content.append('        host=os.getenv("DB_HOST", "localhost"),')
content.append('        port=int(os.getenv("DB_PORT", 3306)),')
content.append('        user=os.getenv("DB_USER", "root"),')
content.append('        password=os.getenv("DB_PASSWORD", ""),')
content.append('        database=os.getenv("DB_NAME", "thriftshop"),')
content.append('    )')
content.append('')
content.append('')
content.append('def erstelle_zustaende(cursor):')
content.append('    """Erstelle die Standard-Zustände in der Datenbank."""')
content.append('    print("Erstelle Zustände...")')
content.append('    zustaende = [')
content.append('        ("Neu", "Artikel ist brandneu, ungetragen und in Originalverpackung."),')
content.append('        ("Wie neu", "Artikel wurde nur selten getragen, kaum Anzeichen von Gebrauch."),')
content.append('        ("Gut", "Artikel wurde getragen, zeigt leichte Gebrauchsspuren, aber ist in gutem Zustand."),')
content.append('        ("Akzeptabel", "Artikel wurde mehrfach getragen, zeigt sichtbare Gebrauchsspuren, funktioniert noch einwandfrei."),')
content.append('    ]')
content.append('    ')
content.append('    for bez, beschreibung in zustaende:')
content.append('        cursor.execute("SELECT zustand_id FROM zustand WHERE bezeichnung = %s", (bez,))')
content.append('        existing = cursor.fetchone()')
content.append('        ')
content.append('        if existing:')
content.append("            print(f\"  Zustand '{bez}' existiert bereits (ID: {existing[0]})\")")
content.append('            continue')
content.append('        ')
content.append('        zustand_id = str(uuid.uuid4())')
content.append('        cursor.execute(')
content.append('            "INSERT INTO zustand (zustand_id, bezeichnung, beschreibung) VALUES (%s, %s, %s)",')
content.append('            (zustand_id, bez, beschreibung),')
content.append('        )')
content.append('        print(f"  Zustand \\'{bez}\\' erstellt (ID: {zustand_id})")')
content.append('    ')
content.append('    print("Zustände fertiggestellt.\\n")')
content.append('')
content.append('')
content.append('def erstelle_kategorien(cursor):')
content.append('    """Erstelle die Standard-Kategorien in der Datenbank."""')
content.append('    print("Erstelle Kategorien...")')
content.append('    kategorien = [')
content.append('        ("Kleidung Herren", "kleidung-herren", "0.00", "19.00"),')
content.append('        ("Kleidung Damen", "kleidung-damen", "0.00", "19.00"),')
content.append('        ("Schuhe", "schuhe", "0.00", "19.00"),')
content.append('        ("Accessoires", "accessoires", "0.00", "19.00"),')
content.append('        ("Taschen", "taschen", "0.00", "19.00"),')
content.append('        ("Elektronik", "elektronik", "0.00", "19.00"),')
content.append('        ("Möbel", "moebel", "0.00", "19.00"),')
content.append('    ]')
content.append('    ')
content.append('    for bezeichnung, slug, rabatt, steuersatz in kategorien:')
content.append('        cursor.execute("SELECT kategorie_id FROM kategorie WHERE slug = %s", (slug,))')
content.append('        existing = cursor.fetchone()')
content.append('        ')
content.append('        if existing:')
content.append("            print(f\"  Kategorie '{bezeichnung}' existiert bereits (ID: {existing[0]})\")")
content.append('            continue')
content.append('        ')
content.append('        kategorie_id = str(uuid.uuid4())')
content.append('        cursor.execute(')
content.append('            "INSERT INTO kategorie (kategorie_id, bezeichnung, slug, kategorie_rabatt, steuersatz) VALUES (%s, %s, %s, %s, %s)",')
content.append('            (kategorie_id, bezeichnung, slug, rabatt, steuersatz),')
content.append('        )')
content.append('        print(f"  Kategorie \\'{bezeichnung}\\' erstellt (ID: {kategorie_id})")')
content.append('    ')
content.append('    print("Kategorien fertiggestellt.\\n")')
content.append('')
content.append('')
content.append('def erstelle_produkte(cursor, conn):')
content.append('    """Erstelle 50 Produkte basierend auf den Bilddatei-Namen."""')
content.append('    print("Erstelle Produkte...")')
content.append('    ')
content.append('    cursor.execute("SELECT zustand_id, bezeichnung FROM zustand ORDER BY zustand_id")')
content.append('    zustands = {bz: zid for zid, bz in cursor.fetchall()}')
content.append('    ')
content.append('    cursor.execute("SELECT kategorie_id, slug FROM kategorie ORDER BY slug")')
content.append('    kategorien = {slug: kid for kid, slug in cursor.fetchall()}')
content.append('    ')
content.append('    cursor.execute("SELECT COUNT(*) AS anzahl FROM produkt")')
content.append('    produkt_count = cursor.fetchone()[0]')
content.append('    ')
content.append('    if produkt_count > 0:')
content.append("        print(f\"  Datenbank enthält bereits {produkt_count} Produkte!\")")
content.append("        print(f\"  Lösche existierende Produkte zuerst.\")")
content.append("        if input(\"  Fortsetzen? (Y/n): \").lower() in (\"n\", \"no\"):")
content.append('            print("Abgebrochen.")')
content.append('            return')
content.append('    ')
content.append('    cursor.execute("SELECT COALESCE(MAX(laufende_nr), 0) FROM produkt")')
content.append('    aktuelle_nr = cursor.fetchone()[0]')
content.append('    ')
content.append('    successful = 0')
content.append('    failed = 0')
content.append('    ')
content.append('    for produkt in PRODUKTE:')
content.append('        aktuelle_nr += 1')
content.append('        produkt_id = str(uuid.uuid4())')
content.append('        ')
content.append('        bezeichnung = produkt["bezeichnung"]')
content.append('        kategorie_slug = produkt["kategorie_slug"]')
content.append('        preis = produkt["preis"]')
content.append('        info = produkt["info"]')
content.append('        lagerbestand = produkt["lagerbestand"]')
content.append('        ')
content.append('        cursor.execute("SELECT produkt_id FROM produkt WHERE bezeichnung = %s", (bezeichnung,))')
content.append('        if cursor.fetchone():')
content.append("            print(f\"  Produkt '{bezeichnung}' existiert bereits, übersprungen.\")")
content.append('            failed += 1')
content.append('            continue')
content.append('        ')
content.append('        if kategorie_slug not in kategorien:')
content.append("            print(f\"  Kategorie '{kategorie_slug}' nicht gefunden für '{bezeichnung}', übersprungen.\")")
content.append('            failed += 1')
content.append('            continue')
content.append('        ')
content.append('        kategorie_id = kategorien[kategorie_slug]')
content.append('        zustand_id = list(zustands.keys())[2]  # Standard: \"Gut\" (Index 2)')
content.append('        ')
content.append('        try:')
content.append("            slug = bezeichnung.lower().replace(\" \", \"-\").replace(\"'\", \"\").replace(\"ß\", \"ss\")[:50]")
content.append('            cursor.execute(')
content.append('                "INSERT INTO produkt (produkt_id, laufende_nr, erstellungsdatum, bezeichnung, slug, produkt_info, preis, produkt_rabatt, produkt_aktiv, lagerbestand, zustand_id, kategorie_id) VALUES (%s, %s, NOW(), %s, %s, %s, %s, %s, %s, %s, %s, %s)",')
content.append('                (')
content.append('                    produkt_id,')
content.append('                    aktuelle_nr,')
content.append('                    bezeichnung,')
content.append('                    slug,')
content.append('                    info,')
content.append('                    preis,')
content.append('                    Decimal("0.00"),')
content.append('                    True,')
content.append('                    lagerbestand,')
content.append('                    zustand_id,')
content.append('                    kategorie_id,')
content.append('                ),')
content.append('            )')
content.append("            print(f\"  Produkt '{bezeichnung}' ({preis}€) erstellt\")")
content.append('            successful += 1')
content.append('        except Exception as e:')
content.append("            print(f\"  Fehler bei '{bezeichnung}': {e}\")")
content.append('            failed += 1')
content.append('    ')
content.append('    conn.commit()')
content.append(f'    print(f"\\nProdukte fertiggestellt: {{successful}} erstellt, {{failed}} übersprungen/fehlgeschlagen.")')
content.append(f'    print(f"Gesamtanzahl Produkte in Datenbank: {{produkt_count + successful}}\\n")')
content.append('')
content.append('')
content.append('def main():')
content.append('    print("=" * 60)')
content.append('    print("ThriftShop Datenbank-Seed")')
content.append('    print("=" * 60)')
content.append('    print()')
content.append('    ')
content.append('    conn = get_db_connection()')
content.append('    cursor = conn.cursor()')
content.append('    ')
content.append('    try:')
content.append('        erstelle_zustaende(cursor)')
content.append('        erstelle_kategorien(cursor)')
content.append('        erstelle_produkte(cursor, conn)')
content.append('        ')
content.append('        print("=" * 60)')
content.append('        print("Seed abgeschlossen!")')
content.append('        print("=" * 60)')
content.append('    except Exception as e:')
content.append('        print(f"\\nFehler: {e}")')
content.append('        conn.rollback()')
content.append('        raise')
content.append('    finally:')
content.append('        cursor.close()')
content.append('        conn.close()')
content.append('')
content.append('')
content.append('if __name__ == "__main__":')
content.append('    main()')
content.append('')

with open('/Users/marceloruediger/code/thriftshop/backend/seed_produkte.py', 'w', encoding='utf-8') as f:
    f.write('\n'.join(content))

print('Datei erfolgreich geschrieben.')
