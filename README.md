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


TODO: 
1. Entwicklungsumgebung einrichten
[x] Flutter SDK, Python, VS Code, MySQL lokal installieren 
[x] GitHub-Repository anlegen 
2. Datenbank aufsetzen
[x] MySQL-Schema lokal erstellen (Tabellen laut Klassendiagramm: benutzer, produkt, kategorie, zustand, bestellung, bestellposition)
[x] DAOs erstellen für die Hauptklassen
3. FastAPI-Backend – Grundstruktur
[x] Projektstruktur anlegen, Datenbankverbindung herstellen
[x] CRUD-Endpunkte für Produkte (GET, POST, PUT, DELETE /produkte)
4. Authentifizierung & Rollen
[] POST /auth/registrieren – Benutzer anlegen, Passwort mit bcrypt hashen
[] POST /auth/login – E-Mail + Passwort prüfen, JWT zurückgeben
[] Depends(aktueller_benutzer) – Token aus Header lesen & validieren
[] Middleware für Rollenprüfung (Administrator / Mitarbeiter / Kunde)
[] (Später bei Schritt 9) Supabase Auth einbinden
5. Bestellsystem im Backend
[] Endpunkte für Bestellungen (POST /bestellungen, PATCH /bestellungen/{id}/status)
[] Stornierung, Statusübergänge
[] Resend-Integration für E-Mail-Bestätigungen
6. Flutter-Frontend – Grundstruktur
[] Projektstruktur anlegen, Navigation (go_router), BottomNavigationBar
[] HTTP-Service für API-Kommunikation, Token-Speicherung (shared_preferences)
7. Flutter – Kundenseiten
[] Screen 1: Login / Registrierung
[] Screen 2: Produktliste (Suche, Filter)
[] Screen 3: Produktdetail + Warenkorb-Logik (Provider)
[] Screen 4: Warenkorb → Checkout → Bestätigung
[] Screen 5: Meine Bestellungen + Stornieren
[] Screen 6: Profil (Bearbeiten, Löschen, Abmelden)
8. Flutter – Admin-Seiten
[] Screen 7: Produktverwaltung (Liste, Toggle, Formular)
[] Screen 8: Bestellverwaltung (Filter, Statusänderung)
9. Migration auf Supabase/PostgreSQL
[] Lokale MySQL-DB auf Supabase PostgreSQL migrieren
[] @dataclass Modelle auf Pydantic BaseModel migrieren (ersetzt @dataclass direkt, kein Vererben)
[] Backend-Verbindung umstellen, Railway-Deployment
[] (Dann) Supabase Auth einbinden
10.  Testen
[] Unit-Tests (pytest für FastAPI-Endpunkte)
[] Manuelle Tests der Flutter-App auf Testgerät
11.  Deployment
[] Backend auf Railway deployen
[] Flutter Web-Build auf GitHub Pages deployen