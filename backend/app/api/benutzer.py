"""
API-Routen für die Benutzerverwaltung unter /benutzer - nur für Administratoren.
"""

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.fehler import nicht_gefunden
from app.core.config import einstellungen
from app.core.datenbank import get_db
from app.core.sicherheit import erfordert_admin
from app.dao.benutzer_dao import BenutzerDAO
from app.models import Benutzer
from app.schemas import BenutzerAusgabe, RolleAnfrage
from app.seed import DEMO_EMAILS

router = APIRouter(prefix="/benutzer", tags=["Benutzer"])


@router.get("", response_model=list[BenutzerAusgabe])
def alle_benutzer_abrufen(_admin=Depends(erfordert_admin), db=Depends(get_db)):
    """Gibt alle Benutzerkonten zurück."""
    return BenutzerDAO(db).get_alle()


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
    if einstellungen.demo_modus and benutzer.email.lower() in DEMO_EMAILS:
        raise HTTPException(
            status.HTTP_403_FORBIDDEN,
            detail="Die Rollen der Demo-Konten sind fest – registriere ein eigenes Konto zum Ausprobieren.",
        )
    benutzer.rolle = anfrage.rolle
    dao.aktualisieren_stammdaten(benutzer)
    return benutzer
