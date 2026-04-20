"""
API-Routen für Bestellungen - CRUD und Statusverwaltung unter /bestellungen.
"""

from fastapi import APIRouter, Depends, HTTPException
from app.core.datenbank import get_db
from app.core.sicherheit import aktueller_benutzer, erfordert_rolle
from dao.bestellung_dao import BestellungDAO
from dao.bestellposition_dao import BestellpositionDAO
from models.bestellung import Bestellung
from models.bestellposition import Bestellposition
from uuid import UUID

router = APIRouter(prefix="/bestellungen", tags=["Bestellungen"])


@router.get("/meine-bestellungen")
def meine_bestellungen(benutzer=Depends(aktueller_benutzer), db=Depends(get_db)):
    """Gibt alle Bestellungen des eingeloggten Kunden zurück."""
    dao = BestellungDAO(db)
    return dao.get_nach_benutzer(benutzer.benutzer_id)


@router.patch("/{bestellung_id}/stornieren")
def bestellung_stornieren(
    bestellung_id: UUID,
    benutzer=Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Kunde storniert seine eigene Bestellung - nur wenn Status 'Offen'."""
    dao = BestellungDAO(db)
    bestellung = dao.get_nach_id(bestellung_id)

    if not bestellung:
        raise HTTPException(status_code=404, detail="Bestellung nicht gefunden")

    # Sicherheitsprüfung: Bestellung gehört dem eingeloggten Benutzer?
    if bestellung.benutzer_id != benutzer.benutzer_id:
        raise HTTPException(status_code=403, detail="Keine Berechtigung")

    # Nur "Offen" kann storniert werden
    if bestellung.status != "Offen":
        raise HTTPException(
            status_code=422,
            detail=f"Bestellung mit Status '{bestellung.status}' kann nicht storniert werden",
        )

    dao.status_aktualisieren(bestellung_id, "Storniert")
    return {"bestellung_id": str(bestellung_id), "status": "Storniert"}


@router.get("/")
def alle_bestellungen_abrufen(
    limit: int = 50,
    offset: int = 0,
    _benutzer=Depends(erfordert_rolle("Administrator", "Mitarbeiter")),
    db=Depends(get_db),
):
    """Gibt alle Bestellungen paginiert zurück - Admin-Dashboard."""
    dao = BestellungDAO(db)
    return dao.get_alle(limit=limit, offset=offset)


@router.get("/benutzer/{benutzer_id}")
def bestellungen_nach_benutzer(
    benutzer_id: UUID,
    _benutzer=Depends(erfordert_rolle("Administrator", "Mitarbeiter")),
    db=Depends(get_db),
):
    """Gibt die Bestellhistorie eines Kunden zurück."""
    dao = BestellungDAO(db)
    return dao.get_nach_benutzer(benutzer_id)


@router.get("/status/{status}")
def bestellungen_nach_status(
    status: str,
    _benutzer=Depends(erfordert_rolle("Administrator", "Mitarbeiter")),
    db=Depends(get_db),
):
    """Gibt alle Bestellungen mit einem bestimmten Status zurück."""
    dao = BestellungDAO(db)
    return dao.get_nach_status(status)


@router.get("/{bestellung_id}")
def bestellung_abrufen(
    bestellung_id: UUID, benutzer=Depends(aktueller_benutzer), db=Depends(get_db)
):
    """Gibt eine einzelne Bestellung anhand der UUID zurück."""
    dao = BestellungDAO(db)
    bestellung = dao.get_nach_id(bestellung_id)
    if not bestellung:
        raise HTTPException(status_code=404, detail="Bestellung nicht gefunden")
    return bestellung


@router.post("/", status_code=201)
def bestellung_erstellen(
    bestellung: Bestellung,
    positionen: list[Bestellposition],
    _benutzer=Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Legt eine neue Bestellung mit allen Positionen an (atomar)."""
    bestell_dao = BestellungDAO(db)
    position_dao = BestellpositionDAO(db)
    bestell_dao.erstellen(bestellung)
    position_dao.erstellen_mehrere(positionen)
    return bestellung


ERLAUBTE_UEBERGAENGE = {
    "Offen": ["In Bearbeitung", "Storniert"],
    "In Bearbeitung": ["Abgeschlossen", "Storniert"],
    "Abgeschlossen": [],
    "Storniert": ["Erstattet"],
    "Erstattet": [],
}


@router.patch("/{bestellung_id}/status")
def status_aktualisieren(
    bestellung_id: UUID,
    neuer_status: str,
    _benutzer=Depends(erfordert_rolle("Administrator", "Mitarbeiter")),
    db=Depends(get_db),
):
    """Ändert den Status einer Bestellung."""
    dao = BestellungDAO(db)
    bestellung = dao.get_nach_id(bestellung_id)
    if not bestellung:
        raise HTTPException(status_code=404, detail="Bestellung nicht gefunden")

    erlaubt = ERLAUBTE_UEBERGAENGE.get(bestellung.status, [])
    if neuer_status not in erlaubt:
        raise HTTPException(
            status_code=422,
            detail=f"Übergang von '{bestellung.status}' nach '{neuer_status}' nicht erlaubt",
        )

    dao.status_aktualisieren(bestellung_id, neuer_status)
    return {"bestellung_id": str(bestellung_id), "status": neuer_status}
