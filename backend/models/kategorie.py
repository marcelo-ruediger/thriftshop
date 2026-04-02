from uuid import UUID
from dataclasses import dataclass
from decimal import Decimal

@dataclass
class Kategorie:
    kategorie_id: UUID
    bezeichnung: str
    slug: str                   # Für die Website-URL
    kategorie_rabatt: Decimal
    steuersatz: Decimal
    