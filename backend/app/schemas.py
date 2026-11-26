"""
Pydantic-Schemas - validieren eingehende Anfragen und legen fest, welche Felder die API ausgibt.

Die Ausgabeschemas lesen direkt aus den Dataclasses (`from_attributes`). So gelangt z.B.
der Passwort-Hash nie in eine Antwort, weil er in keinem Schema vorkommt.
"""

from datetime import datetime
from decimal import Decimal
from typing import Annotated, Literal
from uuid import UUID

from pydantic import AfterValidator, BaseModel, ConfigDict, EmailStr, Field, StringConstraints

Text = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1)]
Name = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=50)]


def _hoechstens_72_bytes(wert: str) -> str:
    # bcrypt verarbeitet höchstens 72 Bytes - Umlaute und Emojis zählen mehrfach
    if len(wert.encode()) > 72:
        raise ValueError("Das Passwort ist zu lang")
    return wert


Passwort = Annotated[
    str, StringConstraints(min_length=8, max_length=72), AfterValidator(_hoechstens_72_bytes)
]
Prozent = Annotated[Decimal, Field(ge=0, lt=100, decimal_places=2)]
Betrag = Annotated[Decimal, Field(gt=0, lt=1_000_000, decimal_places=2)]

Rolle = Literal["Administrator", "Mitarbeiter", "Kunde"]
Bestellstatus = Literal["Offen", "In Bearbeitung", "Abgeschlossen", "Storniert", "Erstattet"]
Zahlungsart = Literal["Zahlung bei Abholung", "Rechnung"]


class Ausgabe(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# --- Benutzer & Authentifizierung -------------------------------------------


class RegistrierungAnfrage(BaseModel):
    vorname: Name
    nachname: Name
    email: EmailStr
    telefon: Annotated[str, StringConstraints(strip_whitespace=True, max_length=30)] | None = None
    passwort: Passwort


class LoginAnfrage(BaseModel):
    email: EmailStr
    passwort: str


class ProfilAnfrage(BaseModel):
    vorname: Name
    nachname: Name
    email: EmailStr
    telefon: Annotated[str, StringConstraints(strip_whitespace=True, max_length=30)] | None = None


class PasswortAnfrage(BaseModel):
    aktuelles_passwort: str
    neues_passwort: Passwort


class RolleAnfrage(BaseModel):
    rolle: Rolle


class BenutzerAusgabe(Ausgabe):
    benutzer_id: UUID
    vorname: str
    nachname: str
    email: str
    telefon: str | None
    rolle: str
    erstellt_am: datetime | None
    letzter_login: datetime | None


class TokenAusgabe(BaseModel):
    access_token: str
    token_type: str = "bearer"
    benutzer: BenutzerAusgabe


# --- Stammdaten ---------------------------------------------------------------


class ZustandAnfrage(BaseModel):
    bezeichnung: Text
    beschreibung: Text


class ZustandAusgabe(Ausgabe):
    zustand_id: UUID
    bezeichnung: str
    beschreibung: str


class KategorieAnfrage(BaseModel):
    bezeichnung: Text
    kategorie_rabatt: Prozent = Decimal("0")
    steuersatz: Prozent = Decimal("19")


class KategorieAusgabe(Ausgabe):
    kategorie_id: UUID
    bezeichnung: str
    slug: str
    kategorie_rabatt: float
    steuersatz: float


# --- Produkte -----------------------------------------------------------------


class ProduktAnfrage(BaseModel):
    bezeichnung: Annotated[str, StringConstraints(strip_whitespace=True, min_length=2, max_length=120)]
    produkt_info: Text
    preis: Betrag
    produkt_rabatt: Prozent = Decimal("0")
    # Ohne Angabe: neues Produkt = 1, bestehendes Produkt = Bestand bleibt unverändert.
    # So überschreibt das Speichern eines Formulars keinen Bestand, den Bestellungen
    # inzwischen verändert haben.
    lagerbestand: int | None = Field(None, ge=0, le=100_000)
    zustand_id: UUID
    kategorie_id: UUID
    bildpfad: str | None = None
    produkt_aktiv: bool = True


class ProduktAusgabe(Ausgabe):
    produkt_id: UUID
    produktnr: str
    bezeichnung: str
    slug: str
    produkt_info: str
    preis: float
    produkt_rabatt: float
    rabatt_prozent: float
    endpreis: float
    steuersatz: float
    lagerbestand: int
    zustand_id: UUID
    kategorie_id: UUID
    bildpfad: str | None
    produkt_aktiv: bool
    erstellungsdatum: datetime


class SichtbarkeitAnfrage(BaseModel):
    produkt_aktiv: bool


class BildAusgabe(BaseModel):
    bildpfad: str


# --- Bestellungen -------------------------------------------------------------


class PositionAnfrage(BaseModel):
    produkt_id: UUID
    menge: int = Field(ge=1, le=99)


class BestellungAnfrage(BaseModel):
    positionen: list[PositionAnfrage] = Field(min_length=1, max_length=100)
    zahlungsart: Zahlungsart = "Zahlung bei Abholung"
    anmerkung: Annotated[str, StringConstraints(strip_whitespace=True, max_length=500)] | None = None
    # Summe, die dem Kunden angezeigt wurde. Weicht sie vom aktuellen Preis ab, wird
    # die Bestellung abgelehnt statt stillschweigend zu einem anderen Preis gebucht.
    erwartete_summe: Decimal | None = Field(None, ge=0)


class StatusAnfrage(BaseModel):
    status: Bestellstatus


class PositionAusgabe(Ausgabe):
    bestellposition_id: UUID
    produkt_id: UUID
    bezeichnung: str | None
    slug: str | None
    bildpfad: str | None
    menge: int
    einzelpreis_gebucht: float
    rabatt_angewendet: float
    steuersatz_gebucht: float
    gesamtpreis_brutto: float


class BestellungAusgabe(Ausgabe):
    bestellung_id: UUID
    bestellnr: str
    status: str
    bestelldatum: datetime
    zahlungsart: str
    anmerkung: str | None
    benutzer_id: UUID
    kunde_name: str | None
    kunde_email: str | None
    artikel_anzahl: int
    gesamtpreis: float
    enthaltene_mwst: float
    positionen: list[PositionAusgabe]


class StatistikAusgabe(BaseModel):
    umsatz: float
    bestellungen_gesamt: int
    bestellungen_je_status: dict[str, int]
    produkte_aktiv: int
    produkte_ausverkauft: int
    kunden: int
