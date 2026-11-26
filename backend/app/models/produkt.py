from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from uuid import UUID

from app.services import preise


@dataclass
class Produkt:
    produkt_id: UUID
    laufende_nr: int
    bezeichnung: str
    slug: str  # Für die Website-URL
    produkt_info: str
    preis: Decimal  # Bruttopreis ohne Rabatt
    produkt_rabatt: Decimal  # Prozent
    lagerbestand: int
    zustand_id: UUID  # FK Zustand
    kategorie_id: UUID  # FK Kategorie
    erstellungsdatum: datetime
    bildpfad: str | None = None  # Dateiname des Produktbilds (z.B. "005_jacke1.webp")
    produkt_aktiv: bool = True
    # Aus der Kategorie mitgeladen (JOIN), um den wirksamen Rabatt zu berechnen
    kategorie_rabatt: Decimal = Decimal("0")
    steuersatz: Decimal = Decimal("19")

    @property
    def produktnr(self) -> str:
        """Lesbare Produktnummer (z.B. P00001) für die Verwaltung."""
        return f"P{self.laufende_nr:05d}"

    @property
    def rabatt_prozent(self) -> Decimal:
        """Wirksamer Rabatt - der höhere von Produkt- und Kategorierabatt."""
        return preise.rabatt_prozent(self.produkt_rabatt, self.kategorie_rabatt)

    @property
    def rabatt_betrag(self) -> Decimal:
        return preise.rabatt_betrag(self.preis, self.rabatt_prozent)

    @property
    def endpreis(self) -> Decimal:
        """Preis, den der Kunde tatsächlich bezahlt."""
        return self.preis - self.rabatt_betrag
