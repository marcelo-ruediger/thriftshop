"""
Preislogik - Rabatte und Mehrwertsteuer.

Regeln:
- Alle Preise sind Bruttopreise (inkl. MwSt.), wie im Endkundengeschäft üblich.
- Rabatte sind Prozentwerte. Produkt- und Kategorierabatt werden nicht addiert,
  es gilt der höhere von beiden.
"""

from decimal import ROUND_HALF_UP, Decimal

CENT = Decimal("0.01")
HUNDERT = Decimal("100")


def runden(betrag: Decimal) -> Decimal:
    """Kaufmännisches Runden auf ganze Cent."""
    return betrag.quantize(CENT, rounding=ROUND_HALF_UP)


def rabatt_prozent(produkt_rabatt: Decimal, kategorie_rabatt: Decimal) -> Decimal:
    """Wirksamer Rabatt in Prozent - der höhere von Produkt- und Kategorierabatt."""
    return max(produkt_rabatt, kategorie_rabatt, Decimal("0"))


def rabatt_betrag(preis: Decimal, prozent: Decimal) -> Decimal:
    """Rabatt in Euro pro Stück."""
    return runden(preis * prozent / HUNDERT)


def enthaltene_mwst(brutto: Decimal, steuersatz: Decimal) -> Decimal:
    """Im Bruttobetrag enthaltene Mehrwertsteuer."""
    return runden(brutto * steuersatz / (HUNDERT + steuersatz))
