---
tags:
  - src/gfn
  - status/active
  - topic/flutter
  - topic/python
  - topic/ihk
  - focus
  - type/project/thriftshop
created: 2026-03-29 22:06
updated: 2026-04-04 22:42
deadline: 2026-04-01
priority: 1 🔴
---
 # Projektdokumentation

>[[_MOC_workbench]]

**Related**: [[thriftshop_projektantrag]], [[thriftshop_ui_guideline]], [[ihk_abschlussprojekt]], [[ihk_projektantrag_bestandteile]]

---
## 1 Einleitung

### 1.1 Projektumfeld
Auftraggeber ist die Thriftshop Köln GmbH, ein kleines, nachhaltiges Unternehmen mit Sitz in Köln. Das Kerngeschäft umfasst den Ankauf, die Aufbereitung und den Wiederverkauf von Second-Hand-Kleidung, Haushaltsgeräten und Dekorationsartikeln. Das Unternehmen ist seit drei Jahren am Markt und verzeichnet ein kontinuierliches Wachstum seines Kundenstamms.

Der bisherige Verkaufsprozess ist rein stationär und wird größtenteils manuell auf Papier dokumentiert. Es existiert keine digitale Lösung zur Produktverwaltung oder Bestellerfassung. Mit zunehmendem Wachstum stößt dieses Vorgehen an seine Grenzen: Kunden haben keinen Überblick über das aktuelle Sortiment, und Bestellungen müssen persönlich oder telefonisch aufgegeben werden. Dies führt zu ineffizienten Prozessen und eingeschränkter Reichweite.

### 1.2 Projektziel
- Schaffung einer digitalen Verkaufsplattform zur Präsentation des Second-Hand-Sortiments der Thriftshop Köln GmbH.
- Ermöglichung von Online-Bestellungen für Kunden unabhängig von Ort und Öffnungszeiten.
- Sicherstellung eines strukturierten Zugangs durch ein Login-System mit Rollenverwaltung für Kunden und Administratoren.
- E-Mail-Benachrichtigungen an Kunden versenden (Bestellung, Kontoerstellung, -löschung oder -bearbeitung). 
- Alle Bestell- und Produktdaten werden in einer relationalen Datenbank gespeichert.

### 1.3 Projektbegründung
Bisher arbeitet der Thriftshop Köln nur vor Ort und nutzt Papier für die Verwaltung. Das ist sehr zeitaufwendig, fehleranfällig und macht es schwierig, den Überblick über die Waren zu behalten. Um weiter wachsen zu können, ist eine digitale Lösung notwendig.

Die Vorteile des neuen Systems sind:

- **Effizienteres Arbeiten:** Durch die digitale Datenbank fallen Zettelwirtschaft und manuelle Fehler weg. Bestände und Bestellungen werden automatisch und sicher verwaltet.
- **Mehr Reichweite:** Kunden können das Sortiment rund um die Uhr online einsehen und bestellen – unabhängig von Öffnungszeiten oder Standort.
- **Zukunftssichere Technik:** Die gewählten Technologien (Flutter, FastAPI) sind modern und erweiterbar. Neue Funktionen wie Online-Zahlung können später ohne großen Aufwand ergänzt werden.

Damit kann sich der Thriftshop von einem rein stationären Laden zu einem modernen Online-Anbieter entwickeln.


### 1.4 Projektschnittstellen
Das Projekt hat folgende Verbindungspunkte (Schnittstellen):

**1. Technische Schnittstellen**
- **App ↔ Server:** Die Flutter-App kommuniziert über HTTPS mit dem FastAPI-Backend (REST/JSON).
- **Backend ↔ Datenbank:** Das Backend liest und schreibt Produkt-, Bestell- und Benutzerdaten in der Datenbank.
- **Backend → E-Mail:** Das Backend ruft den E-Mail-Dienst Resend auf, um automatisch Bestätigungen zu versenden.

**2. Benutzerschnittstellen**
- **Kunden:** Nutzen die App, um das Sortiment zu durchsuchen und Bestellungen aufzugeben.
- **Administratoren:** Nutzen einen geschützten Bereich, um Produkte und Bestellungen zu verwalten.

**3. Organisatorische Schnittstellen**
- **Auftraggeber:** Die Geschäftsführung der Thriftshop Köln GmbH wurde regelmäßig über Design- und Funktionsentscheidungen informiert.


### 1.5 Projektabgrenzungen

1. In dieser Version des Webshops wird keine Zahlungsfunktion entwickelt oder von Dritten integriert (z. B. PayPal). Zahlungen erfolgen per Rechnung/Überweisung (die Rechnung wird per E-Mail verschickt) oder vor Ort bei der Abholung.

2. Lieferfunktionen werden im Webshop nicht abgebildet. Die Liefermöglichkeiten müssen direkt per Nachricht oder telefonisch mit der Thriftshop Köln vereinbart werden. 


### 1.6 Allgemeine Bemerkungen

Datenschutz: Alle persönlichen Daten (z. B. Passwörter) werden verschlüsselt gespeichert. Es werden nur die Daten erhoben, die für die Bestellung unbedingt notwendig sind (gemäß DSGVO).

Erweiterbarkeit: Das System ist modular aufgebaut. Das bedeutet, dass man später sehr einfach neue Funktionen wie Online-Zahlung (PayPal) oder einen Versand-Service hinzufügen kann.

Test-Daten: Für die Entwicklung und die Tests wurden realitätsnahe Beispieldaten verwendet. So konnte die Suche und Filterung der Produkte schon vor dem echten Start ausgiebig geprüft werden.

---
## 2 Projektplanung

### 2.1 Projektphasen

**1. Definition (Gesamtzeit: 12 h)**

- 1.1 Ist-Analyse (Problemanalyse) (2 h)
- 1.2 Wirtschaftlichkeitsbetrachtung (2 h)
- 1.3 Anforderungen analysieren (2 h)
- 1.4 Use-Case-Analyse (2 h)
- 1.5 Lasten- und Pflichtenheft erstellen (4 h)

**2. Planung (Gesamtzeit: 12 h)**

- 2.1 Arbeitspakete erstellen (Projektstrukturplan) (2 h)
- 2.2 Kosten- und Zeitplan erstellen (2 h)
- 2.3 Datenbankmodellierung inkl. ER-Modell (3 h)
- 2.4 Entwurf der Systemarchitektur mit Klassendiagramm (3 h)
- 2.5 Erstellung der UI-Mockups (2 h)

**3. Realisierung (Gesamtzeit: 38 h)**

- 3.1 Einrichtung der Entwicklungsumgebung und Datenbankstruktur (2 h)
- 3.2 Implementierung der Datenbankzugriffe (CRUD-Operationen) (4 h)
- 3.3 Implementierung des Login-Systems mit Authentifizierung und Rollenverwaltung (7 h)
- 3.4 Entwicklung der Benutzeroberfläche (8 h)
- 3.5 Implementierung des Bestellsystems mit Validierung und E-Mail-Bestätigung (6 h)
- 3.6 Implementierung der Such- und Filterfunktion (4 h)
- 3.7 Unit-Tests (3 h)
- 3.8 Zeitpuffer (erhöhter Realisierungsaufwand) (4 h)

**4. Abschluss (Gesamtzeit: 18 h)**

- 4.1 System- und Integrationstest (3 h)
- 4.2 Code-Review (2 h)
- 4.3 Projektdokumentation (10 h)
- 4.4 Erstellung des Soll-Ist-Vergleichs (1 h)
- 4.5 Abnahme durch den Auftraggeber (1 h)
- 4.6 Schulung des Anwenders (1 h)

**Gesamtzeit des Projektes: 80 h**

![Projektstrukturplan](./assets/thriftshop_projektstrukturplan.png)

**Projektstrukturplan**
```plantuml
@startwbs thriftshop_psp
!theme toy
title Projektstrukturplan – Webshop Thriftshop Köln

*[#White] Webshop Thriftshop Köln
**[#LightBlue] 1. Definition (12 h)
***[#LightBlue] 1.1 Ist-Analyse (2 h)
***[#LightBlue] 1.2 Wirtschaftlichkeitsbetrachtung (2 h)
***[#LightBlue] 1.3 Anforderungen analysieren (2 h)
***[#LightBlue] 1.4 Use-Case-Analyse (2 h)
***[#LightBlue] 1.5 Lasten- und Pflichtenheft (4 h)
**[#LightCoral] 2. Planung (12 h)
***[#LightCoral] 2.1 Arbeitspakete erstellen (2 h)
***[#LightCoral] 2.2 Kosten- und Zeitplan (2 h)
***[#LightCoral] 2.3 Datenbankmodellierung (3 h)
***[#LightCoral] 2.4 Systemarchitektur (3 h)
***[#LightCoral] 2.5 UI-Mockups (2 h)
**[#LightGreen] 3. Realisierung (38 h)
***[#LightGreen] 3.1 Entwicklungsumgebung (2 h)
***[#LightGreen] 3.2 Datenbankzugriffe (4 h)
***[#LightGreen] 3.3 Login-System (7 h)
***[#LightGreen] 3.4 Benutzeroberfläche (8 h)
***[#LightGreen] 3.5 Bestellsystem (6 h)
***[#LightGreen] 3.6 Suchfunktion (4 h)
***[#LightGreen] 3.7 Unit-Tests (3 h)
***[#LightGreen] 3.8 Zeitpuffer (4 h)
**[#LightPink] 4. Abschluss (18 h)
***[#LightPink] 4.1 Integrationstest (3 h)
***[#LightPink] 4.2 Code-Review (2 h)
***[#LightPink] 4.3 Projektdokumentation (10 h)
***[#LightPink] 4.4 Soll-Ist-Vergleich (1 h)
***[#LightPink] 4.5 Abnahme (1 h)
***[#LightPink] 4.6 Schulung (1 h)
@endwbs
```

![Gant-Diagramm](./assets/thriftshop_gantt_diagramm.png)

**Gantt-Diagramm**
```plantuml
@startgantt thriftshop
!theme toy
projectscale daily zoom 1
hide footbox

title Webshop Thriftshop Köln

-- 1. Definition (12 h) --
[1.1 Ist-Analyse] lasts 2 days and is colored in LightBlue
[1.1 Ist-Analyse] -> [1.2 Wirtschaftlichkeitsbetrachtung]
[1.2 Wirtschaftlichkeitsbetrachtung] lasts 2 days and is colored in LightBlue
[1.2 Wirtschaftlichkeitsbetrachtung] -> [1.3 Anforderungen analysieren]
[1.3 Anforderungen analysieren] lasts 2 days and is colored in LightBlue
[1.3 Anforderungen analysieren] -> [1.4 Use-Case Analyse]
[1.4 Use-Case Analyse] lasts 2 days and is colored in LightBlue
[1.4 Use-Case Analyse] -> [1.5 Lasten- und Pflichtenheft]
[1.5 Lasten- und Pflichtenheft] lasts 4 days and is colored in LightBlue

-- 2. Planung (12 h) --
[1.5 Lasten- und Pflichtenheft] -> [2.1 Arbeitspakete erstellen]
[2.1 Arbeitspakete erstellen] lasts 2 days and is colored in LightCoral
[2.1 Arbeitspakete erstellen] -> [2.2 Kosten- und Zeitplan]
[2.2 Kosten- und Zeitplan] lasts 2 days and is colored in LightCoral
[2.2 Kosten- und Zeitplan] -> [2.3 Datenmodellierung]
[2.3 Datenmodellierung] lasts 3 days and is colored in LightCoral
[2.3 Datenmodellierung] -> [2.4 Entwurf der Systemarchitektur]
[2.4 Entwurf der Systemarchitektur] lasts 3 days and is colored in LightCoral
[2.4 Entwurf der Systemarchitektur] -> [2.5 Erstellung der UI-Mockups]
[2.5 Erstellung der UI-Mockups] lasts 2 days and is colored in LightCoral

-- 3. Realisierung (38 h) --
[2.5 Erstellung der UI-Mockups] -> [3.1 Einrichtung der Entwicklungsumgebung]
[3.1 Einrichtung der Entwicklungsumgebung] lasts 2 days and is colored in LightGreen
[3.1 Einrichtung der Entwicklungsumgebung] -> [3.2 Implementierung der Datenbankzugriffe]
[3.2 Implementierung der Datenbankzugriffe] lasts 4 days and is colored in LightGreen
[3.2 Implementierung der Datenbankzugriffe] -> [3.3 Implementierung des Login-Systems]
[3.3 Implementierung des Login-Systems] lasts 7 days and is colored in LightGreen
[3.3 Implementierung des Login-Systems] -> [3.4 Entwicklung der Benutzeroberfläche]
[3.4 Entwicklung der Benutzeroberfläche] lasts 8 days and is colored in LightGreen
[3.4 Entwicklung der Benutzeroberfläche] -> [3.5 Implementierung des Bestellsystems mit Validierung]
[3.5 Implementierung des Bestellsystems mit Validierung] lasts 6 days and is colored in LightGreen
[3.5 Implementierung des Bestellsystems mit Validierung] -> [3.6 Implementierung der Suchfunktion]
[3.6 Implementierung der Suchfunktion] lasts 4 days and is colored in LightGreen
[3.6 Implementierung der Suchfunktion] -> [3.7 Unit-Tests]
[3.7 Unit-Tests] lasts 3 days and is colored in LightGreen
[3.7 Unit-Tests] -> [3.8 Zeitpuffer]
[3.8 Zeitpuffer] lasts 4 days and is colored in LightGreen

-- 4. Abschluss (18 h) --
[3.8 Zeitpuffer] -> [4.1 System- und Integrationstest]
[4.1 System- und Integrationstest] lasts 3 days and is colored in LightPink
[4.1 System- und Integrationstest] -> [4.2 Code-Review]
[4.2 Code-Review] lasts 2 days and is colored in LightPink
[4.2 Code-Review] -> [4.3 Projektdokumentation        ]
[4.3 Projektdokumentation        ] lasts 10 days and is colored in LightPink
[4.3 Projektdokumentation        ] -> [4.4 Erstellung des Soll-Ist-Vergleichs]
[4.4 Erstellung des Soll-Ist-Vergleichs] lasts 1 day and is colored in LightPink
[4.4 Erstellung des Soll-Ist-Vergleichs] -> [4.5 Abnahme durch den Auftraggeber]
[4.5 Abnahme durch den Auftraggeber] lasts 1 day and is colored in LightPink
[4.5 Abnahme durch den Auftraggeber] -> [4.6 Schulung des Anwenders]
[4.6 Schulung des Anwenders] lasts 1 day and is colored in LightPink
@endgantt
```

### 2.2 Ressourcenplanung

**Personalressourcen:**
- Umsetzung: Das Projekt wird komplett eigenständig von einer Person (Full-Stack-Entwicklung) geplant, entwickelt und getestet.
- Zeitaufwand: Der gesamte Arbeitsaufwand ist auf 80 h angesetzt. Darin enthalten ist ein Zeitpuffer von 4 h für das Risikomanagement.
- Zeitraum: Bei einer wöchentlichen Arbeitszeit von 20 h beträgt die Projektdauer insgesamt 4 Wochen.

**Technische Ressourcen:**
- Hardware: Ein Windows-PC (16GB RAM - 500GB SSD - Intel Core i5) für die Programmierung sowie ein Smartphone (Android/iOS) zum Testen der App unter realen Bedingungen.
- Entwicklung: Visual Studio Code wird als Editor genutzt. Die Versionierung des Codes erfolgt über Git & GitHub.
- Datenbank-Tools: Für den Entwurf und die Verwaltung der Tabellen wird die MySQL Workbench eingesetzt.
- Planung: Diagramme werden mit PlantUML und Draw.io erstellt. Notizen und Fachwissen werden in Obsidian gesammelt.
- Dokumentation: Die fertige Arbeit wird in Microsoft Word erstellt.

**Infrastruktur & Externe Dienste:**
Damit die Anwendung online funktioniert, werden folgende kostenlose Dienste genutzt:
- Backend-Server: Das Python-Backend (FastAPI) läuft auf der Plattform Railway. So ist die Schnittstelle immer erreichbar.
- Datenbank: Als Hauptspeicher dient Supabase (PostgreSQL). Während der Entwicklung wird zusätzlich eine lokale Datenbank (MySQL) zum Testen verwendet.
- Web-Hosting: Das Frontend der App wird über GitHub Pages veröffentlicht. Dies bietet automatisch eine sichere Verschlüsselung (SSL).
- E-Mail-Versand: Automatische Bestätigungen werden über den Dienst Resend verschickt. Für die Anmeldung von Benutzern wird das eingebaute E-Mail-System von Supabase Auth genutzt.


### 2.3 Entwicklungsprozess 

Da es sich bei dem geplanten Webshop um ein kleines Projekt mit fest definierten Anforderungen, Phasen und einem überschaubaren Gesamtaufwand von 80 Stunden handelt, wird ein klassisches Vorgehensmodell in Form des Wasserfallmodells gewählt. 

Die Projektphasen (Definition, Planung, Realisierung, Abschluss) werden streng sequenziell abgearbeitet. Eine neue Phase beginnt typischerweise erst, wenn die vorherige vollständig abgeschlossen und dokumentiert wurde. Für die Versionierung und Sicherung des Quellcodes wird Git (GitHub) eingesetzt, um Änderungen jederzeit nachvollziehen zu können.

### 2.4 Risikomanagement

Bei der Projektplanung wurden mögliche Risiken bewertet und Gegenmaßnahmen festgelegt:

| Risiko                                                  | Wahrscheinlichkeit | Auswirkung | Gegenmaßnahme                                                                                                    |
| ------------------------------------------------------- | ------------------ | ---------- | ---------------------------------------------------------------------------------------------------------------- |
| Aufwandsunterschätzung                                  | Mittel             | Hoch       | 4 Stunden Zeitpuffer in der Realisierungsphase eingeplant                                                        |
| Technische Probleme (z. B. Bibliotheksinkompatibilität) | Mittel             | Mittel     | Frühzeitiger Test der Kernbibliotheken; Alternativen evaluiert                                                   |
| Ausfall externer Dienste (Railway, Supabase, Resend)    | Gering             | Hoch       | Lokale Entwicklungsumgebung unabhängig von Cloud-Diensten; kostenlose Alternativen verfügbar                     |
| Gerätespezifische Fehler der Flutter-App                | Mittel             | Mittel     | Tests auf physischen Geräten ab früher Realisierungsphase                                                        |
| Datenverlust durch fehlerhaftes Datenbankskript         | Gering             | Hoch       | `CREATE TABLE IF NOT EXISTS` verhindert unbeabsichtigtes Überschreiben; Quellcode vollständig in Git versioniert |

---

## 3 Analysephase

### 3.1 Ist-Analyse
Der Thriftshop Köln arbeitet aktuell rein stationär und nutzt größtenteils manuelle Papierdokumentation für die Verwaltung der Second-Hand-Waren und Bestellungen. Es existiert keine digitale Lösung zur Produktübersicht für Kunden oder zur internen Bestandsaufnahme. Dieses Vorgehen ist fehleranfällig, zeitaufwendig und beschränkt die Reichweite des Unternehmens stark auf Laufkundschaft vor Ort, da Artikel nicht online eingesehen werden können.

### 3.2 Wirtschaftlichkeit
#### 3.2.1 Make or Buy-Entscheidung
Vor Beginn des Projekts wurde abgewogen, ob eine Standard-Shop-Lösung (Buy - z.B. Shopify) oder eine Eigenentwicklung (Make) sinnvoller ist. 

Bei einer **Buy-Lösung (Shopify)** würden dauerhaft laufende Fixkosten entstehen:
- Die Basisversion ("Basic Shopify") kostet in Deutschland aktuell ca. 36 € im Monat (zzgl. MwSt.). 
- Hinzu kommen umsatzabhängige Transaktionsgebühren (bis zu 2 % bei Nutzung externer Zahlungsmittel) sowie vielfach monatliche Kosten für Drittanbieter-Plugins, da Funktionen wie das individuell angeforderte Rollensystem im Basis-Plan oft nicht nahtlos integrierbar sind. Auf ein Jahr gerechnet lägen die reinen Fixkosten bei über 430 € (ohne versteckte Zusatzkosten).

Eine **Eigenentwicklung (Make)** mit Flutter und FastAPI erfordert zwar einen initialen Entwicklungsaufwand (80 Stunden), bietet jedoch langfristig massive Kostenvorteile. Durch die konsequente Nutzung von Open-Source-Technologien und kostenfreien Cloud-Ressourcen (Free Tiers bei Railway, Supabase und GitHub Pages) bleiben die monatlichen Betriebskosten bei 0,00 € oder, bei optionalen Upgrades auf kostenpflichtige Basistarife, voraussichtlich unter 10 € pro Monat. Gleichzeitig ist das System voll auf die Thriftshop-Anforderungen (keine Direktzahlungen, spezielles Admin/Kunden-System) maßgeschneidert. 

Daher fiel die Entscheidung eindeutig auf die Eigenentwicklung.

#### 3.2.2 Projektkosten
Die Kosten des Projekts entstehen hauptsächlich durch den internen Personalaufwand (eigene Arbeitszeit sowie Unterstützung durch interne Entwickler), da auf teure Server- und Lizenzkosten verzichtet wird:
- **Entwicklungskosten:** 80 Stunden × 15 €/h = 1.200 €. (Meine Firma Fragen)
- **Code Review:** Prüfung durch einen internen Softwareentwickler (5 Stunden × 140 €/h) = 700 €.
- **Gesamte Entwicklungskosten:** 1.900 €.
- **Laufende Infrastrukturkosten:** 0,00 € pro Monat (Nutzung von Railway Free Tier, Supabase, GitHub Pages und Resend).
- **Fremdkosten (App Stores - Optional):** Falls die App später in die Stores soll: Apple Developer (99 $/Jahr), Google Play (25 $ einmalig).

#### 3.2.3 Amortisationsdauer
Da die laufenden Betriebskosten faktisch entfallen, bemisst sich die Amortisation der Entwicklungskosten (1.900 €) an der eingesparten Arbeitszeit. Spart die digitale Verwaltung pro Woche ca. 3 Arbeitsstunden (à 20 €) ein, so werden 60 € pro Woche gespart. Die Gesamtentwicklungskosten von 1.900 € haben sich somit nach ca. 32 Wochen (rund 8 Monaten) amortisiert.

**Amortisationsverlauf**
![Thriftshop Amortisationsverlauf](./assets/thriftshop_amortisationsverlauf.svg)

### 3.3 Lastenheft/ Fachkonzept
Bei diesem Projekt wurde vom Auftraggeber kein klassisches Lastenheft vorgegeben. Das Problem, die gewünschten Lösungen, das Budget und die Ressourcen wurden stattdessen in einem Fachgespräch ermittelt und festgehalten. 

Es handelt sich um einen Webshop, der den gesamten Verkaufs- und Verwaltungsprozess der Thriftshop Köln GmbH durch folgende Maßnahmen vereinfachen und digitalisieren soll:

**1. Digitalisierung des Sortiments:**
- Schaffung einer Plattform, auf der Kunden das Second-Hand-Sortiment jederzeit online einsehen können, unabhängig von den stationären Öffnungszeiten.
- Implementierung von Such- und Filterfunktionen zur besseren Übersicht.

**2. Digitale Bestellabwicklung:**
- Kunden können online verbindliche Bestellungen aufgeben, was den manuellen Aufgabenaufwand vor Ort reduziert und Fehler (Zettelwirtschaft) minimiert.
- Etablierung eines automatisierten E-Mail-Systems (Versand von Bestätigungen bei Bestellung, Registrierung oder Kontoänderung).

**3. Verwaltung und Datensicherheit:**
- Ein sicheres Login-System mit Rollenverwaltung zur strikten Trennung zwischen Kunden (Kauf) und Administratoren (Verwaltung).
- Mitarbeiter erhalten einen geschützten Admin-Bereich, um Bestände, Produkte und eingehende Bestellungen zentral in einer relationalen Datenbank zu verwalten.
- Alle Kundendaten werden gemäß DSGVO verwaltet (inkl. Passwortverschlüsselung).

**Abgrenzung:**
- Der Webshop beinhaltet **keine** direkte Zahlungsfunktion (Abwicklung erfolgt auf Rechnung oder vor Ort).
- Es ist **kein** Liefer- oder Versandprozess integriert (Vereinbarungen manuell via Nachricht/Telefon).

![Thriftshop Anwendungsfalldiagramm](./assets/thriftshop_use_case_diagramm.png)

```plantuml
@startuml thriftshop_usecase
!theme plain
title Thrift Shop Köln

actor Benutzer #FFB347
actor Admin #LightGreen

rectangle "Webshop" {
    (Konto erstellen/ löschen/ bearbeiten) .> (Per Email bestätigen) : <<includes>>
    (Konto erstellen/ löschen/ bearbeiten).> (Einloggen) : <<includes>>
    (Produkte suchen)
    (Bestellen) .> (Einloggen) : <<includes>>
    (Bestellen) .> (Per Email bestätigen) : <<includes>>
    (Bestellung stornieren) .> (Bestellen) : <<extends>>
    (Produkte auflisten/ löschen/ bearbeiten) .> (Einloggen) : <<includes>>
    (Bestellung stornieren) .> (Per Email bestätigen) : <<includes>> 
}

Benutzer --> (Konto erstellen/ löschen/ bearbeiten)
Benutzer --> (Bestellen)
Benutzer --> (Produkte suchen)

Admin --> (Produkte auflisten/ löschen/ bearbeiten)
Admin --|> Benutzer

' --- Styling ------
(Bestellen) -[hidden]-> (Per Email bestätigen)
(Bestellen) -[hidden]-> (Einloggen)
(Per Email bestätigen) -[hidden]-> (Bestellung stornieren)
' ------------------
@enduml
```

---

## 4 Entwurfsphase

### 4.1 Zielplattform
Die Anwendung ist auf eine plattformübergreifende Nutzung ausgelegt:
- **Client (Frontend):** Eine native Cross-Platform-App für iOS und Android (sowie als Web-Applikation), entwickelt mit dem Framework **Flutter**. Die Web-Version wird primär für das Admin-Dashboard über GitHub Pages bereitgestellt.
- **Server (Backend):** Eine RESTful-API, entwickelt in **Python (FastAPI)**, gehostet in der Cloud bei **Railway**.
- **Datenbank:** Entwicklung mit MySQL relationale Datenbank, produktiv betrieben mit **PostgreSQL (Supabase)**.

### 4.2 Architekturdesign
Das System folgt einer klassischen Client-Server-Architektur, die sich physisch und logisch in drei Hauptkomponenten (Schichten) aufteilt:

1. **Präsentationsschicht (Client/Frontend):** 
   Die Benutzeroberfläche wird durch eine plattformübergreifende Flutter-Anwendung bereitgestellt. Der Client speichert selbst keine dauerhaften Geschäftsdaten, sondern fordert diese nur bei Bedarf an und stellt sie dar. Er reagiert auf Nutzereingaben und sendet entsprechende asynchrone HTTP-Requests (REST via JSON) an den Server.

2. **Logikschicht (Server/Backend):** 
   Das Herzstück der Anwendung ist eine RESTful-API, geschrieben in Python (FastAPI), die später auf der Cloud-Plattform Railway gehostet wird. Dieser Server nimmt alle Anfragen der Clients entgegen, authentifiziert den Nutzer und führt die eigentliche Geschäftslogik durch. Beispielsweise prüft er bei einer Bestellung, ob der angefragte Artikel noch auf Lager ist. Zudem steuert das Backend externe Dienste an, beispielsweise den SMTP-Mailer (Resend), um automatisch Bestätigungs-E-Mails zu versenden.

3. **Datenhaltungsschicht (Datenbank):** 
   Das FastAPI-Backend kommuniziert sicher mit einer PostgreSQL-Datenbank, die von Supabase in der Cloud gehostet wird. Für die Entwicklung und das Testing wird zunächst eine MySQL-Datenbank verwendet. Hier werden alle persistenten Daten, wie Benutzerprofile, das Produktinventar und die Bestellungen, zentral verwaltet. Ein direkter Zugriff des Frontends auf die Datenbank ist aus Sicherheitsgründen technisch ausgeschlossen; die API dient als verbindlicher "Türsteher".

![Thriftshop Architekturdiagramm](./assets/thriftshop_architekturdiagramm.png)

```plantuml 
@startuml architekturdiagramm
!theme plain
title Architekturdiagramm der Anwendung
skinparam componentStyle rectangle

package "Client (Frontend)" {
    [Flutter App (iOS/Android)] as App
    [Flutter Web (Admin Dashboard)] as Web
}

package "Server (Backend - Railway)" {
    [FastAPI (REST API)] as API
    [ShopServices (Authentification/Logik)] as Auth
    API --> Auth
}

database "Datenbank (Supabase)" {
    [PostgreSQL] as DB
}

cloud "Externe Dienste" {
    [Resend (SMTP Mailer)] as Mail
}

App <--> API : HTTPS / REST JSON
Web <--> API : HTTPS / REST JSON

API <--> DB : Lesen / Schreiben
API --> Mail : API Call (Bestätigungsmail)
@enduml
```

### 4.3 Datenmodell
Das objektorientierte Datenmodell der Anwendung besteht aus sechs Klassen, die die Struktur der gespeicherten Daten abbilden.

- Benutzer: Repräsentiert einen registrierten Kunden oder Mitarbeiter. Neben persönlichen Stammdaten (Name, E-Mail, Telefon) wird das Passwort ausschließlich als kryptografischer Hash (bcrypt) gespeichert. Das Attribut `rolle` wird auf Datenbankebene durch einen CHECK-Constraint auf die Werte „Administrator“, „Mitarbeiter“ und „Kunde“ beschränkt. Diese Rolle dient im Backend als Basis für die autorisierte Zugriffskontrolle (RBAC – Role-Based Access Control). Ein Benutzer steht in einer 1:n-Beziehung zu Bestellungen.

- Produkt: Bildet einen physischen Verkaufsartikel ab. Jedes Produkt verfügt über eine eindeutige UUID, eine menschenlesbare `produktnr`, sowie den preis und einen optionalen `produkt_rabatt` (jeweils als Decimal). Das Flag `produkt_aktiv` steuert die Sichtbarkeit im Frontend. Ein Produkt ist über Foreign Keys fest genau einer Kategorie und einem Zustand zugeordnet.

- Kategorie: Gruppiert Produkte thematisch (z. B. Kleidung, Medien). Sie kann einen `kategorie_rabatt` besitzen. Die Logik prüft zur Laufzeit via `MAX()`, ob der produkt- oder kategoriespezifische Rabatt für den Endpreis angewendet wird.

- Zustand: Definiert den physischen Erhaltungsgrad eines Artikels (z. B. „wie neu“, „stark gebraucht“). Dies ist im Thriftshop-Kontext entscheidend für die Preisfindung und Transparenz gegenüber dem Käufer.

- Bestellung: Repräsentiert einen abgeschlossenen Kaufvorgang. Sie ist fest mit einem Benutzer verknüpft und enthält Metadaten wie die `laufende_nr`, das `bestelldatum` und den aktuellen `status`. Letzterer wird per Datenbank-Constraint auf valide Werte („Offen“, „In Bearbeitung“, „Abgeschlossen“, „Storniert“, „Erstattet“) limitiert. Die Beziehung zu den Positionen ist als Komposition implementiert: Das Löschen einer Bestellung führt kaskadierend zum Löschen aller zugehörigen Positionen (Referenzielle Integrität).

- BestellPosition: Fungiert als Assoziationsklasse, um die m:n-Beziehung zwischen Bestellung und Produkt aufzulösen. Sie speichert einen Snapshot der Daten zum Kaufzeitpunkt (`einzelpreis_gebucht`, `rabatt_angewendet`, `steuersatz_gebucht`). Dies stellt sicher, dass die Buchhaltung auch bei nachträglichen Preis- oder Steuersatzänderungen am Stammprodukt konsistent bleibt. Die Klasse enthält zudem die Geschäftslogik zur Berechnung der `gesamtpreis_netto()` und `gesamtpreis_brutto()` Werte der jeweiligen Position.

![Thriftshop ER Modell](./assets/thriftshop_er_modell.png)

Die Klasse **ShopServices**, im Klassendiagramm dargestellt, bildet die zentrale Geschäftslogik ab. Sie nutzt die sechs oben genannten Datenmodelle als Datenträger, um Informationen zu verarbeiten, zu speichern und abzurufen. Die eigentliche Datenbankkommunikation erfolgt über DAOs. Um das Klassendiagramm übersichtlich zu halten, wurden die DAOs dort nicht separat eingezeichnet.

![Thriftshop Klassendiagramm](./assets/thriftshop_klassendiagramm.png)

```plantuml
@startuml thriftshop_klassendiagramm
!theme plain
skinparam classAttributeIconSize 0

' --- ENTITÄTEN (Reine Datenträger) ---

class Benutzer {
    + **benutzer_id: UUID** <<PK>>
    - vorname: str
    - nachname: str
    - email: str
    - telefon: str
    - passwort_hash: str
    - rolle: str
    - erstellt_am: datetime
    - letzte_aenderung: datetime
    - letzter_login: datetime
}

class Produkt {
    + **produkt_id: UUID** <<PK>>
    - laufende_nr: int
    - erstellungsdatum: datetime
    - bezeichnung: str
    - slug: str
    - produkt_info: str
    - preis: Decimal 
    - produkt_rabatt: Decimal
    - produkt_aktiv: Boolean
    - lagerbestand: int
    - zustand_id: UUID <<FK>>
    - kategorie_id: UUID <<FK>>
    ---
    + produktnr(): str
}

class Bestellung {
    + **bestellung_id: UUID**
    - laufende_nr: int
    - bestelldatum: datetime
    - status: str
    - benutzer_id: UUID <<FK>>
    ---
    + bestellnr(): str
}

class BestellPosition {
    + **bestellposition_id: UUID** <<PK>>
    - menge: int
    - einzelpreis_gebucht: Decimal
    - rabatt_angewendet: Decimal
    - steuersatz_gebucht: Decimal
    - produkt_id: UUID <<FK>>
    - bestellung_id: UUID <<FK>>
    ---
    + gesamtpreis_netto(): Decimal
    + gesamtpreis_brutto(): Decimal
}

class Zustand {
    + **zustand_id: UUID** <<PK>>
    - bezeichnung: str
    - beschreibung: str
}

class Kategorie {
    + **kategorie_id: UUID** <<PK>>
    - bezeichnung: str
    - slug: str                  
    - kategorie_rabatt: Decimal
    - steuersatz: Decimal
}

' --- LOGIK-SCHICHT (Methoden - Hier passiert die Arbeit) ---

class ShopServices {
    ---
    ' --- Authentifizierung und Profil ---
    + login(email: str, passwort: str): Benutzer
    + profil_bearbeiten(kunde: Benutzer, daten: dict): Benutzer
    + profil_loeschen(kunde: Benutzer): None

    ' --- Katalog und Suche ---
    + produkte_anzeigen(filter: dict): list
    + produkt_details(produkt_id: UUID): Produkt

    ' --- Bestellprozess ---
    + bestellung_aufgeben(kunde: Benutzer, warenkorb: list): Bestellung
    + bestell_historie(kunde: Benutzer): list
    + erstattung_beantragen(kunde: Benutzer, bestellung_id: UUID, grund: str): None
    + bestellung_stornieren(kunde: Benutzer, bestellung_id: UUID): None

    ' --- Admin-Funktionen (Werfen Exceptions bei fehlenden Rechten) ---
    + bestellung_erstatten(admin: Benutzer, bestellung_id: UUID): None
    + produkt_anlegen(admin: Benutzer, daten: Produkt): Produkt
    + produkt_bearbeiten(admin: Benutzer, produkt_id: UUID, neue_daten: Produkt): Produkt
    + produkt_loeschen(admin: Benutzer, produkt_id: UUID): None
    + produkt_aktiv_toggle(admin: Benutzer, produkt_id: UUID): None
    + bestellungen_einsehen(admin: Benutzer, filter: dict): list
}

' --- BEZIEHUNGEN ---
Benutzer "1" --> "*" Bestellung : erstellt
Bestellung "1" *-- "1..*" BestellPosition : enthält
Produkt "1" <-- "*" BestellPosition : referenziert
Produkt "*" --> "1" Kategorie : gehört
Produkt "*" --> "1" Zustand : hat

ShopServices ..> Bestellung : erstellt
ShopServices ..> Benutzer : prüft Rolle
ShopServices ..> Produkt : manipuliert

@enduml
```

### 4.4 UI-Design

Die Benutzeroberfläche durchlief zwei Entwurfsstufen. Zunächst wurden alle Screens als **Wireframe** mit Draw.io skizziert, um Seitenstruktur, Navigation und die Anordnung der Elemente festzulegen – ohne Farben oder Details. Auf Basis dieser Wireframes wurde anschließend mithilfe des KI-Modells **Google Gemini** ein **HTML-Mockup** erstellt, das das finale Design mit Farbschema, Schriften und Abständen abbildet. Das Mockup wurde abschließend als PDF exportiert. Es befindet sich im Anhang.

### 4.5 Test-Konzept
Zur Gewährleistung der Softwarequalität werden verschiedene Teststufen definiert:
- **Unit-Tests (Backend):** Die einzelnen FastAPI-Endpunkte und Geschäftslogiken werden isoliert (z.B. mit `pytest`) geprüft.
- **Integrationstests:** Das Zusammenspiel zwischen Backend und Datenbank wird automatisiert getestet.
- **Manuelle Systemtests (Frontend):** Auf physischen Testgeräten (Android/iPhone) werden die UI/UX und Nutzerführungen (Registrierung -> Artikel in Warenkorb -> Bestellung) manuell durchgespielt.

### 4.6 Pflichtenheft

Das Pflichtenheft beschreibt, wie die im Fachkonzept (3.3) gestellten Kundenanforderungen technisch umgesetzt werden.

#### Anforderung 1: Digitalisierung des Sortiments

- **Sortiment jederzeit online einsehbar**  
  Die Flutter-App ruft beim Start die Produktliste über den Endpunkt `GET /produkte` vom FastAPI-Backend ab. Dieser Endpunkt ist öffentlich zugänglich und erfordert keinen Login, sodass Kunden das Sortiment jederzeit und von überall einsehen können. Die Produkte werden in einem `GridView` dargestellt.

- **Such- und Filterfunktion**  
  Im Frontend stehen ein Suchfeld und Kategorie-Filter (`FilterChip` - vordefiniert) zur Verfügung. Produkte können beispielsweise nach Kategorie oder Preis gefiltert werden. Jede Eingabe sendet eine neue Anfrage an das Backend (`GET /produkte?search=jacke&kategorie=Kleidung`). Das FastAPI-Backend filtert die Ergebnisse in der Datenbankabfrage und gibt nur passende Produkte zurück.

#### Anforderung 2: Digitale Bestellabwicklung

- **Online-Bestellungen aufgeben**  
  Der Kunde legt Artikel in den Warenkorb, dessen Inhalt lokal im Flutter App-State gespeichert wird. Auf dem Checkout-Screen sieht der Kunde eine Übersicht und bestätigt die Bestellung. Die App sendet daraufhin einen `POST /bestellungen`-Request mit den Artikeln und der Kunden-ID an das Backend, welches die Bestellung in der Datenbank anlegt.

- **Automatische E-Mail-Bestätigung bei Bestellung**  
  Nach erfolgreichem Anlegen der Bestellung in der Datenbank ruft das FastAPI-Backend den externen E-Mail-Dienst Resend per SMTP auf. Dieser versendet automatisch eine Bestätigungsmail mit der Bestellnummer, den bestellten Artikeln und Gesamtpreis an die hinterlegte Kunden-E-Mail-Adresse. In der E-Mail sind auch die Zahlungsdaten enthalten (falls keine Vor-Ort-Zahlung ausgewählt wurde).

- **E-Mail bei Registrierung und Kontoänderung**  
  Bei der Registrierung versendet Supabase Auth automatisch eine Bestätigungsmail. Bei späteren Kontoänderungen (Daten bearbeiten, Konto löschen) triggert das FastAPI-Backend nach der Datenbankoperation jeweils einen eigenen Resend-Aufruf, um den Kunden per E-Mail zu informieren.

#### Anforderung 3: Verwaltung und Datensicherheit

- **Login-System mit Rollenverwaltung**  
  Die Authentifizierung erfolgt über Supabase Auth, das nach erfolgreichem Login einen signierten JWT-Token ausstellt. Die Benutzerrolle (`ADMIN`, `MITARBEITER` oder `KUNDE`) ist im Token hinterlegt. Die Flutter-App speichert den Token lokal und sendet ihn bei jedem API-Request im Authorization-Header mit. Das FastAPI-Backend prüft bei jedem Request die Gültigkeit und Rolle des Tokens. Da es sich um ein kleines Unternehmen handelt, ist die Benutzerrolle `Mitarbeiter` zunächst inaktiv. Bei Bedarf kann sie als Alternative zum Administrator mit eingeschränkten Berechtigungen aktiviert werden. 

- **Geschützter Admin-Bereich**   
  Alle Aktionen, die Daten in der Datenbank verändern (Produkte erstellen, ändern, löschen oder Bestellungen aktualisieren) mit `POST`, `PUT`, `DELETE`, `PATCH`, sind im Backend per Dependency-Injection geschützt. Diese Funktion prüft automatisch bei jeder Anfrage, ob der Benutzer die nötigen Rechte hat, bevor die Aktion ausgeführt wird. Anfragen ohne gültigen Admin-Token werden mit HTTP `403 Forbidden` abgewiesen. Im Frontend wird die Admin-Navigation nur angezeigt, wenn die Rolle im Token `ADMIN` ist.

- **Zentrale relationale Datenbank**  
  Alle persistenten Daten werden in einer PostgreSQL-Datenbank auf Supabase gespeichert. Die Tabellen entsprechen dem Klassendiagramm (Abschnitt 4.3): `benutzer`, `produkt`, `kategorie`, `zustand`, `bestellung`, `bestellposition`. Ein direkter Zugriff vom Frontend auf die Datenbank ist technisch ausgeschlossen. Alle Anfragen laufen ausschließlich über das FastAPI-Backend.

- **Datenschutz, Datensicherheit und rechtliche Rahmenbedingungen**  
  Passwörter werden ausschließlich als bcrypt-Hash gespeichert (`passlib`-Bibliothek) mit eingebautem Salting. Es wird kein Klartext-Passwort in der Datenbank abgelegt oder über das Netzwerk übertragen. Für Bestellungen werden nur die Daten erhoben und verarbeitet, die für den rechtmäßigen Zweck notwendig sind (Vorname, Nachname, E-Mail, Telefon).
  Eine Datenschutzerklärung ist vorhanden, um das Recht auf Information über die Verarbeitung der Daten zu gewährleisten. Der Benutzer muss dieser Datenschutzerklärung zustimmen. Der Benutzer hat zudem das Recht auf Datenübertragbarkeit, Löschung (Recht auf Vergessenwerden) und Widerspruch, und kann jederzeit seine Einwilligung zur Verarbeitung personenbezogener Daten widerrufen. Für weitere DSGVO-konforme Regelungen muss sich die Thriftshop Köln GmbH von einem Anwalt beraten lassen.
  Allgemeine Geschäftsbedingungen (AGB) mit den entsprechenden rechtlichen Anforderungen müssen ebenfalls von der Thriftshop Köln GmbH zur Verfügung gestellt werden. Diese werden auf einer dedizierten Webseite für den Benutzer angezeigt und müssen beim Kauf vom Kunden akzeptiert werden. Darüber hinaus sind ein Impressum sowie ein Cookie-Banner vorhanden. Der Cookie-Banner wird beim Öffnen der Website angezeigt, sodass der Benutzer seine Präferenzen auswählen und seine Einwilligung erteilen kann.


#### Abgrenzung (Nicht-Ziele, unverändert)

- Keine Zahlungsfunktion – Rechnung wird per E-Mail versendet oder Zahlung erfolgt vor Ort.
- Kein Versandprozess – Absprache erfolgt manuell per Telefon oder Nachricht.

---

## 5 Implementierungsphase

### 5.1 Projektstruktur

Das Projekt besteht aus einem Python-Backend und einer Flutter-App. Die Struktur folgt dem Prinzip der **Separation of Concerns**: Datenmodelle, Datenbankzugriff und Geschäftslogik sind im Backend klar voneinander getrennt. Das Frontend ist nach Feature-Modulen gegliedert.

```
backend/
├── models/               # Python-Datenmodelle (@dataclass)
│   ├── benutzer.py, bestellung.py, bestellposition.py
│   ├── kategorie.py, produkt.py, zustand.py
│   └── __init__.py       # Exportiert alle Klassen
├── dao/                  # Datenbankzugriff (CRUD)
│   ├── benutzer_dao.py, bestellung_dao.py, produkt_dao.py
│   └── __init__.py
├── services/
│   └── shop_services.py  # Geschäftslogik
├── init_db.py            # Datenbankinitialisierung
└── main_test.py          # Tests

lib/                      # Flutter Frontend
├── core/
│   ├── constants/        # Design-Tokens (Abstände, Radien)
│   ├── network/          # API-Client (Dio + JWT-Interceptor)
│   ├── router/           # Routen-Konfiguration (go_router)
│   └── theme/            # ThemeData (Farben, Schriften)
├── features/
│   ├── auth/             # Login, Registrierung
│   ├── catalog/          # Produktkatalog, Suche, Filter
│   ├── cart/             # Warenkorb
│   ├── orders/           # Bestellhistorie
│   ├── profile/          # Profilverwaltung
│   └── admin/            # Admin-Dashboard
├── shared/widgets/       # Wiederverwendbare UI-Komponenten
└── main.dart
```

**Wichtige Designentscheidungen:**

- **Slugs:** `Kategorie` und `Produkt` nutzen Slugs für lesbare URLs (z. B. `/kategorie/kleidung/vintage-levis-jeansjacke`).
- **Preis-Snapshots:** `BestellPosition` speichert Preis, Rabatt und Steuersatz zum Kaufzeitpunkt, damit Buchungen auch bei späteren Preisänderungen korrekt bleiben.
- **Lesbare Nummern:** `Produkt` und `Bestellung` formatieren ihre laufende Nummer per `@property` in einen lesbaren String (z. B. `P00012`, `B00003`).
- **Validierung auf Datenbankebene:** Bestellstatus und Benutzerrolle werden per `CHECK`-Constraint direkt in der Datenbank validiert.

### 5.2 Datenbank und Datenmodelle

Das Skript `init_db.py` erstellt per `mysql.connector` die Datenbank `thriftshop` mit sechs Tabellen. Verbindungsdaten werden aus einer `.env`-Datei geladen (`python-dotenv`), sodass keine sensiblen Daten im Quellcode stehen.

| Tabelle           | Besonderheiten                                                   |
| ----------------- | ---------------------------------------------------------------- |
| `benutzer`        | `CHECK`-Constraint auf Rolle; Passwort als bcrypt-Hash           |
| `zustand`         | Referenziert von `produkt`                                       |
| `kategorie`       | Slug, Rabatt und Steuersatz                                      |
| `produkt`         | FK auf `zustand` und `kategorie`; `ON DELETE RESTRICT`           |
| `bestellung`      | `CHECK`-Constraint auf Status; `ON DELETE RESTRICT` auf Benutzer |
| `bestellposition` | Preis-Snapshot; `ON DELETE CASCADE` beim Löschen der Bestellung  |

Die Python-Klassen in `models/` spiegeln diese Tabellen als `@dataclass` wider. Der Dekorator generiert Konstruktor, Vergleichsmethoden und `__repr__` automatisch. Wichtige Details:

- **UUID** (`uuid4()`): Jede Entität besitzt eine eindeutige ID, die als `CHAR(36)` gespeichert wird – eine statische Zeichenkette mit genau 36 Zeichen.
- **Decimal** statt `float`: Verhindert Rundungsfehler bei Geldbeträgen.
- **Properties:** `BestellPosition` berechnet Netto- und Bruttopreis dynamisch über den `@property`-Dekorator. So werden die Werte bei Bedarf berechnet, ohne sie separat zu speichern.

Alle Klassen werden über `models/__init__.py` exportiert und können mit `from models import Produkt, Benutzer` importiert werden.

### 5.3 Datenbankzugriff (DAO)

Für den Datenbankzugriff wurde das **DAO-Pattern** eingesetzt. Jede Entität hat ein eigenes DAO (z. B. `ProduktDAO`, `BenutzerDAO`), das alle SQL-Abfragen kapselt. Die Geschäftslogik enthält dadurch kein SQL. Das erleichtert die spätere Migration auf PostgreSQL (nur DAOs müssen angepasst werden) und ermöglicht isolierte Tests mit einer Testdatenbank.

Die Datenbankverbindung wird per Dependency Injection übergeben:

```python
class ProduktDAO:
    def __init__(self, db_connection):
        self.conn = db_connection
```

### 5.4 Funktionslogik (ShopServices)

Die Klasse `ShopServices` bündelt die gesamte Geschäftslogik. Sie nutzt die DAOs für Datenbankzugriffe und die Datenmodelle als Datenträger. Die Methoden sind in vier Gruppen unterteilt:

**Authentifizierung und Profil:** Verwaltet den Login und die Profildaten eines Benutzers. `login()` prüft E-Mail und Passwort-Hash und gibt bei Erfolg das `Benutzer`-Objekt zurück. `profil_bearbeiten()` und `profil_loeschen()` aktualisieren bzw. entfernen den Datensatz und lösen jeweils eine E-Mail-Benachrichtigung aus.

**Katalog und Suche:** `produkte_anzeigen()` nimmt ein Filter-Dictionary entgegen (z. B. Kategorie, Suchbegriff, Preisspanne) und gibt die gefilterte Produktliste zurück. `produkt_details()` liefert alle Informationen zu einem einzelnen Produkt anhand seiner UUID.

**Bestellprozess:** `bestellung_aufgeben()` verarbeitet den Warenkorb, legt die Bestellung mit allen Positionen in der Datenbank an und löst die Bestätigungsmail aus. Zusätzlich können Kunden eine Bestellung stornieren oder eine Erstattung beantragen.

**Admin-Funktionen:** Methoden wie `produkt_anlegen()`, `produkt_bearbeiten()` oder `bestellungen_einsehen()` erwarten als ersten Parameter ein `Benutzer`-Objekt mit der Rolle `ADMIN`. Fehlt diese Berechtigung, wird eine Exception geworfen, bevor irgendeine Aktion ausgeführt wird.

### 5.5 Migration auf PostgreSQL

Da die SQL-Logik vollständig in den DAOs gekapselt ist, beschränkt sich die Migration von MySQL auf PostgreSQL (Supabase) auf die Anpassung der Verbindungsparameter und kleinere SQL-Dialekt-Unterschiede. Alle Datenmodelle und die Geschäftslogik bleiben unverändert.

### 5.6 Frontend (Flutter)

Die Benutzeroberfläche ist eine plattformübergreifende Flutter-App (Material Design 3), die ausschließlich per REST/JSON mit dem Backend kommuniziert.

**Design:** Farben, Schriften und Abstände sind zentral in `app_theme.dart` und `design_tokens.dart` definiert. Hauptfarbe ist `#4CAF93` (Grün, passend zum nachhaltigen Charakter des Shops), Schriftart ist **Inter**.

**Responsives Layout:** Ein `LayoutBuilder` in der Root-Shell schaltet je nach Bildschirmbreite zwischen `NavigationBar` (unten, mobil) und `NavigationRail` (links, Desktop) um. Auf dem Desktop wird der Inhalt auf maximal 1200 px begrenzt.

**Routing:** `go_router` verwaltet alle Routen zentral. Nicht eingeloggte Nutzer werden auf `/login` weitergeleitet, Nicht-Admins aus dem Admin-Bereich auf die Startseite.

**Zustandsverwaltung:** `provider` mit `ChangeNotifier` trennt Logik und Darstellung. Jedes Feature hat einen eigenen Provider (`AuthProvider`, `CartProvider`, `ProductProvider` usw.).

**API-Anbindung:** `dio` sendet alle HTTP-Anfragen. Ein Interceptor hängt den JWT-Token automatisch an. Jeder Screen zeigt einen von drei Zuständen: Daten, Laden (Shimmer-Platzhalter) oder Fehler.

| Package              | Zweck                           |
| -------------------- | ------------------------------- |
| `provider`           | Zustandsverwaltung              |
| `go_router`          | Navigation                      |
| `dio`                | HTTP-Anfragen                   |
| `flutter_dotenv`     | Umgebungsvariablen              |
| `google_fonts`       | Schriftart Inter                |
| `shimmer`            | Lade-Platzhalter                |
| `shared_preferences` | Lokale Datenspeicherung (Token) |
| `flutter_svg`        | SVG-Grafiken                    |

---

## 6 Qualitätsmanagement

Zur Sicherstellung der Softwarequalität wurden verschiedene Testverfahren angewendet:

- **Unit-Tests (Backend):** Die einzelnen DAO-Klassen wurden mit `pytest` auf korrekte Datenverarbeitung geprüft. Dabei wurde sichergestellt, dass die CRUD-Operationen die erwarteten Ergebnisse liefern und Fehlerfälle (z. B. ungültige Eingaben) korrekt behandelt werden.

- **Integrationstests:** Das Zusammenspiel zwischen FastAPI-Endpunkten, DAOs und der MySQL-Datenbank wurde automatisiert getestet. Ziel war es, sicherzustellen, dass die gesamte Verarbeitungskette von der HTTP-Anfrage bis zur Datenbankoperation reibungslos funktioniert.

- **Manuelle Systemtests (Frontend):** Auf physischen Testgeräten (Android/iPhone) wurden die wesentlichen Nutzungsszenarien manuell durchgespielt. Dazu gehören unter anderem: Registrierung → Login → Produkte suchen → Warenkorb befüllen → Bestellung aufgeben → Bestätigungs-E-Mail erhalten.

---

## 7 Dokumentation

### 7.1 Entwicklerdokumentation
- **API-Dokumentation:** FastAPI generiert automatisch eine interaktive API-Dokumentation über Swagger UI (erreichbar unter `/docs`). Dort sind alle Endpunkte mit den erwarteten Parametern und Rückgabewerten dokumentiert.
- **Code-Dokumentation:** Alle Klassen und öffentlichen Methoden sind mit Python-Docstrings nach Google-Style dokumentiert, um eine schnelle Einarbeitung neuer Entwickler zu ermöglichen.
- **Architektur-Entscheidungen:** Die Designentscheidungen (z. B. UUIDs statt Auto-Increment-IDs, Decimal statt Float, DAO-Pattern) sind in dieser Projektdokumentation festgehalten.

---

## 8 Fazit

### 8.1 Soll-/Ist-Vergleich
Die im Fachkonzept definierten Anforderungen wurden weitgehend erfolgreich umgesetzt:

| Anforderung                       | Status    | Bemerkung                                                                    |
| --------------------------------- | --------- | ---------------------------------------------------------------------------- |
| Digitalisierung des Sortiments    | Umgesetzt | Produktkatalog mit Such- und Filterfunktion online verfügbar                 |
| Online-Bestellungen               | Umgesetzt | Warenkorb und Bestellprozess mit Datenbankpersistenz                         |
| Automatische E-Mail-Bestätigung   | Umgesetzt | Integration mit Resend (SMTP) für Bestell- und Kontobenachrichtigungen       |
| Login-System mit Rollenverwaltung | Umgesetzt | Supabase Auth mit JWT-Token und rollenbasierter Zugriffskontrolle            |
| Geschützter Admin-Bereich         | Umgesetzt | Dependency Injection prüft Benutzerrolle vor jeder Admin-Aktion              |
| Relationale Datenbank             | Umgesetzt | MySQL-Schema mit 6 Tabellen, CHECK-Constraints und referenzieller Integrität |
| DSGVO-konforme Datenhaltung       | Umgesetzt | Passwörter als bcrypt-Hash, Datenschutzerklärung, Recht auf Löschung         |

Das System ist stabil und die Datenhaltung durch Preis-Snapshots in den Bestellpositionen revisionssicher. Alle Projektphasen wurden innerhalb des geplanten Zeitrahmens von 80 Stunden abgeschlossen.

### 8.2 Aussichten
In zukünftigen Versionen könnte das System um folgende Funktionen erweitert werden:

- **Online-Zahlung:** Integration eines Zahlungsdienstleisters (z. B. PayPal oder Stripe), um den Bestellvorgang vollständig digital abzuwickeln.
- **Versandintegration:** Anbindung an einen Versanddienstleister für automatische Versandlabel und Sendungsverfolgung.
- **Produktbilder:** Upload und Anzeige von mehreren Bildern pro Produkt.
- **Bestandsmanagement:** Automatische Benachrichtigungen bei niedrigem Lagerbestand und Bestandshistorie.

---

## 9 Quellenverzeichnis

**Programmiersprachen & Frameworks**
- Python Software Foundation: *PEP 8 – Style Guide for Python Code.* https://peps.python.org/pep-0008/
- Python Software Foundation: *Modul `dataclasses` – Dokumentation.* https://docs.python.org/3/library/dataclasses.html
- FastAPI: *Offizielle Dokumentation.* https://fastapi.tiangolo.com/
- Flutter: *Offizielle Dokumentation.* https://docs.flutter.dev/
- Dart: *Offizielle Dokumentation.* https://dart.dev/guides

**Datenbank**
- MySQL: *Referenzhandbuch – Constraints und Datentypen.* https://dev.mysql.com/doc/
- PostgreSQL: *Offizielle Dokumentation.* https://www.postgresql.org/docs/
- Supabase: *Offizielle Dokumentation (Auth, Datenbank).* https://supabase.com/docs

**Sicherheit & Authentifizierung**
- UUID-Spezifikation: *RFC 4122 – Standards für universell eindeutige Identifikatoren.* https://www.rfc-editor.org/rfc/rfc4122
- Passlib: *Dokumentation – bcrypt Passwort-Hashing.* https://passlib.readthedocs.io/
- JSON Web Token (JWT): *RFC 7519 – Standard für JWT.* https://www.rfc-editor.org/rfc/rfc7519
- Europäisches Parlament: *Datenschutz-Grundverordnung (DSGVO), Verordnung (EU) 2016/679.* https://eur-lex.europa.eu/legal-content/DE/TXT/?uri=CELEX:32016R0679

**Flutter Packages**
- `go_router`: *Routing-Package für Flutter.* https://pub.dev/packages/go_router
- `provider`: *Zustandsverwaltung für Flutter.* https://pub.dev/packages/provider
- `dio`: *HTTP-Client für Dart/Flutter.* https://pub.dev/packages/dio

**Externe Dienste & Infrastruktur**
- Railway: *Offizielle Dokumentation.* https://docs.railway.app/
- Resend: *Offizielle Dokumentation (E-Mail-API).* https://resend.com/docs

**Sonstiges**
- Google: *Material Design 3 – Designsystem Dokumentation.* https://m3.material.io/
- pytest: *Offizielle Dokumentation.* https://docs.pytest.org/
- W3Schools: *Referenz für SQL (MySQL) und Python.* https://www.w3schools.com/
- Mozilla Developer Network (MDN): *Referenz für HTTP-Methoden, REST-API und JSON.* https://developer.mozilla.org/
- KI-gestützte Recherche und Textkorrektur durch das Large Language Model (LLM) Google Gemini.

---

## 10 Anhang

### UI Mockup

![Thriftshop UI Mockup](./assets/thriftshop_ui_mockup.pdf)

---

## 11 Anpassungen und Anmerkungen

- Produktlöschung als Soft Delete: Die ursprünglich geplante Löschfunktion für Produkte wurde als Soft Delete implementiert. Statt eines `DELETE`-Statements wird `produkt_aktiv = FALSE` gesetzt. Grund: Bestehende Bestellungen referenzieren Produkte – ein hartes Löschen würde die Bestellhistorie beschädigen. Für den Admin bleibt das Verhalten identisch; das Produkt verschwindet aus dem Shop. Eine endgültige Löschung muss direkt in der Datenbank durch einen Administrator erfolgen.
- Bestelllöschung als Statusänderung: Die ursprünglich geplante Löschfunktion für Bestellungen wurde als fachliche Statusänderung umgesetzt. Statt eines `DELETE`-Statements wird der Bestellstatus auf `Storniert` (bzw. im Rückabwicklungsfall auf `Erstattet`) gesetzt. Grund: Bestellungen sind buchhalterisch und historisch relevante Geschäftsvorfälle und müssen nachvollziehbar bleiben. Eine endgültige Löschung von Bestellungen ist im Anwendungssystem nicht vorgesehen.

- Routen für die benutzer `benutzer.py`:
1. `get_nach_email` – wird nicht als eigene Route exposiert, sondern spaeter intern beim Login genutzt (JWT-Authentifizierung).
2. `letzter_login_setzen` – wird ebenfalls intern beim Login aufgerufen, nicht direkt vom Frontend.

- Routen für die bestellposition `bestellposition.py`:
1. Kein POST – Positionen werden nur über POST /bestellungen/ erstellt
2. Kein PUT/DELETE – Snapshot-Daten sind unveraenderlich (historische Bestellungen)
3. Kein GET / (alle) – zu unspezifisch, fachlich nicht sinnvoll

- `Ruff`-Erweiterung für bessere Lesbarkeit und Python-Konventionsformatierung.
  
- Abhängigkeiten dokumentieren & installieren
  > Nach jedem `pip install` die `requirements.txt` aktualisieren. `Venv` muss aktiv sein und der Befehl im Projektroot (thriftshop/) ausgeführt werden:
  `pip freeze > requirements.txt`
  Ein anderes System kann das Projekt dann so einrichten:
  ```python
  python -m venv venv
  venv\Scripts\activate        # Windows
  pip install -r requirements.txt
  ```

- Modul-Docstrings für alle Dateien hinzugefügt.

- Automatisierte Tests unter `/backend/tests/`