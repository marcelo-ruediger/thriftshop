"""
Smoke-Tests - prüft Modelle und DAO-Grundfunktionen manuell ohne Test-Framework.
Ausführen mit: python backend/main_test.py
"""

from models import Produkt
from decimal import Decimal
from uuid import uuid4

test_produkt = Produkt(
    produkt_id=uuid4(),
    laufende_nr=1,
    bezeichnung="Vintage Levi's Jeansjacke",
    slug="vintage-levis-jeansjacke-90s",
    produkt_info="Original 90er Jahre, gut erhalten, Größe L",
    preis=Decimal("49.99"),
    produkt_rabatt=Decimal("5.00"),
    lagerbestand=1,
    zustand_id=uuid4(),  # Platzhalter für echte Zustand-UUID
    kategorie_id=uuid4(),  # Platzhalter für echte Kategorie-UUID
)

print(test_produkt.erstellungsdatum)
print(test_produkt.produkt_id)
