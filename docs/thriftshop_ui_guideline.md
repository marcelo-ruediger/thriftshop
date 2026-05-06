---
tags:
  - src/gfn
  - topic/flutter
  - topic/frontend/ui-design
  - type/project/thriftshop
  - focus
  - status/active
created: 2026-04-02 16:46
updated: 2026-04-02 17:06
deadline: 2026-04-22
priority: 1 🔴
# Hoch: 1 🔴 # Mittel: 2 🟡 # Niedrig: 3 🔵
---
# UI/UX Leitfaden – Thriftshop Köln

>[[_MOC_workbench]]

**Related**: [[thriftshop_projektantrag]], [[thriftshop_dokumentation]]

---

> [!NOTE] Zweck
> Verbindliche Referenz für **alle** UI/UX-Entscheidungen im Flutter-Frontend. Abweichungen müssen vorab abgestimmt werden.

| | |
|---|---|
| **Ziel** | Performanter, responsiver Webshop für Second-Hand-Mode |
| **Plattform** | Flutter 3.x – Material Design 3 |
| **Sprache** | Deutsch (UI-Texte, Labels, Fehlermeldungen) |
| **Backend** | FastAPI (Python) – Kommunikation ausschließlich über REST/JSON |

---

## 1 Design-System

Alle Farben, Schriften und Abstände werden **zentral** im `ThemeData`-Objekt definiert (`lib/core/theme/app_theme.dart`). Hardcodierte Werte in Widgets sind **verboten**.

### 1.1 Farbschema

Erstellt via `ColorScheme.fromSeed()` oder manuell über `ColorScheme.light()`:

| Rolle | Hex | Verwendung |
|---|---|---|
| `primary` | `#4CAF93` | Buttons, aktive Navigation, Links |
| `onPrimary` | `#FFFFFF` | Text/Icons auf Primary |
| `secondary` | `#81C784` | Chips, Badges, sekundäre Aktionen |
| `surface` | `#FAFAFA` | Karten, Dialoge, Sheets |
| `error` | `#E53935` | Validierungsfehler, Lösch-Aktionen |

Farben **immer** über `Theme.of(context).colorScheme.primary` abrufen – niemals `Colors.green` o. Ä. direkt verwenden. Das ermöglicht einen späteren Dark Mode ohne Umbauten.

### 1.2 Typografie

Schriftart: **Inter** (via `google_fonts`-Package).

| TextTheme-Rolle | Größe | Gewicht | Einsatz |
|---|---|---|---|
| `displayLarge` | 32 sp | Bold | Screen-Titel |
| `titleLarge` | 22 sp | SemiBold | Karten-Überschriften |
| `titleMedium` | 18 sp | Medium | Abschnitts-Überschriften |
| `bodyLarge` | 16 sp | Regular | Lauftext, Produktbeschreibung |
| `bodyMedium` | 14 sp | Regular | Sekundärtext, Preise |
| `labelLarge` | 14 sp | SemiBold | Button-Labels |

### 1.3 Abstände und Radien

Definiert als `static const double` in `lib/core/constants/design_tokens.dart`. **Keine Magic Numbers in Widgets.**

| Token | Wert | Verwendung |
|---|---|---|
| `spacingXs` | 4 px | Inline-Abstände |
| `spacingSm` | 8 px | Chip-Padding |
| `spacingMd` | 16 px | Standard-Padding |
| `spacingLg` | 24 px | Abschnitte trennen |
| `spacingXl` | 32 px | Screen-Ränder |
| `radiusSm` | 8 px | Chips, kleine Buttons |
| `radiusMd` | 12 px | Karten, Eingabefelder |
| `radiusLg` | 16 px | Bottom Sheets, Dialoge |

---

## 2 Responsives Layout

### 2.1 Breakpoints

| Gerät | Breite | Grid-Spalten |
|---|---|---|
| Mobile | < 600 px | 1–2 |
| Tablet | 600–1024 px | 2–3 |
| Desktop | > 1024 px | 4–6 |

### 2.2 Navigation

| Gerät | Widget | Einträge |
|---|---|---|
| Mobile | `NavigationBar` | Home, Warenkorb, Bestellungen, Konto |
| Desktop | `NavigationRail` (links fixiert) | Gleiche Einträge + Admin (nur bei Rolle ADMIN) |

### 2.3 Umschaltlogik

```dart
// In der Root-Shell (MainShell)
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileShell();   // NavigationBar unten
    } else {
      return DesktopShell();  // NavigationRail links
    }
  },
);
```

### 2.4 Maximale Inhaltsbreite

Desktop-Content wird auf **max. 1200 px** begrenzt und zentriert (`Center` + `ConstrainedBox`).

---

## 3 Routing

Package: **`go_router`**. Alle Routen zentral in `lib/core/router/app_router.dart`.

| Route | Screen | Auth | Rolle |
|---|---|---|---|
| `/` | Katalog / Home | Nein | Alle |
| `/produkt/:id` | Produktdetails | Nein | Alle |
| `/login` | Login | Nein | – |
| `/registrieren` | Registrierung | Nein | – |
| `/warenkorb` | Warenkorb | Ja | GAST+ |
| `/checkout` | Checkout | Ja | GAST+ |
| `/bestellungen` | Bestellhistorie | Ja | GAST+ |
| `/konto` | Profil | Ja | GAST+ |
| `/admin/produkte` | Produktverwaltung | Ja | ADMIN |
| `/admin/bestellungen` | Bestellübersicht | Ja | ADMIN |

**Guards** (als `redirect`-Funktion im `GoRouter`):
- **Auth-Guard:** Nicht eingeloggt → Redirect auf `/login`.
- **Rollen-Guard:** Keine Admin-Berechtigung → Redirect auf `/`.

---

## 4 State Management

Package: **`provider`** mit `ChangeNotifier`.

### 4.1 Schichten

```
UI-Widgets (Screens)        → Nur Darstellung
       ↓
Provider / ChangeNotifier   → Zustandsverwaltung
       ↓
Services / Repositories     → API-Aufrufe
       ↓
Models (Datenklassen)       → fromJson / toJson
```

### 4.2 Provider-Übersicht

| Provider | Aufgabe |
|---|---|
| `AuthProvider` | Login-Zustand, JWT-Token, Benutzerrolle |
| `CartProvider` | Warenkorb (lokal bis Bestellung abgeschickt) |
| `ProductProvider` | Produktliste, Filter, Suchbegriff |
| `OrderProvider` | Bestellhistorie des Nutzers |
| `AdminProductProvider` | Produkt-CRUD (Admin) |
| `AdminOrderProvider` | Bestellstatus ändern (Admin) |

> [!IMPORTANT] Kein Business-Code in Widgets
> Widgets rufen nur `context.read<XyzProvider>().methode()` auf. Logik (Validierung, API-Aufrufe, Fehlerbehandlung) gehört in Provider und Services.

---

## 5 API-Anbindung

Das Frontend greift **nie direkt** auf die Datenbank zu – alles läuft über das FastAPI-Backend.

### 5.1 HTTP-Client

Package: **`dio`**. Zentraler Client in `lib/core/network/api_client.dart`.

- **Base-URL:** Via `.env`-Datei (`flutter_dotenv`).
- **Auth-Header:** JWT-Token wird per Dio-Interceptor automatisch als `Bearer`-Token mitgesendet.
- **Timeout:** 15 Sekunden.

### 5.2 Fehlerbehandlung

| HTTP-Status | Reaktion im UI |
|---|---|
| `200–299` | Daten anzeigen oder Erfolgs-SnackBar |
| `401` | Auto-Logout → Redirect auf `/login` |
| `403` | SnackBar: „Keine Berechtigung" |
| `404` | Platzhalter-Widget (Ressource nicht gefunden) |
| `422` | Felder rot markieren, Backend-Meldung anzeigen |
| `500+` | Error-Widget mit „Erneut versuchen"-Button |
| Timeout | Offline-Hinweis mit Retry-Option |

> [!WARNING] Drei-Zustände-Regel
> Jeder Screen zeigt **immer** einen von drei Zuständen: **Daten**, **Laden** oder **Fehler**. Ein leerer oder eingefrorener Screen ist ein Bug.

---

## 6 Screen-Spezifikationen

### 6.1 Login & Registrierung

- **Struktur:** `SingleChildScrollView` (verhindert Tastatur-Overflow auf kleinen Bildschirmen).
- **Felder:** `TextFormField` mit `InputDecoration` und Prefix-Icons (E-Mail-Icon, Schloss-Icon).
- **Validierung:** `GlobalKey<FormState>` + `validator`-Funktion pro Feld.
- **Auth-Flow:** Nach Login → Token via `AuthProvider` speichern (Supabase Auth).

### 6.2 Katalog (Home)

- **Suche:** `SearchBar` (Material 3), oben fixiert.
- **Filter:** `FilterChip`-Widgets in horizontaler `SingleChildScrollView`.
- **Grid:** `SliverGrid` in `CustomScrollView` (ermöglicht schrumpfende `SliverAppBar`).
- **Animation:** `Hero`-Widget um jedes Produktbild → flüssiger Übergang zur Detailansicht.
- **Laden:** `Shimmer`-Platzhalter in Kartenform.

### 6.3 Produktdetails

- **Bilder:** `PageView.builder` als Slider (bei mehreren Fotos).
- **Layout:** Mobile → `Column` / Desktop → `Row` (Bild links, Text rechts).
- **CTA:** „In den Warenkorb" als `FloatingActionButton.extended` oder fixiertes Bottom-Element – **immer sichtbar**.
- **Rabatt:** Originalpreis durchgestrichen + reduzierter Preis daneben.

### 6.4 Warenkorb & Checkout

- **Liste:** `ListView.builder` + `Dismissible` (Swipe-to-Delete nach links).
- **Mengen:** Stepper-Widget (`+` / `−`) pro Artikel.
- **Preise:** `Table`-Widget für Netto, MwSt., Gesamt.
- **Bestätigung:** Nach `POST /bestellungen` → Bestätigungsscreen mit Bestellnummer.

### 6.5 Bestellhistorie

- **Liste:** `ListView.builder` mit `Card` pro Bestellung.
- **Status-Badge:** `Chip` mit Farben: Offen → Blau, In Bearbeitung → Orange, Abgeschlossen → Grün, Storniert → Rot.
- **Detail:** `ExpansionTile` oder separate Detailseite.
- **Stornierung:** Button nur bei Status `OFFEN` sichtbar.

### 6.6 Admin-Dashboard

- **Produkttabelle:** `PaginatedDataTable` – sortierbar nach Preis, Status, Datum.
- **Bild-Upload:** `DottedBorder`-Container (Package: `dotted_border`) als Drop-Zone.
- **Aktiv-Toggle:** `Switch` oder `SegmentedButton` für `produkt_aktiv`.
- **Bestellungen:** Statusänderung per `DropdownButton` → `PATCH /bestellungen/{id}/status`.

---

## 7 UX-Regeln

Diese Regeln gelten für **jeden Screen** und werden im Code Review geprüft.

### 7.1 Empty States

Leere Bereiche (z. B. leerer Warenkorb) zeigen **niemals** einen leeren Screen. Stattdessen:
1. Passendes Icon/Illustration
2. Erklärender Text (z. B. „Dein Warenkorb ist leer")
3. Call-to-Action-Button (z. B. „Jetzt shoppen" → Katalog)

### 7.2 Loading States

- **Standard:** `Shimmer`-Platzhalter in der Form der erwarteten Inhalte (Karten-Skelette).
- **Kein** nackter `CircularProgressIndicator` in der Screen-Mitte.
- **Ausnahme:** Overlay-Spinner bei Aktionen wie „Bestellung wird aufgegeben …".

### 7.3 Feedback & Overlays

| Aktion | Widget | Wann |
|---|---|---|
| Erfolg | `ScaffoldMessenger.showSnackBar` | Nach jeder erfolgreichen Aktion |
| Laden | `Shimmer` oder `CircularProgressIndicator` | Während API-Calls |
| Lösch-Bestätigung | `showDialog` (AlertDialog) | Vor destruktiven Aktionen |
| Erstattungs-Grund | `showModalBottomSheet` | Bei Stornierung / Erstattung |
| Netzwerkfehler | Error-Widget + Retry-Button | Bei Timeout oder 500er |

### 7.4 Hover-Effekte (Desktop)

Alle klickbaren Elemente ändern ihren Zustand bei Mouse-over:
- **Karten:** Leichte Elevation-Erhöhung + Schatten.
- **Buttons:** Farbänderung gemäß Material-3-States.

### 7.5 Animationen

| Animation | Widget | Dauer |
|---|---|---|
| Seitenübergang | `Hero` | 300 ms |
| Listen-Einblendung | `AnimatedList` | 200 ms |
| Warenkorb-Badge | `AnimatedSwitcher` | 200 ms |
| FAB ein/aus | `ScaleTransition` | 150 ms |

### 7.6 Barrierefreiheit

- Jedes `Image`-Widget bekommt ein `semanticLabel`.
- Jeder `IconButton` bekommt ein `tooltip`.
- Mindest-Touch-Target: **48 × 48 px**.
- Kontrastverhältnis Text/Hintergrund: mindestens **4.5:1** (WCAG AA).

---

## 8 Ordnerstruktur

```
lib/
├── core/
│   ├── constants/
│   │   └── design_tokens.dart       # Farben, Abstände, Radien
│   ├── network/
│   │   └── api_client.dart          # Dio-Setup, Interceptoren
│   ├── router/
│   │   └── app_router.dart          # GoRouter-Definition
│   └── theme/
│       └── app_theme.dart           # ThemeData-Objekt
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── catalog/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── cart/
│   ├── orders/
│   ├── profile/
│   └── admin/
│       ├── product_management/
│       └── order_management/
│
├── shared/
│   └── widgets/
│       ├── error_widget.dart
│       ├── empty_state_widget.dart
│       ├── shimmer_card.dart
│       └── responsive_shell.dart
│
└── main.dart
```

Jedes Feature-Modul (`auth`, `catalog`, `cart` …) folgt derselben Struktur: `models/`, `providers/`, `screens/`, `widgets/`.

---

## 9 Namenskonventionen

| Typ | Konvention | Beispiel |
|---|---|---|
| Dateien | `snake_case.dart` | `product_card.dart` |
| Klassen | `PascalCase` | `ProductCard` |
| Variablen | `camelCase` | `productList` |
| Konstanten | `k` + `CamelCase` | `kDefaultPadding` |
| Provider | Klasse + `Provider` | `CartProvider` |
| Screens | Klasse + `Screen` | `CatalogScreen` |
| Widgets | Klasse + beschreibend | `ProductCard`, `ShimmerCard` |

---

## 10 Entwickler-Checkliste

Implementierung in dieser Reihenfolge:

- [ ] **1.** ThemeData & Design-Tokens einrichten
- [ ] **2.** Responsive Shell (LayoutBuilder + NavigationBar / NavigationRail)
- [ ] **3.** Routing via `go_router` mit Guards
- [ ] **4.** API-Client (Dio + JWT-Interceptor + `.env`)
- [ ] **5.** AuthProvider (Login / Logout / Token)
- [ ] **6.** Katalog-Screen (Suche, Filter, Grid)
- [ ] **7.** Produktdetail-Screen (Hero-Animation, Warenkorb-CTA)
- [ ] **8.** CartProvider & Warenkorb-Screen (Swipe-to-Delete)
- [ ] **9.** Checkout-Flow mit Bestätigungsscreen
- [ ] **10.** Bestellhistorie mit Status-Badges
- [ ] **11.** Profil-Screen (Bearbeiten, Löschen)
- [ ] **12.** Admin-Dashboard (Produkt-CRUD, Bestellstatus)
- [ ] **13.** Empty States, Loading States, Error States für alle Screens
- [ ] **14.** Accessibility-Review
- [ ] **15.** Cross-Device-Test (Mobile, Tablet, Desktop)

> [!CAUTION] Package-Whitelist
> Keine neuen Packages ohne Absprache. Freigegebene Packages:
> `provider` · `go_router` · `dio` · `flutter_dotenv` · `google_fonts` · `flutter_svg` · `shimmer` · `dotted_border` · `shared_preferences`