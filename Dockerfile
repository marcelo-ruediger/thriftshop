# Baut Shop und API zu einem einzigen Container:
# das Backend liefert das gebaute Flutter-Web-Frontend mit aus.

# --- Stufe 1: Flutter-Web-Frontend bauen --------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS frontend
WORKDIR /src
COPY frontend/pubspec.yaml frontend/pubspec.lock ./
RUN flutter pub get
COPY frontend/ ./
RUN flutter build web --release --no-web-resources-cdn

# --- Stufe 2: Backend mit dem gebauten Frontend --------------------------------
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/app ./app
COPY backend/static ./static
COPY --from=frontend /src/build/web ./static/web

# Nicht als root laufen; /app/data nimmt die SQLite-Datei und Uploads auf
RUN useradd --create-home shop && mkdir -p /app/data && chown shop /app/data
USER shop

EXPOSE 8000
# Hosting-Anbieter geben den Port über $PORT vor
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
