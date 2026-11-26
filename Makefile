# Häufige Befehle. `make` ohne Argument zeigt die Übersicht.
PYTHON  ?= python3
VENV    := .venv
BIN     := $(VENV)/bin
STEMPEL := $(VENV)/.installiert

.DEFAULT_GOAL := hilfe
.PHONY: hilfe install backend frontend build start test

hilfe:
	@echo "make install   Python- und Flutter-Abhängigkeiten installieren"
	@echo "make backend   API mit Auto-Reload starten        -> http://localhost:8001/api/docs"
	@echo "make frontend  Flutter-App im Browser starten (braucht 'make backend')"
	@echo "make build     Frontend bauen und ins Backend legen"
	@echo "make start     Shop + API als ein Prozess starten -> http://localhost:8001"
	@echo "make test      Backend- und Frontend-Tests ausführen"

# Legt die virtuelle Umgebung an (falls nötig) und installiert die Python-Pakete,
# sobald sich eine requirements-Datei geändert hat.
$(STEMPEL): backend/requirements-dev.txt backend/requirements.txt
	test -d $(VENV) || $(PYTHON) -m venv $(VENV)
	$(BIN)/pip install --quiet -r backend/requirements-dev.txt
	@touch $(STEMPEL)

install: $(STEMPEL)
	cd frontend && flutter pub get

backend: $(STEMPEL)
	cd backend && ../$(BIN)/uvicorn app.main:app --reload --port 8001

frontend:
	cd frontend && flutter run -d chrome

build:
	cd frontend && flutter build web --release --no-web-resources-cdn
	rm -rf backend/static/web
	cp -R frontend/build/web backend/static/web

start: $(STEMPEL) build
	cd backend && ../$(BIN)/uvicorn app.main:app --port 8001

test: $(STEMPEL)
	cd backend && ../$(BIN)/python -m pytest -q
	cd frontend && flutter analyze && flutter test
