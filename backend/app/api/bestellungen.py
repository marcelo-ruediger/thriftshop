"""
API-Routen für Bestellungen unter /bestellungen.

Kunden sehen und stornieren nur ihre eigenen Bestellungen. Die Bestellverwaltung
(alle Bestellungen, Statuswechsel, Kennzahlen) erfordert Mitarbeiter oder Administrator.
"""

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query

from app.api.fehler import konflikt, nicht_gefunden
from app.core.datenbank import get_db
from app.core.sicherheit import PERSONAL, aktueller_benutzer, erfordert_personal
from app.dao.bestellung_dao import BestellungDAO
from app.models import Benutzer, Bestellung
from app.schemas import (
    BestellungAnfrage,
    BestellungAusgabe,
    Bestellstatus,
    StatistikAusgabe,
    StatusAnfrage,
)
from app.services import demo
from app.services.bestellservice import Bestellfehler, Bestellservice, Statuskonflikt

router = APIRouter(prefix="/bestellungen", tags=["Bestellungen"])


def _ausgabe(bestellung: Bestellung, betrachter: Benutzer) -> BestellungAusgabe:
    """Im Demo-Modus sieht das öffentliche Personal-Konto fremde Kundendaten nur maskiert."""
    ausgabe = BestellungAusgabe.model_validate(bestellung)
    if bestellung.benutzer_id != betrachter.benutzer_id and demo.verbirgt_daten(
        betrachter, bestellung.kunde_email
    ):
        ausgabe.kunde_name = demo.name_kuerzen(bestellung.kunde_name or "")
        ausgabe.kunde_email = demo.email_maskieren(bestellung.kunde_email or "")
        if ausgabe.anmerkung:
            ausgabe.anmerkung = demo.AUSGEBLENDET
    return ausgabe


@router.post("", response_model=BestellungAusgabe, status_code=201)
def bestellung_erstellen(
    anfrage: BestellungAnfrage,
    benutzer: Benutzer = Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Legt eine Bestellung für den eingeloggten Benutzer an.

    Erwartet nur Produkt-IDs und Mengen - Preise, Rabatte und Steuersätze
    ermittelt der Server. Antwortet mit 409, wenn ein Artikel nicht mehr verfügbar ist.
    """
    try:
        return Bestellservice(db).bestellen(benutzer, anfrage)
    except Bestellfehler as fehler:
        raise konflikt(str(fehler)) from fehler


@router.get("/meine", response_model=list[BestellungAusgabe])
def meine_bestellungen(benutzer: Benutzer = Depends(aktueller_benutzer), db=Depends(get_db)):
    """Gibt alle Bestellungen des eingeloggten Benutzers zurück."""
    return BestellungDAO(db).get_nach_benutzer(benutzer.benutzer_id)


@router.get("/statistik", response_model=StatistikAusgabe)
def statistik(_personal=Depends(erfordert_personal), db=Depends(get_db)):
    """Kennzahlen für das Admin-Dashboard."""
    return BestellungDAO(db).statistik()


@router.get("", response_model=list[BestellungAusgabe])
def alle_bestellungen_abrufen(
    status: Bestellstatus | None = None,
    limit: int = Query(200, ge=1, le=500),
    offset: int = Query(0, ge=0),
    personal: Benutzer = Depends(erfordert_personal),
    db=Depends(get_db),
):
    """Gibt Bestellungen seitenweise zurück (neueste zuerst) - optional nach Status gefiltert."""
    bestellungen = BestellungDAO(db).get_alle(status, limit=limit, offset=offset)
    return [_ausgabe(bestellung, personal) for bestellung in bestellungen]


@router.get("/{bestellung_id}", response_model=BestellungAusgabe)
def bestellung_abrufen(
    bestellung_id: UUID,
    benutzer: Benutzer = Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Gibt eine Bestellung zurück - Kunden nur ihre eigene."""
    bestellung = BestellungDAO(db).get_nach_id(bestellung_id)
    # Fremde Bestellungen werden wie nicht existierende behandelt (kein Hinweis auf gültige IDs)
    if not bestellung or (
        bestellung.benutzer_id != benutzer.benutzer_id and benutzer.rolle not in PERSONAL
    ):
        raise nicht_gefunden("Bestellung")
    return _ausgabe(bestellung, benutzer)


@router.patch("/{bestellung_id}/stornieren", response_model=BestellungAusgabe)
def bestellung_stornieren(
    bestellung_id: UUID,
    benutzer: Benutzer = Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Kunde storniert seine eigene Bestellung - nur solange sie „Offen“ ist."""
    bestellung = BestellungDAO(db).get_nach_id(bestellung_id)
    if not bestellung or bestellung.benutzer_id != benutzer.benutzer_id:
        raise nicht_gefunden("Bestellung")
    if bestellung.status != "Offen":
        raise konflikt(
            f"Eine Bestellung mit Status „{bestellung.status}“ kann nicht mehr storniert werden"
        )
    try:
        return Bestellservice(db).status_aendern(bestellung, "Storniert")
    except Bestellfehler as fehler:
        raise konflikt(str(fehler)) from fehler


@router.patch("/{bestellung_id}/status", response_model=BestellungAusgabe)
def status_aktualisieren(
    bestellung_id: UUID,
    anfrage: StatusAnfrage,
    personal: Benutzer = Depends(erfordert_personal),
    db=Depends(get_db),
):
    """Ändert den Status einer Bestellung entlang der erlaubten Übergänge."""
    bestellung = BestellungDAO(db).get_nach_id(bestellung_id)
    if not bestellung:
        raise nicht_gefunden("Bestellung")
    try:
        return _ausgabe(Bestellservice(db).status_aendern(bestellung, anfrage.status), personal)
    except Statuskonflikt as fehler:
        raise konflikt(str(fehler)) from fehler
    except Bestellfehler as fehler:
        raise HTTPException(422, detail=str(fehler)) from fehler
