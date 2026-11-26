/// Bestellung mit ihren Positionen - entspricht `BestellungAusgabe` im Backend.
library;

import '../core/config.dart';

class Bestellstatus {
  Bestellstatus._();
  static const String offen = 'Offen';
  static const String inBearbeitung = 'In Bearbeitung';
  static const String abgeschlossen = 'Abgeschlossen';
  static const String storniert = 'Storniert';
  static const String erstattet = 'Erstattet';
  static const List<String> alle = [
    offen,
    inBearbeitung,
    abgeschlossen,
    storniert,
    erstattet,
  ];

  /// Erlaubte Folgestatus - dieselben Regeln prüft auch das Backend.
  static const Map<String, List<String>> uebergaenge = {
    offen: [inBearbeitung, storniert],
    inBearbeitung: [abgeschlossen, storniert],
    abgeschlossen: [erstattet],
    storniert: [erstattet],
    erstattet: [],
  };
}

class Zahlungsarten {
  Zahlungsarten._();
  static const String abholung = 'Zahlung bei Abholung';
  static const String rechnung = 'Rechnung';
}

class Bestellposition {
  const Bestellposition({
    required this.bestellpositionId,
    required this.produktId,
    required this.menge,
    required this.einzelpreisGebucht,
    required this.rabattAngewendet,
    required this.steuersatzGebucht,
    required this.gesamtpreis,
    this.bezeichnung,
    this.slug,
    this.bildpfad,
  });

  final String bestellpositionId;
  final String produktId;
  final String? bezeichnung;
  final String? slug;
  final String? bildpfad;
  final int menge;

  /// Listenpreis zum Kaufzeitpunkt.
  final double einzelpreisGebucht;

  /// Rabatt in Euro pro Stück zum Kaufzeitpunkt.
  final double rabattAngewendet;
  final double steuersatzGebucht;
  final double gesamtpreis;

  double get stueckpreis => einzelpreisGebucht - rabattAngewendet;
  String? get bildUrl => bildpfad == null ? null : AppConfig.bildUrl(bildpfad!);

  factory Bestellposition.fromJson(Map<String, dynamic> json) => Bestellposition(
    bestellpositionId: json['bestellposition_id'] as String,
    produktId: json['produkt_id'] as String,
    bezeichnung: json['bezeichnung'] as String?,
    slug: json['slug'] as String?,
    bildpfad: json['bildpfad'] as String?,
    menge: (json['menge'] as num).toInt(),
    einzelpreisGebucht: (json['einzelpreis_gebucht'] as num).toDouble(),
    rabattAngewendet: (json['rabatt_angewendet'] as num).toDouble(),
    steuersatzGebucht: (json['steuersatz_gebucht'] as num).toDouble(),
    gesamtpreis: (json['gesamtpreis_brutto'] as num).toDouble(),
  );
}

class Bestellung {
  const Bestellung({
    required this.bestellungId,
    required this.bestellnr,
    required this.status,
    required this.bestelldatum,
    required this.zahlungsart,
    required this.benutzerId,
    required this.artikelAnzahl,
    required this.gesamtpreis,
    required this.enthalteneMwst,
    required this.positionen,
    this.anmerkung,
    this.kundeName,
    this.kundeEmail,
  });

  final String bestellungId;
  final String bestellnr;
  final String status;
  final DateTime bestelldatum;
  final String zahlungsart;
  final String? anmerkung;
  final String benutzerId;
  final String? kundeName;
  final String? kundeEmail;
  final int artikelAnzahl;
  final double gesamtpreis;
  final double enthalteneMwst;
  final List<Bestellposition> positionen;

  bool get stornierbar => status == Bestellstatus.offen;

  factory Bestellung.fromJson(Map<String, dynamic> json) => Bestellung(
    bestellungId: json['bestellung_id'] as String,
    bestellnr: json['bestellnr'] as String,
    status: json['status'] as String,
    bestelldatum: DateTime.parse(json['bestelldatum'] as String),
    zahlungsart: json['zahlungsart'] as String,
    anmerkung: json['anmerkung'] as String?,
    benutzerId: json['benutzer_id'] as String,
    kundeName: json['kunde_name'] as String?,
    kundeEmail: json['kunde_email'] as String?,
    artikelAnzahl: (json['artikel_anzahl'] as num).toInt(),
    gesamtpreis: (json['gesamtpreis'] as num).toDouble(),
    enthalteneMwst: (json['enthaltene_mwst'] as num).toDouble(),
    positionen: (json['positionen'] as List)
        .map((p) => Bestellposition.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}

/// Kennzahlen für das Admin-Dashboard.
class Statistik {
  const Statistik({
    required this.umsatz,
    required this.bestellungenGesamt,
    required this.bestellungenJeStatus,
    required this.produkteAktiv,
    required this.produkteAusverkauft,
    required this.kunden,
  });

  final double umsatz;
  final int bestellungenGesamt;
  final Map<String, int> bestellungenJeStatus;
  final int produkteAktiv;
  final int produkteAusverkauft;
  final int kunden;

  int anzahl(String status) => bestellungenJeStatus[status] ?? 0;

  factory Statistik.fromJson(Map<String, dynamic> json) => Statistik(
    umsatz: (json['umsatz'] as num).toDouble(),
    bestellungenGesamt: (json['bestellungen_gesamt'] as num).toInt(),
    bestellungenJeStatus: (json['bestellungen_je_status'] as Map).map(
      (status, anzahl) => MapEntry(status as String, (anzahl as num).toInt()),
    ),
    produkteAktiv: (json['produkte_aktiv'] as num).toInt(),
    produkteAusverkauft: (json['produkte_ausverkauft'] as num).toInt(),
    kunden: (json['kunden'] as num).toInt(),
  );
}
