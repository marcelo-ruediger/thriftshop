from dataclasses import dataclass
from decimal import Decimal
from uuid import UUID

from app.services import preise


@dataclass
class Bestellposition:
    bestellposition_id: UUID
    menge: int
    einzelpreis_gebucht: Decimal  # Brutto-Listenpreis zum Kaufzeitpunkt
    rabatt_angewendet: Decimal  # Rabatt in Euro pro Stück
    steuersatz_gebucht: Decimal  # Prozent
    produkt_id: UUID  # FK Produkt
    bestellung_id: UUID  # FK Bestellung
    # Aus dem Produkt mitgeladen (JOIN) - nur für die Anzeige
    bezeichnung: str | None = None
    slug: str | None = None
    bildpfad: str | None = None

    @property
    def gesamtpreis_brutto(self) -> Decimal:
        """Preis der Position inklusive Mehrwertsteuer."""
        return (self.einzelpreis_gebucht - self.rabatt_angewendet) * self.menge

    @property
    def mwst_betrag(self) -> Decimal:
        """In der Position enthaltene Mehrwertsteuer."""
        return preise.enthaltene_mwst(self.gesamtpreis_brutto, self.steuersatz_gebucht)

    @property
    def gesamtpreis_netto(self) -> Decimal:
        """Preis der Position ohne Mehrwertsteuer."""
        return self.gesamtpreis_brutto - self.mwst_betrag
