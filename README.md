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
