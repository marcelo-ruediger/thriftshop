from uuid import UUID
from dataclasses import dataclass
from decimal import Decimal

@dataclass
class Bestellposition:
    bestellposition_id: UUID
    menge: int
    einzelpreis_gebucht: Decimal
    rabatt_angewendet: Decimal
    steuersatz_gebucht: Decimal
    produkt_id: UUID                # FK Produkt
    bestellung_id: UUID             # FK Bestellung 

    @property
    def gesamtpreis_netto(self) -> Decimal: 
        """Berechnet den Preis vor Steuern für diese Position"""
        return (self.einzelpreis_gebucht - self.rabatt_angewendet) * self.menge 
    
    @property
    def gesamtpreis_brutto(self) -> Decimal:
        """"Berechnet den Preis inklusiv Steuern"""
        steuer_faktor = Decimal("1") + (self.steuersatz_gebucht/ Decimal("100"))
        return self.gesamtpreis_netto * steuer_faktor