## Ordnerstruktur

thriftshop_project/
├── frontend/                # View - Flutter App
│   ├── lib/                 # Dart Code
│   ├── pubspec.yaml
│   └── ...
├── backend/                 # Python API
│   ├── app/
│   │   ├── api/             # Controller / Routes (z.B. FastAPI oder Flask)
│   │   ├── core/            # Konfiguration (DB-Verbindung, Secrets)
│   │   ├── dao/             # Data Access Objects (SQL-Logik)
│   │   ├── models/          # Models - Datenstrukturen (@dataclass / Pydantic)
│   │   ├── services/        # Business Logik (Berechnungen, Regeln)
│   │   └── main.py          # Startpunkt der App
│   ├── tests/               # Unit- & Integrationtests
│   ├── requirements.txt     # Abhängigkeiten
│   └── .env                 # Umgebungsvariablen (DB_USER, PW)
├── docs/                    # Deine Obsidian-Notizen & Diagramme
└── docker-compose.yml       # Optional: Startet DB, Backend & Frontend zusammen

Pydantic -> Für API / Datenvalidierung


## TODO

### 1. Entwicklungsumgebung einrichten
- [x] Flutter SDK, Python, VS Code, MySQL lokal installieren
- [x] GitHub-Repository anlegen
- [x] Virtuelle Umgebung (`.venv`) einrichten

### 2. Datenbank aufsetzen
- [x] MySQL-Schema lokal erstellen (benutzer, produkt, kategorie, zustand, bestellung, bestellposition)
- [x] DAOs erstellen für alle Hauptklassen

### 3. FastAPI-Backend – Grundstruktur
- [x] Projektstruktur anlegen, Datenbankverbindung herstellen
- [x] CRUD-Endpunkte für alle Entitäten (Produkte, Kategorien, Zustände, Benutzer, Bestellungen, Bestellpositionen)

### 4. Authentifizierung & Rollen
- [x] `POST /auth/registrieren` – Benutzer anlegen, Passwort mit bcrypt hashen
- [x] `POST /auth/login` – E-Mail + Passwort prüfen, JWT zurückgeben
- [x] `Depends(aktueller_benutzer)` – Token aus Header lesen & validieren
- [x] `erfordert_rolle()` – Rollenprüfung (Administrator / Mitarbeiter / Kunde)

### 5. Bestellsystem im Backend
- [x] Endpunkte für Bestellungen (`POST /bestellungen`, `PATCH /bestellungen/{id}/status`)
- [x] Statusübergänge mit Validierung (`ERLAUBTE_UEBERGAENGE`)
- [x] Stornierung durch Kunden (`PATCH /bestellungen/{id}/stornieren`)

### 6. Tests – Backend
- [x] Unit-Tests – Sicherheitsmodul (`test_sicherheit.py`)
- [x] Integrationstests – Authentifizierung (`test_auth.py`)
- [x] Integrationstests – Benutzer (`test_benutzer.py`)
- [x] Integrationstests – Kategorien, Zustände, Produkte
- [x] Integrationstests – Bestellungen (`test_bestellungen.py`)

### 7. Flutter-Frontend – Grundstruktur
- [x] Projektstruktur anlegen, Navigation (`go_router`), `BottomNavigationBar`
- [x] HTTP-Service für API-Kommunikation, Token-Speicherung (`shared_preferences`)
- [x] Auth-Screens implementieren (Login, Registrierung) 
- [x] Auth-Service mit Token-Verwaltung
- [x] API-Service mit JWT-Interceptor

- [x] http://0.0.0.0:8000/docs Port Colision (Thriftshop and oMLX Admins)

### 8. Flutter – Kundenseiten
- [x] Screen 2: Produktliste (Suche, Filter mit Provider-Integration, dynamische Kategorien, Filter-Chips)
- [x] Screen 3: Produktdetail + Warenkorb-Logik (Provider)
- [x] Screen 4: Warenkorb → Checkout → Bestätigung
- [x] Screen 5: Meine Bestellungen + Stornieren
- [x] Screen 6: Profil (Bearbeiten, Löschen, Abmelden)

### 9. Flutter – Admin-Seiten
- [x] Screen 7: Produktverwaltung (CRUD: Erstellen, Bearbeiten, Löschen, Kategorie & Zustand-Dropdowns, Admin-Zugriffskontrolle)
- [x] Screen 8: Bestellverwaltung (Filter, Statusänderung, Detailansicht)

### 10. Tests – Flutter-App
- [ ] Manuelle Tests aller Screens auf Testgerät / Emulator
- [ ] Smoke-Test: Login → Produkt kaufen → Bestellung stornieren

### 11. Migration auf Supabase/PostgreSQL
- [ ] Lokale MySQL-DB auf Supabase PostgreSQL migrieren
- [ ] `@dataclass` Modelle auf Pydantic `BaseModel` migrieren
- [ ] Backend-Verbindung umstellen, Railway-Deployment
- [ ] Supabase Auth einbinden

### 12. Deployment
- [ ] Backend auf Railway deployen
- [ ] Flutter Web-Build auf GitHub Pages deployen

### 13. Nice-to-have
- [ ] Resend-Integration für E-Mail-Bestätigungen