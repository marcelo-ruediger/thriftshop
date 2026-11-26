from dataclasses import dataclass, field
from datetime import datetime
from decimal import Decimal
from uuid import UUID

from .bestellposition import Bestellposition


@dataclass
class Bestellung:
    bestellung_id: UUID
    laufende_nr: int
    status: str
    bestelldatum: datetime
    benutzer_id: UUID  # FK Benutzer
    zahlungsart: str = "Zahlung bei Abholung"
    anmerkung: str | None = None
    positionen: list[Bestellposition] = field(default_factory=list)
    # Aus dem Benutzer mitgeladen (JOIN) - für die Bestellverwaltung
    kunde_name: str | None = None
    kunde_email: str | None = None

    @property
    def bestellnr(self) -> str:
        """Lesbare Bestellnummer (z.B. B00001)."""
        return f"B{self.laufende_nr:05d}"

    @property
    def gesamtpreis(self) -> Decimal:
        return sum((p.gesamtpreis_brutto for p in self.positionen), Decimal("0"))

    @property
    def enthaltene_mwst(self) -> Decimal:
        return sum((p.mwst_betrag for p in self.positionen), Decimal("0"))

    @property
    def artikel_anzahl(self) -> int:
        return sum(p.menge for p in self.positionen)
