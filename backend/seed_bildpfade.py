"""
Skript zur Zuordnung von Produktbildern zu den Produkten in der Datenbank.
Erkennt den Produkttyp basierend auf Keywords im Namen und weist das passende Bild zu.
"""

import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

# Mapping von Produkt-Keywords zu Bild-Dateien
PRODUKT_BILD_ZUORDNUNG = {
    # Gürtel
    "Gürtel": ["001_gel1.png", "002_gel2.png"],
    # Hosen
    "Hose": ["003_hose1.png", "004_hose2.png"],
    # Jacken
    "Jacke": ["005_jacke1.png", "006_jacke2.png", "011_jacke3.png"],
    "jacke": ["005_jacke1.png", "006_jacke2.png", "011_jacke3.png"],
    # Radios
    "Radio": ["007_radio1.png", "008_radio2.png"],
    # T-Shirts
    "T-Shirt": ["009_tshirts2.png", "010_tshits1.png"],
    # Taschen
    "tasche": ["012_tasche1.png", "013_tasche2.png", "014_tasche3.png"],
    "Tasche": ["012_tasche1.png", "013_tasche2.png", "014_tasche3.png"],
    # Geldbeutel
    "Geldbeutel": ["015_geldbeutel1.png", "016_geldbeutel2.png"],
    "Portemonnaie": ["015_geldbeutel1.png", "016_geldbeutel2.png"],
    # Pullover
    "Pullover": ["017_pullover1.png", "018_pullover2.png", "019_pullover3.png"],
    "pullover": ["017_pullover1.png", "018_pullover2.png", "019_pullover3.png"],
    # Socken
    "Socken": ["020_socken1.png", "021_socken2.png", "022_socken3.png"],
    "socken": ["020_socken1.png", "021_socken2.png", "022_socken3.png"],
    # Pyjamahose
    "Pyjamahose": ["023_pyjamahose1.png", "024_pyjamahose2.png"],
    # Röcke
    "Rock": ["025_rock1.png", "026_rock2.png", "027_rock3.png"],
    "rock": ["025_rock1.png", "026_rock2.png", "027_rock3.png"],
    # Kleider
    "Kleid": [
        "028_kleid1.png",
        "029_kleid2.png",
        "030_kleid3.png",
        "031_kleid4.png",
        "032_kleid5.png",
        "033_kleid6.png",
    ],
    "kleid": [
        "028_kleid1.png",
        "029_kleid2.png",
        "030_kleid3.png",
        "031_kleid4.png",
        "032_kleid5.png",
        "033_kleid6.png",
    ],
    "Bluse": [
        "028_kleid1.png",
        "029_kleid2.png",
        "030_kleid3.png",
        "031_kleid4.png",
        "032_kleid5.png",
        "033_kleid6.png",
    ],
    # Boots/Schuhe
    "Boot": [
        "034_boots1.png",
        "035_boots2.png",
        "036_boots3.png",
        "037_boots4.png",
        "038_sneakers1.png",
        "039_sneakers2.png",
        "040_boots5.png",
        "041_boots6.png",
        "042_boots7.png",
    ],
    "boot": [
        "034_boots1.png",
        "035_boots2.png",
        "036_boots3.png",
        "037_boots4.png",
        "038_sneakers1.png",
        "039_sneakers2.png",
        "040_boots5.png",
        "041_boots6.png",
        "042_boots7.png",
    ],
    "Sneaker": [
        "034_boots1.png",
        "035_boots2.png",
        "036_boots3.png",
        "037_boots4.png",
        "038_sneakers1.png",
        "039_sneakers2.png",
        "040_boots5.png",
        "041_boots6.png",
        "042_boots7.png",
    ],
    "sneaker": [
        "034_boots1.png",
        "035_boots2.png",
        "036_boots3.png",
        "037_boots4.png",
        "038_sneakers1.png",
        "039_sneakers2.png",
        "040_boots5.png",
        "041_boots6.png",
        "042_boots7.png",
    ],
    "Stiefel": [
        "034_boots1.png",
        "035_boots2.png",
        "036_boots3.png",
        "037_boots4.png",
        "038_sneakers1.png",
        "039_sneakers2.png",
        "040_boots5.png",
        "041_boots6.png",
        "042_boots7.png",
    ],
    # Spielcontroller
    "Spielcontroller": ["043_spielcontroller.png"],
    # Videospiel
    "Videospiele": ["044_videospiel.png"],
    # Gitarren
    "Gitarre": ["045_gitarre1.png", "046_gitarre2.png"],
    "gitarre": ["045_gitarre1.png", "046_gitarre2.png"],
    # Tische
    "tisch": ["047_tisch1.png", "048_tisch2.png"],
    "Tisch": ["047_tisch1.png", "048_tisch2.png"],
    # Bürostühle
    "stuhl": ["049_buerostuhl1.png", "050_buerostuhl2.png"],
    "Stuhl": ["049_buerostuhl1.png", "050_buerostuhl2.png"],
}


def auflistung_erzeugen(cursor):
    """Liest alle Produkte aus der Datenbank."""
    cursor.execute(
        "SELECT produkt_id, bezeichnung, bildpfad FROM produkt WHERE bildpfad IS NULL ORDER BY bezeichnung"
    )
    return cursor.fetchall()


def bilddatei_finden(bezeichnung, beobachtete_bilder):
    """Findet eine passende Bilddatei basierend auf Keywords im Produktnamen."""
    name = bezeichnung.lower()
    for keyword, dateien in PRODUKT_BILD_ZUORDNUNG.items():
        if keyword.lower() in name:
            for datei in dateien:
                if datei not in beobachtete_bilder:
                    beobachtete_bilder[datei] = beobachtete_bilder.get(datei, 0) + 1
                    return datei
    return None


def bildpfade_zuordnen(cursor):
    """Ordnet Bildern Produkte zu und aktualisiert die Datenbank."""
    produkte = auflistung_erzeugen(cursor)
    beobachtete_bilder = {}
    aktualisierte = 0

    for produkt in produkte:
        produkt_id = produkt["produkt_id"]
        bezeichnung = produkt["bezeichnung"]

        # Finde eine passende Bilddatei
        bilddatei = bilddatei_finden(bezeichnung, beobachtete_bilder)

        if bilddatei:
            # Aktualisiere die Datenbank
            cursor.execute(
                "UPDATE produkt SET bildpfad = %s WHERE produkt_id = %s",
                (bilddatei, str(produkt_id)),
            )
            aktualisierte += 1
            print(f"✓ {bezeichnung} -> {bilddatei}")
        else:
            print(f"✗ Keine Zuordnung für: {bezeichnung}")

    return aktualisierte


def main():
    """Hauptfunktion."""
    try:
        conn = mysql.connector.connect(
            host="localhost", user="root", password=os.getenv("DB_PASSWORD")
        )
        cursor = conn.cursor(dictionary=True)
        cursor.execute("USE thriftshop")

        # Prüfe wie viele Produkte ohne Bild sind
        cursor.execute("SELECT COUNT(*) as anzahl FROM produkt WHERE bildpfad IS NULL")
        anzahl = cursor.fetchone()["anzahl"]
        print(f"Produkte ohne Bild: {anzahl}")
        print()

        # Führe die Zuordnung durch
        aktualisierte = bildpfade_zuordnen(cursor)

        # Commit
        conn.commit()
        cursor.close()
        conn.close()

        print()
        print(
            f"Fertig! {aktualisierte} von {anzahl} Produkten wurden einem Bild zugeordnet."
        )

    except Exception as e:
        print(f"Fehler: {e}")


if __name__ == "__main__":
    main()
