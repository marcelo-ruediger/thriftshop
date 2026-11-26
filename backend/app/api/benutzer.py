"""
API-Routen für die Benutzerverwaltung unter /benutzer - nur für Administratoren.
"""

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.fehler import nicht_gefunden
from app.core.datenbank import get_db
from app.core.sicherheit import erfordert_admin
from app.dao.benutzer_dao import BenutzerDAO
from app.models import Benutzer
from app.schemas import BenutzerAusgabe, RolleAnfrage
from app.services import demo

router = APIRouter(prefix="/benutzer", tags=["Benutzer"])


def _ausgabe(benutzer: Benutzer, betrachter: Benutzer) -> BenutzerAusgabe:
    """Im Demo-Modus sieht das öffentliche Admin-Konto fremde Kontaktdaten nur maskiert."""
    ausgabe = BenutzerAusgabe.model_validate(benutzer)
    if demo.verbirgt_daten(betrachter, benutzer.email):
        ausgabe.nachname = f"{benutzer.nachname[:1]}."
        ausgabe.email = demo.email_maskieren(benutzer.email)
        ausgabe.telefon = None
    return ausgabe


@router.get("", response_model=list[BenutzerAusgabe])
def alle_benutzer_abrufen(admin: Benutzer = Depends(erfordert_admin), db=Depends(get_db)):
    """Gibt alle Benutzerkonten zurück."""
    return [_ausgabe(benutzer, admin) for benutzer in BenutzerDAO(db).get_alle()]


@router.patch("/{benutzer_id}/rolle", response_model=BenutzerAusgabe)
def rolle_aendern(
    benutzer_id: UUID,
    anfrage: RolleAnfrage,
    admin: Benutzer = Depends(erfordert_admin),
    db=Depends(get_db),
):
    """Vergibt eine Rolle (Kunde, Mitarbeiter, Administrator)."""
    if benutzer_id == admin.benutzer_id:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            detail="Die eigene Rolle kann nicht geändert werden",
        )
    dao = BenutzerDAO(db)
    benutzer = dao.get_nach_id(benutzer_id)
    if not benutzer:
        raise nicht_gefunden("Benutzer")
    demo.demo_konto_schuetzen(
        benutzer,
        "Die Rollen der Demo-Konten sind fest – registriere ein eigenes Konto zum Ausprobieren.",
    )
    benutzer.rolle = anfrage.rolle
    dao.aktualisieren_stammdaten(benutzer)
    return _ausgabe(benutzer, admin)
