"""
Authentifizierungs-Endpunkte - Registrierung, Login und das eigene Profil unter /auth.
"""

from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, Response, status

from app.api.fehler import konflikt
from app.core.datenbank import get_db
from app.core.sicherheit import (
    ROLLE_ADMIN,
    ROLLE_KUNDE,
    aktueller_benutzer,
    passwort_hashen,
    passwort_pruefen,
    token_erstellen,
)
from app.dao.benutzer_dao import BenutzerDAO
from app.dao.bestellung_dao import BestellungDAO
from app.models import Benutzer
from app.schemas import (
    BenutzerAusgabe,
    LoginAnfrage,
    PasswortAnfrage,
    ProfilAnfrage,
    RegistrierungAnfrage,
    TokenAusgabe,
)
from app.services import demo
from app.services.bestellservice import Bestellservice

router = APIRouter(prefix="/auth", tags=["Authentifizierung"])


def _token_antwort(benutzer: Benutzer) -> TokenAusgabe:
    token = token_erstellen({"sub": str(benutzer.benutzer_id), "rolle": benutzer.rolle})
    return TokenAusgabe(access_token=token, benutzer=BenutzerAusgabe.model_validate(benutzer))


def _demo_konto_schuetzen(benutzer: Benutzer) -> None:
    """Die öffentlichen Demo-Konten sollen für alle Besucher nutzbar bleiben."""
    demo.demo_konto_schuetzen(
        benutzer,
        "Das ist ein Demo-Konto – E-Mail, Passwort und Löschung sind hier gesperrt. "
        "Registriere ein eigenes Konto, um diese Funktion auszuprobieren.",
    )


@router.post("/registrieren", response_model=TokenAusgabe, status_code=201)
def registrieren(anfrage: RegistrierungAnfrage, db=Depends(get_db)):
    """Legt ein neues Kundenkonto an und meldet es direkt an.

    Die Rolle ist immer „Kunde“ - höhere Rollen vergibt nur ein Administrator.
    """
    dao = BenutzerDAO(db)
    if dao.get_nach_email(anfrage.email.lower()):
        raise konflikt("Diese E-Mail-Adresse ist bereits registriert")

    benutzer = Benutzer(
        benutzer_id=uuid4(),
        vorname=anfrage.vorname,
        nachname=anfrage.nachname,
        email=anfrage.email.lower(),
        telefon=anfrage.telefon or None,
        passwort_hash=passwort_hashen(anfrage.passwort),
        rolle=ROLLE_KUNDE,
    )
    dao.erstellen(benutzer)
    return _token_antwort(benutzer)


@router.post("/login", response_model=TokenAusgabe)
def login(anfrage: LoginAnfrage, db=Depends(get_db)):
    """Prüft E-Mail und Passwort, gibt bei Erfolg einen JWT zurück."""
    dao = BenutzerDAO(db)
    # E-Mails werden kleingeschrieben gespeichert (auch Umlaute, die SQLite nicht angleicht)
    benutzer = dao.get_nach_email(anfrage.email.lower())
    if not benutzer or not passwort_pruefen(anfrage.passwort, benutzer.passwort_hash):
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED, detail="E-Mail oder Passwort ist falsch"
        )
    dao.letzter_login_setzen(benutzer.benutzer_id)
    return _token_antwort(benutzer)


@router.get("/me", response_model=BenutzerAusgabe)
def profil_aktuell(benutzer: Benutzer = Depends(aktueller_benutzer)):
    """Gibt die Daten des aktuell eingeloggten Benutzers zurück."""
    return benutzer


@router.put("/profil", response_model=BenutzerAusgabe)
def profil_bearbeiten(
    anfrage: ProfilAnfrage,
    benutzer: Benutzer = Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Aktualisiert die eigenen Stammdaten. Die Benutzer-ID stammt aus dem Token."""
    dao = BenutzerDAO(db)
    neue_email = anfrage.email.lower()
    if neue_email != benutzer.email.lower():
        _demo_konto_schuetzen(benutzer)
        if dao.get_nach_email(neue_email):
            raise konflikt("Diese E-Mail-Adresse ist bereits vergeben")

    benutzer.vorname = anfrage.vorname
    benutzer.nachname = anfrage.nachname
    benutzer.email = neue_email
    benutzer.telefon = anfrage.telefon or None
    dao.aktualisieren_stammdaten(benutzer)
    return benutzer


@router.put("/passwort", status_code=204)
def passwort_aendern(
    anfrage: PasswortAnfrage,
    benutzer: Benutzer = Depends(aktueller_benutzer),
    db=Depends(get_db),
):
    """Ändert das eigene Passwort - das aktuelle Passwort muss bestätigt werden."""
    _demo_konto_schuetzen(benutzer)
    if not passwort_pruefen(anfrage.aktuelles_passwort, benutzer.passwort_hash):
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, detail="Das aktuelle Passwort ist falsch"
        )
    BenutzerDAO(db).passwort_setzen(
        benutzer.benutzer_id, passwort_hashen(anfrage.neues_passwort)
    )
    return Response(status_code=204)


@router.delete("/profil", status_code=204)
def profil_loeschen(benutzer: Benutzer = Depends(aktueller_benutzer), db=Depends(get_db)):
    """Löscht das eigene Konto (DSGVO - Recht auf Vergessenwerden).

    Gibt es Bestellungen, werden noch laufende storniert (die Ware geht zurück in den
    Shop), Anmerkungen und persönliche Daten entfernt und der Datensatz anonymisiert,
    damit die Buchhaltung konsistent bleibt.
    """
    _demo_konto_schuetzen(benutzer)
    dao = BenutzerDAO(db)
    if benutzer.rolle == ROLLE_ADMIN and dao.anzahl_administratoren() <= 1:
        raise konflikt(
            "Du bist der einzige Administrator. Vergib die Rolle zuerst an ein anderes Konto."
        )

    bestell_dao = BestellungDAO(db)
    bestellungen = bestell_dao.get_nach_benutzer(benutzer.benutzer_id)
    if not bestellungen:
        dao.loeschen(benutzer.benutzer_id)
        return Response(status_code=204)

    service = Bestellservice(db)
    for bestellung in bestellungen:
        if bestellung.status in ("Offen", "In Bearbeitung"):
            service.status_aendern(bestellung, "Storniert")
    bestell_dao.anmerkungen_entfernen(benutzer.benutzer_id)
    dao.anonymisieren(benutzer.benutzer_id)  # schließt die Transaktion ab
    return Response(status_code=204)
