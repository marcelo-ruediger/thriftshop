### 1. Thema der Projektarbeit

Realisierung einer webbasierten Shopping-Plattform zur Darstellung von Second-Hand-Produkten und Erfassung von Kundenbestellungen für die Thriftshop Köln GmbH

### 2. Geplanter Bearbeitungszeitraum

Beginn: 18.03.2026  
Ende: 22.04.2026 

### 3. Projektbeschreibung

Die Thriftshop Köln GmbH betreibt ein nachhaltiges Geschäftsmodell: Second-Hand-Kleidung, Haushaltsgeräte und Dekorationsartikel werden von Dritten erworben, aufbereitet und anschließend an Kunden weiterverkauft. Da der bisherige Verkaufsprozess ausschließlich stationär und größtenteils manuell auf Papier abgewickelt wird, ist eine Skalierung des Geschäfts nur begrenzt möglich. Ziel des Projektes ist die Entwicklung einer webbasierten Shopping-Plattform, die Kunden ermöglicht, das aktuelle Produktsortiment online einzusehen und Bestellungen aufzugeben, sowie dem Personal eine effiziente digitale Verwaltung bietet.

#### 3.1. Zielsetzung

- Schaffung einer digitalen Verkaufsplattform zur Präsentation des Second-Hand-Sortiments der Thriftshop Köln GmbH.
- Ermöglichung von Online-Bestellungen für Kunden unabhängig von Ort und Öffnungszeiten.
- Sicherstellung eines strukturierten Zugangs durch ein Login-System mit Rollenverwaltung für Kunden und Administratoren.
- E-Mail-Benachrichtigungen an Kunden versenden (Bestellung, Kontoerstellung, -löschung oder -bearbeitung). 
- Aller Bestell- und Produktdaten werden in einer relationalen Datenbank abgespeichert.


#### 3.2 Projektabgrenzungen 

- In dieser Version des Webshops wird keine Zahlungsfunktion entwickelt oder von Dritten integriert (z. B. PayPal). Zahlungen erfolgen per Rechnung/Überweisung (die Rechnung wird per E-Mail verschickt) oder vor Ort bei der Abholung.
- Lieferfunktionen werden im Webshop nicht abgebildet. Die Liefermöglichkeiten müssen direkt per Nachricht oder telefonisch mit der Triftshop Köln vereinbart werden.  

#### 3.3. Aufgaben

- Ist-Analyse der bestehenden Geschäftsprozesse und Erhebung der funktionalen Anforderungen (Use-Case Analyse, Lasten- und Pflichtenheft).
- Durchführung einer Wirtschaftlichkeitsbetrachtung, Kostenplannung und Zeitplannung.
- Datenbankmodellierung: Erstellung eines ER-Modells für Produkte, Kategorien, Kunden, Bestellungen und Benutzer.
- Entwurf der Systemarchitektur - Erstellung eines Klassendiagramms.
- Erstellung von UI-Mockups (Produktübersicht, Detailseite, Warenkorb, Login und Administrationsbereich).
- Implementierung der Datenbankstruktur und der CRUD-Operationen für die Produktverwaltung.
- Entwicklung des Flutter-Frontends mit Produktübersicht, Detailseite und Such- sowie Filterfunktion.
- Implementierung des Login-Systems mit Benutzerauthentifizierung und Rollenverwaltung (Kunde / Admin).
- Implementierung des Bestellsystems mit serverseitiger Validierung der Eingabedaten und E-Mail-Versand zur Bestellbestätigung.
- Entwicklung des Administrationsbereichs zum Hinzufügen, Löschen und Bearbeiten von Produkten und Bestellungen.
- Durchführung von Unit- und Integrationstests sowie Benutzerakzeptanztest und Fehlerbehebung.

#### 3.4. Technische Ressourcen

Als Backend-Technologie wird Python mit dem Framework FastAPI eingesetzt, die Datenbankanbindung erfolgt über MySQL. Das Frontend wird mit Flutter entwickelt, wodurch die Anwendung plattformübergreifend auf Desktop, Tablet und Smartphone lauffähig ist. Als Editor wird Visual Studio Code verwendet, die Versionskontrolle erfolgt über Git und GitHub.

### 4. Projektumfeld

Auftraggeber ist die Thriftshop Köln GmbH, ein kleines, nachhaltiges Unternehmen mit Sitz in Köln. Das Kerngeschäft umfasst den Ankauf, die Aufbereitung und den Wiederverkauf von Second-Hand-Kleidung, Haushaltsgeräten und Dekorationsartikeln. Das Unternehmen ist seit drei Jahren am Markt und verzeichnet ein kontinuierliches Wachstum seines Kundenstamms.

Der bisherige Verkaufsprozess ist rein stationär und wird größtenteils manuell auf Papier dokumentiert. Es existiert keine digitale Lösung zur Produktverwaltung oder Bestellerfassung. Mit zunehmendem Wachstum stößt dieses Vorgehen an seine Grenzen: Kunden haben keinen Überblick über das aktuelle Sortiment, und Bestellungen müssen persönlich oder telefonisch aufgegeben werden. Dies führt zu ineffizienten Prozessen und eingeschränkter Reichweite.

### 5. Projektphasen mit Zeitplanung

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
4.5 Schulungs des Anwenders (1 h)

**Gesamtzeit des Projektes: 80 h**

### Präsentationsmittel

- Beamer, Notebook, 15 Minuten Rüstzeit


