from dataclasses import dataclass
from decimal import Decimal
from uuid import UUID


@dataclass
class Kategorie:
    kategorie_id: UUID
    bezeichnung: str
    slug: str  # Für die Website-URL
    kategorie_rabatt: Decimal = Decimal("0")  # Prozent
    steuersatz: Decimal = Decimal("19")  # Prozent
