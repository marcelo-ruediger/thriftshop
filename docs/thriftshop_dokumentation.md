# Projektdokumentation

#focus 

## 1 Einleitung

### 1.1 Projektumfeld
Auftraggeber ist die Thriftshop Köln GmbH, ein kleines, nachhaltiges Unternehmen mit Sitz in Köln. Das Kerngeschäft umfasst den Ankauf, die Aufbereitung und den Wiederverkauf von Second-Hand-Kleidung, Haushaltsgeräten und Dekorationsartikeln. Das Unternehmen ist seit drei Jahren am Markt und verzeichnet ein kontinuierliches Wachstum seines Kundenstamms.

Der bisherige Verkaufsprozess ist rein stationär und wird größtenteils manuell auf Papier dokumentiert. Es existiert keine digitale Lösung zur Produktverwaltung oder Bestellerfassung. Mit zunehmendem Wachstum stößt dieses Vorgehen an seine Grenzen: Kunden haben keinen Überblick über das aktuelle Sortiment, und Bestellungen müssen persönlich oder telefonisch aufgegeben werden. Dies führt zu ineffizienten Prozessen und eingeschränkter Reichweite.

### 1.2 Projektziel
- Schaffung einer digitalen Verkaufsplattform zur Präsentation des Second-Hand-Sortiments der Thriftshop Köln GmbH.
- Ermöglichung von Online-Bestellungen für Kunden unabhängig von Ort und Öffnungszeiten.
- Sicherstellung eines strukturierten Zugangs durch ein Login-System mit Rollenverwaltung für Kunden und Administratoren.
- E-Mail-Benachrichtigungen an Kunden versenden (Bestellung, Kontoerstellung, -löschung oder -bearbeitung). 
- Aller Bestell- und Produktdaten werden in einer relationalen Datenbank abgespeichert.

### 1.3 Projektbegründung
Bisher arbeitet der Thriftshop Köln nur vor Ort und nutzt Papier für die Verwaltung. Das ist sehr zeitaufwendig, fehleranfällig und macht es schwierig, den Überblick über die Waren zu behalten. Um weiter wachsen zu können, ist eine digitale Lösung notwendig.

Die Vorteile des neuen Systems sind:

Effizienteres Arbeiten: Durch die digitale Datenbank fallen Zettelwirtschaft und manuelle Fehler weg. Bestände und Bestellungen werden automatisch und sicher verwaltet.

Mehr Reichweite: Kunden können das Sortiment ab sofort rund um die Uhr online ansehen und bestellen. Das gewinnt neue Kunden außerhalb von Köln.

Moderne Technik: Die gewählten Technologien (Flutter, FastAPI) sind schnell und zukunftssicher. Das System kann später einfach um neue Funktionen erweitert werden.

Das Projekt sorgt dafür, dass der Thriftshop wettbewerbsfähig bleibt und sich von einem kleinen Laden zu einem modernen Online-Anbieter entwickelt.


### 1.4 Projektschnittstellen
Das Projekt hat verschiedene Verbindungspunkte (Schnittstellen), die für den Betrieb wichtig sind:

1. Technische Schnittstellen (Verbindungen im System)

App und Server: Die Flutter-App (Frontend) kommuniziert mit dem Python-Backend (FastAPI), um Daten auszutauschen.

Datenbank: Das Backend ist mit der MySQL-Datenbank verbunden, um Produkte und Bestellungen zu speichern.

E-Mail-Versand: Das System nutzt einen E-Mail-Dienst, um automatisch Bestätigungen an Kunden zu senden.

2. Benutzerschnittstellen (Wer nutzt das System?)

Administratoren: Die Mitarbeiter des Thriftshops nutzen einen geschützten Bereich, um das Sortiment zu verwalten.

Kunden: Nutzen die App, um das Sortiment zu sehen und zu bestellen. 

3. Organisatorische Schnittstellen (Personen)

Auftraggeber: Enge Abstimmung mit der Geschäftsführung der Thriftshop Köln GmbH über das Design und die Funktionen.


### 1.5 Projektabgrenzungen

1. In dieser Version des Webshops wird keine Zahlungsfunktion entwickelt oder von Dritten integriert (z. B. PayPal). Zahlungen erfolgen per Rechnung/Überweisung (die Rechnung wird per E-Mail verschickt) oder vor Ort bei der Abholung.

2. Lieferfunktionen werden im Webshop nicht abgebildet. Die Liefermöglichkeiten müssen direkt per Nachricht oder telefonisch mit der Triftshop Köln vereinbart werden. 


### 1.6 Allgemeine Bemerkungen

Datenschutz: Alle persönlichen Daten (z. B. Passwörter) werden verschlüsselt gespeichert. Es werden nur die Daten erhoben, die für die Bestellung unbedingt notwendig sind (gemäß DSGVO).

Erweiterbarkeit: Das System ist modular aufgebaut. Das bedeutet, dass man später sehr einfach neue Funktionen wie Online-Zahlung (PayPal) oder einen Versand-Service hinzufügen kann.

Test-Daten: Für die Entwicklung und die Tests wurden realitätsnahe Beispieldaten verwendet. So konnte die Suche und Filterung der Produkte schon vor dem echten Start ausgiebig geprüft werden.

---
## 2 Projektplannung

### 2.1 Projektphasen

**1. Definition (Gesamtzeit: 14 h)**
1.1 Ist-Analyse (Problemanalyse) (2 h)
1.2 Wirtschaftlichkeitsbetrachtung (2 h)
1.3 Anforderungen analysieren (2 h)
1.4 Use-Case Analyse (2 h)
1.5 Lasten- und Pflichtenheft erstellen (6 h)

**2. Planung (Gesamtzeit: 14 h)**
2.1 Arbeitspakete erstellen (Projektstrukturplan) (3 h)
2.2 Kostenplan und Zeitplan erstellen (Netzplan) (4 h)
2.3 Datenbankmodellierung inkl. ER-Modell (3 h)
2.4 Entwurf der Systemarchitektur mit Klassendiagramm (3 h)
2.5 Erstellung der UI-Mockups (1 h)

**3. Realisierung (Gesamtzeit: 40 h + 2 h Puffer)**
3.1 Einrichtung der Entwicklungsumgebung und Datenbankstruktur (2 h)
3.2 Implementierung der Datenbankzugriffe (CRUD-Operationen) (4 h)
3.3 Entwicklung der Benutzeroberfläche (6 h)
3.4 Implementierung des Bestellsystems mit Validierung und E-Mail-Bestätigung (6 h)
3.5 Implementierung des Login-Systems mit Benutzerauthentifizierung und Rollenverwaltung (5 h)
3.6 Implementierung der Such- und Filterfunktion (4 h)
3.7 Unit-Test (3 h)
3.8 Projektdokumentation (10 h)
3.9 Zeitpuffer: ein potenziell erhöhter Realisierungsaufwand (2 h) 

**4. Abschluss (Gesamtzeit: 10 h)**
4.1 System- und Integrationstest (3 h)
4.2 Code-Review (2 h)
4.3 Erstellung des Soll-Ist-Vergleichs (2 h)
4.4 Abnahme durch den Auftraggeber (2 h)
4.5 Schulung des Anwenders (1 h)

**Gesamtzeit des Projektes: 80 h**


### 2.2 Ressourcenplanung

**Personalressourcen:**
- Das Projekt wird von 1 Person geplant, entwickelt und getestet.  
- Der geschätzte Netto-Arbeitsaufwand liegt bei 80 Stunden (inkl. 2 Stunden Puffer für das Risikomanagement).
- Für die Verfügbarkeit sind 20 Stunden pro Woche berechnet, was einer Projektdauer von ca. 4 Wochen entspricht. 

**Technische Ressourcen:**
- Arbeitsgerät: Eigener Windows Laptop/PC für die Entwicklung. 
- Testgeräte: Physisches Smartphone (Android oder iPhone) zum Testen der Flutter-App unter realen Bedingungen.
- Werkzeuge/Software: Visual Studio Code für die Programmierung. 

**Infrastruktur & Externe Dienste:**
Für den Produktivbetrieb der Anwendung (Schnittstellen und Datenbank) werden folgende Dienste benötigt:
- Backend-Server: Für das Hosting der Python API (FastAPI) und Backend-Logik wird die Plattform Railway (Kostenloses Tier) verwendet.
- Datenbank-Server: Für die Entwicklung und das Testing wird zunächst ein lokaler MySQL-Server verwendet und später auf Supabase (PostgreSQL) migriert.
- Domain und SSL: Das Flutter-Frontend wird auf GitHub Pages deployed, was automatisch eine kostenlose Subdomain und ein gültiges SSL-Zertifikat bereitstellt. 
- E-Mail-Dienste (SMTP): Für den automatisierten Versand von Bestätigungen (Bestellungen, Kontoerstellung oder -entfernung) wird Resend (Kostenloses Tier) verwendet. *Hinweis:* Für die Authentifizierung wird das integrierte Supabase E-Mail-System benutzt.


### 2.3 Entwicklungsprozzess 

Da es sich bei dem geplanten Webshop um ein kleines Projekt mit fest definierten Anforderungen, Phasen und einem überschaubaren Gesamtaufwand von 80 Stunden handelt, wird ein klassisches Vorgehensmodell in Form des Wasserfallmodells gewählt. 

Die Projektphasen (Definition, Planung, Realisierung, Abschluss) werden streng sequenziell abgearbeitet. Eine neue Phase beginnt typischerweise erst, wenn die vorherige vollständig abgeschlossen und dokumentiert wurde. Für die Versionierung und Sicherung des Quellcodes wird Git (GitHub) eingesetzt, um Änderungen jederzeit nachvollziehen zu können.

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
- **Code Review:** Prüfung durch einen interner Softwareentwickler (5 Stunden × 140 €/h) = 700 €.
- **Gesamte Entwicklungskosten:** 1.900 €.
- **Laufende Infrastrukturkosten:** 0,00 € pro Monat (Nutzung von Railway Free Tier, Supabase, GitHub Pages und Resend).
- **Fremdkosten (App Stores - Optional):** Falls die App später in die Stores soll: Apple Developer (99 $/Jahr), Google Play (25 $ einmalig).

#### 3.2.3 Amortisationsdauer
Da die laufenden Betriebskosten faktisch entfallen, bemisst sich die Amortisation der anfänglichen (fiktiven) Entwicklungskosten (1.900 €) an der eingesparten Arbeitszeit. Spart die digitale Verwaltung pro Woche ca. 3 Arbeitsstunden (à 20 €) ein, so werden 60 € pro Woche gespart. Die Gesamtentwicklungskosten von 1.900 € haben sich somit nach ca. 32 Wochen (rund 8 Monaten) amortisiert.

### 3.3 Lastenheft/ Fachkonzept
Bei diesem Projekt wurde vom Auftraggeber kein klassisches Lastenheft vorgegeben. Das Problem, die gewünschten Lösungen, das Budget und die Ressourcen wurden stattdessen in einem Fachgespräch ermittelt und festgehalten. 

Es handelt sich um einen Webshop, der den gesamten Verkaufs- und Verwaltungsprozess der Thriftshop Köln GmbH durch folgende Maßnahmen vereinfachen und digitalisieren soll:

**1. Digitalisierung des Sortiments (Frontend):**
- Schaffung einer Plattform, auf der Kunden das Second-Hand-Sortiment jederzeit online einsehen können, unabhängig von den stationären Öffnungszeiten.
- Implementierung von Such- und Filterfunktionen zur besseren Übersicht.

**2. Digitale Bestellabwicklung:**
- Kunden können online verbindliche Bestellungen aufgeben, was den manuellen Aufgabenaufwand vor Ort reduziert und Fehler (Zettelwirtschaft) minimiert.
- Etablierung eines automatisierten E-Mail-Systems (Versand von Bestätigungen bei Bestellung, Registrierung oder Kontoänderung).

**3. Verwaltung und Datensicherheit (Backend):**
- Ein sicheres Login-System mit Rollenverwaltung zur strikten Trennung zwischen Kunden (Kauf) und Administratoren (Verwaltung).
- Mitarbeiter erhalten einen geschützten Admin-Bereich, um Bestände, Produkte und eingehende Bestellungen zentral in einer relationalen Datenbank zu verwalten.
- Alle Kundendaten werden gemäß DSGVO verwaltet (inkl. Passwortverschlüsselung).

**Abgrenzung (Nicht-Ziele der Iteration):**
- Der Webshop beinhaltet **keine** direkte Zahlungsfunktion (Abwicklung erfolgt auf Rechnung oder vor Ort).
- Es ist **kein** Liefer- oder Versandprozess integriert (Vereinbarungen manuell via Nachricht/Telefon).

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
   Das FastAPI-Backend kommuniziert sicher mit einer PostgreSQL-Datenbank, die von Supabase in der Cloud gehostet wird. Für die Entwicklung und Testing wird erstmal eine MySQL Datenbank verwendet. Hier werden alle persistenten Daten, wie Benutzerprofile, das Produktinventar und die Bestellungen, zentral verwaltet. Ein direkter Zugriff des Frontends auf die Datenbank ist aus Sicherheitsgründen technisch ausgeschlossen; die API dient als verbindlicher "Türsteher".


### 4.3 Datenmodell
Das objektorientierte Datenmodell der Anwendung umfasst sieben Klassen und zwei Enumerationen, welche die Struktur der gespeicherten Daten repräsentieren.

**Erklärung des Klassendiagramms:**
- **Benutzer:** Repräsentiert einen registrierten Kunden. Speichert persönliche Daten wie Name, E-Mail und einen gehashten Passwort. Die Eigenschaft `berechtigung` referenziert die Enumeration `Benutzerrolle` (ADMIN oder GAST) und legt die Zugriffsrechte fest. Ein Benutzer kann keine oder beliebig viele (`0..*`) Bestellungen aufgeben.
- **Administrator:** Erbt von `Benutzer`. Erweitert den Benutzer um Protokollierungsattribute (`letzter_login`, `letzte_aenderung`) und Methoden zur Verwaltung des Sortiments, z.B. `produkt_anlegen()`, `produkt_bearbeiten()`, `produkt_loeschen()` und `produkt_aktiv_toggle()`. Letztere invertiert den Aktivstatus eines Produkts und gibt den neuen Wert zurück. Dient für die Kontrolle von Produkte die im Sortiment angezeigt sind oder nicht, da Produkte die in eine Bestellposition vorhanden sind, dürfen nicht direkt gelöscht oder bearbeitet werden. 
- **Produkt:** Bildet einen Artikel des Thriftshops ab. Jedes Produkt besitzt eine eindeutige `produktsnummer`, einen `preis`, einen optionalen `produkt_rabatt` und das Flag `produkt_aktiv` (standardmäßig `True`). Ein Produkt ist genau einer `Kategorie` und genau einem `Zustand` zugeordnet. Es kann in keiner oder mehreren `BestellPosition`en vorkommen (`0..*`).
- **Kategorie:** Gruppiert Produkte thematisch (z.B. Kleidung, Elektronik). Besitzt einen optionalen `kategorie_rabatt`, der auf alle zugehörigen Produkte angewendet werden kann.
- **Zustand:** Beschreibt den physischen Zustand eines Produkts (z.B. neuwertig, gebraucht). Enthält eine `bezeichnung` und eine ausführliche `beschreibung`.
- **Bestellung:** Wird angelegt, sobald ein Kunde einen Kauf abschließt. Sie ist genau einem `Benutzer` zugeordnet und besitzt eine eindeutige `bestellungsnummer`, ein `bestellung_datum` sowie einen `status` aus der Enumeration `BestellStatus`. Die Beziehung zu `BestellPosition` ist eine Komposition (`*--`): Wird eine Bestellung gelöscht, werden auch alle zugehörigen Positionen entfernt.
- **BestellPosition:** Löst die m:n-Beziehung zwischen `Bestellung` und `Produkt` auf. Sie speichert die `menge` und den `positionspreis` – also den Preis des Produkts zum Zeitpunkt der Bestellung. Dadurch bleibt der Bestellwert korrekt, auch wenn sich der Produktpreis später ändert.
- **BestellStatus (Enum):** Definiert die möglichen Zustände einer Bestellung: `OFFEN`, `IN_BEARBEITUNG`, `ABGESCHLOSSEN` und `STORNIERT`.
- **Benutzerrolle (Enum):** Definiert die Rollen im System: `ADMIN` und `GAST`.

### 4.4 Test-Konzept
Zur Gewährleistung der Softwarequalität werden verschiedene Teststufen definiert:
- **Unit-Tests (Backend):** Die einzelnen FastAPI-Endpunkte und Geschäftslogiken werden isoliert (z.B. mit `pytest`) geprüft.
- **Integrationstests:** Das Zusammenspiel zwischen Backend und Datenbank wird automatisiert getestet.
- **Manuelle Systemtests (Frontend):** Auf physischen Testgeräten (Android/iPhone) werden die UI/UX und Nutzerführungen (Registrierung -> Artikel in Warenkorb -> Bestellung) manuell durchgespielt.

### 4.5 Pflichtenheft
Das Pflichtenheft beschreibt detailliert die technische und gestalterische Umsetzung des im Fachkonzept (siehe 3.3) geforderten Lastenhefts durch den Entwickler. Es enthält unter anderem die konkreten Endpunkte der REST-API, das finale Datenbankschema (ERD), das detaillierte UI-Mockup (z.B. in Figma) und die Zielplattform-Dokumentation.

---

## 5 Implementierungsphase

### 5.1 Erstellen der Projektstruktur
### 5.2 Implementierung der Datenstruktur
### 5.3 Implementierung der Funktionslogik
#### 5.3.1 Module Entity
#### 5.3.2 ModuleController
#### 5.3.3 ModuleRepository
#### 5.3.4 ModuleLoader
#### 5.3.5 PageController

---

## 6 Qualitätsmanagement

---

## 7 Dokumentation

### 7.1 Entwicklerdokumentation

---

## 8 Fazit

### 8.1 Soll-/Ist-Vergleich
### 8.2 Aussichten

---

## 9 Quellenverzeichnis

---

## 10 Anhang

---
