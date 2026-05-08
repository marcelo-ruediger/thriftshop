"""
API-Routen für Benutzer - CRUD und Passwortverwaltung unter /benutzer.
"""

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from app.core.datenbank import get_db
from dao.benutzer_dao import BenutzerDAO
from models.benutzer import Benutzer
from uuid import UUID

router = APIRouter(prefix="/benutzer", tags=["Benutzer"])


def _benutzer_to_dict(benutzer: Benutzer) -> dict:
    """Konvertiert Benutzer-Objekt für JSON-Antwort mit Frontend-kompatiblen Feldnamen."""
    return {
        "benutzer_id": str(benutzer.benutzer_id),
        "vorname": benutzer.vorname,
        "nachname": benutzer.nachname,
        "email": benutzer.email,
        "telefonnummer": benutzer.telefon,
        "passwort_hash": benutzer.passwort_hash,
        "rolle": benutzer.rolle,
        "erstellt_am": benutzer.erstellt_am.isoformat() if benutzer.erstellt_am else None,
        "letzte_aenderung": benutzer.letzte_aenderung.isoformat() if benutzer.letzte_aenderung else None,
        "letzter_login": benutzer.letzter_login.isoformat() if benutzer.letzter_login else None,
    }


@router.get("/")
def alle_benutzer_abrufen(limit: int = 50, offset: int = 0, db=Depends(get_db)):
    """Gibt alle Benutzer paginiert zurück - Admin-Dashboard."""
    dao = BenutzerDAO(db)
    return [_benutzer_to_dict(u) for u in dao.get_alle(limit=limit, offset=offset)]


@router.get("/{benutzer_id}")
def benutzer_abrufen(benutzer_id: UUID, db=Depends(get_db)):
    """Gibt einen einzelnen Benutzer anhand der UUID zurück."""
    dao = BenutzerDAO(db)
    benutzer = dao.get_nach_id(benutzer_id)
    if not benutzer:
        raise HTTPException(status_code=404, detail="Benutzer nicht gefunden")
    return _benutzer_to_dict(benutzer)


@router.post("/", status_code=201)
def benutzer_erstellen(benutzer: Benutzer, db=Depends(get_db)):
    """Legt einen neuen Benutzer an (Registrierung)."""
    dao = BenutzerDAO(db)
    dao.erstellen(benutzer)
    return _benutzer_to_dict(benutzer)


@router.put("/{benutzer_id}")
def benutzer_aktualisieren(benutzer_id: UUID, benutzer: Benutzer, db=Depends(get_db)):
    """Aktualisiert die Stammdaten eines Benutzers."""
    dao = BenutzerDAO(db)
    dao.aktualisieren_stammdaten(benutzer)
    return _benutzer_to_dict(benutzer)


@router.patch("/{benutzer_id}/passwort")
def passwort_setzen(benutzer_id: UUID, neues_passwort_hash: str, db=Depends(get_db)):
    """Setzt einen neuen Passwort-Hash."""
    dao = BenutzerDAO(db)
    dao.passwort_setzen(benutzer_id, neues_passwort_hash)
    return {"benutzer_id": str(benutzer_id), "passwort_aktualisiert": True}


@router.delete("/{benutzer_id}", status_code=204)
def benutzer_loeschen(benutzer_id: UUID, db=Depends(get_db)):
    """Löscht einen Benutzer (DSGVO)."""
    dao = BenutzerDAO(db)
    dao.loeschen(benutzer_id)
