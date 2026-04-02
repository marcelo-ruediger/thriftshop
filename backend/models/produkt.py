from uuid import UUID
from dataclasses import dataclass, field
from datetime import datetime
from decimal import Decimal

@dataclass
class Produkt:
    produkt_id: UUID
    laufende_nr: int
    bezeichnung: str
    slug: str                       # Für die Website-URL
    produkt_info: str
    preis: Decimal
    produkt_rabatt: Decimal
    lagerbestand: int
    zustand_id: UUID            # FK Zustand
    kategorie_id: UUID          # FK Kategorie 
    produkt_aktiv: bool = True  # Defaukt Aktiv
    erstellungsdatum: datetime = field(default_factory=datetime.now)  # wird dynamisch generiert bei jeden Produkt() Instanz
    
    @property 
    def produktnr(self) -> str:
        """Erzeugt eine lesbare Produktnummer (z.B.: P00001) für die Verwaltung"""
        return f"P{self.laufende_nr:05d}"