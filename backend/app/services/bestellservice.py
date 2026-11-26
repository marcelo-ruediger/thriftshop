"""
Geschäftslogik für Bestellungen - Preisermittlung, Lagerbuchung und Statusübergänge.

Der Server ist die einzige Quelle für Preise: das Frontend sendet nur Produkt-IDs
und Mengen, Preis, Rabatt und Steuersatz werden hier aus der Datenbank gelesen.
"""

import sqlite3
from uuid import UUID, uuid4

from app.core.datenbank import jetzt
from app.dao.bestellung_dao import BestellungDAO
from app.dao.produkt_dao import ProduktDAO
from app.models import Benutzer, Bestellposition, Bestellung
from app.schemas import BestellungAnfrage

ERLAUBTE_UEBERGAENGE = {
    "Offen": ["In Bearbeitung", "Storniert"],
    "In Bearbeitung": ["Abgeschlossen", "Storniert"],
    "Abgeschlossen": ["Erstattet"],  # Rückgabe nach der Abholung
    "Storniert": ["Erstattet"],  # bereits bezahlte Rechnung wird zurückgezahlt
    "Erstattet": [],
}
# Bei diesen Statuswechseln (alt, neu) geht die Ware zurück ins Lager.
# Von "Storniert" nach "Erstattet" nicht - dort wurde sie bereits zurückgebucht.
_WARE_ZURUECK = {
    ("Offen", "Storniert"),
    ("In Bearbeitung", "Storniert"),
    ("Abgeschlossen", "Erstattet"),
}


class Bestellfehler(Exception):
    """Fachlicher Fehler - wird von der API als HTTP 409 bzw. 422 ausgegeben."""


class Statuskonflikt(Bestellfehler):
    """Eine andere Anfrage hat den Status der Bestellung inzwischen geändert."""


class Bestellservice:
    def __init__(self, db: sqlite3.Connection):
        self.db = db
        self.bestellungen = BestellungDAO(db)
        self.produkte = ProduktDAO(db)

    def bestellen(self, kunde: Benutzer, anfrage: BestellungAnfrage) -> Bestellung:
        """Legt eine Bestellung an und bucht die Ware aus - atomar in einer Transaktion."""
        # Gleiche Produkte zusammenfassen, damit die Bestandsprüfung stimmt
        mengen: dict[UUID, int] = {}
        for position in anfrage.positionen:
            mengen[position.produkt_id] = mengen.get(position.produkt_id, 0) + position.menge

        bestellung = Bestellung(
            bestellung_id=uuid4(),
            laufende_nr=0,  # vergibt die Datenbank
            status="Offen",
            bestelldatum=jetzt(),
            benutzer_id=kunde.benutzer_id,
            zahlungsart=anfrage.zahlungsart,
            anmerkung=anfrage.anmerkung or None,
        )
        try:
            # Schreibsperre von Anfang an: verhindert, dass zwei Kunden gleichzeitig das letzte Stück kaufen
            self.db.execute("BEGIN IMMEDIATE")
            for produkt_id, menge in mengen.items():
                produkt = self.produkte.get_nach_id(produkt_id)
                if produkt is None or not produkt.produkt_aktiv:
                    raise Bestellfehler("Ein Artikel ist nicht mehr verfügbar.")
                if not self.produkte.bestand_reduzieren(produkt_id, menge):
                    raise Bestellfehler(
                        f"„{produkt.bezeichnung}“ ist nur noch {produkt.lagerbestand}× verfügbar."
                        if produkt.lagerbestand
                        else f"„{produkt.bezeichnung}“ ist leider ausverkauft."
                    )
                bestellung.positionen.append(
                    Bestellposition(
                        bestellposition_id=uuid4(),
                        menge=menge,
                        einzelpreis_gebucht=produkt.preis,
                        rabatt_angewendet=produkt.rabatt_betrag,
                        steuersatz_gebucht=produkt.steuersatz,
                        produkt_id=produkt_id,
                        bestellung_id=bestellung.bestellung_id,
                    )
                )
            if (
                anfrage.erwartete_summe is not None
                and anfrage.erwartete_summe != bestellung.gesamtpreis
            ):
                raise Bestellfehler(
                    "Ein Preis hat sich inzwischen geändert. Bitte prüfe deinen Warenkorb."
                )
            self.bestellungen.erstellen(bestellung)
            self.db.commit()
        except BaseException:
            self.db.rollback()
            raise
        return self.bestellungen.get_nach_id(bestellung.bestellung_id)

    def status_aendern(self, bestellung: Bestellung, neuer_status: str) -> Bestellung:
        """Wechselt den Status und bucht bei Storno/Erstattung die Ware zurück."""
        if neuer_status not in ERLAUBTE_UEBERGAENGE.get(bestellung.status, []):
            raise Bestellfehler(
                f"Übergang von „{bestellung.status}“ nach „{neuer_status}“ ist nicht erlaubt."
            )
        try:
            self.db.execute("BEGIN IMMEDIATE")
            # Die Prüfung oben lief auf einem möglicherweise veralteten Stand. Erst die
            # bedingte Änderung innerhalb der Transaktion stellt sicher, dass zwei
            # gleichzeitige Anfragen die Ware nicht doppelt zurückbuchen.
            if not self.bestellungen.status_aktualisieren(
                bestellung.bestellung_id, neuer_status, bisheriger_status=bestellung.status
            ):
                raise Statuskonflikt(
                    "Die Bestellung wurde gerade von jemand anderem geändert. Bitte lade die Seite neu."
                )
            if (bestellung.status, neuer_status) in _WARE_ZURUECK:
                for position in bestellung.positionen:
                    self.produkte.bestand_erhoehen(position.produkt_id, position.menge)
            self.db.commit()
        except BaseException:
            self.db.rollback()
            raise
        return self.bestellungen.get_nach_id(bestellung.bestellung_id)
