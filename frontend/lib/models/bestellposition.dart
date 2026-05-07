/// Das Bestellposition-Modell für den Thriftshop
/// Entspricht dem Python-Bestellposition-Modell aus dem Backend
library;

import 'dart:convert';

/// Eine Position in einer Bestellung
class Bestellposition {
  /// Die eindeutige ID der Bestellposition
  final String bestellpositionId;

  /// Die Menge des Produkts
  final int menge;

  /// Der Einzelpreis nach Rabatt (gebucht)
  final double einzelpreisGebucht;

  /// Der angewendete Rabatt pro Einheit
  final double rabattAngewendet;

  /// Der gebuchte Steuersatz in Prozent
  final double steuersatzGebucht;

  /// Die ID des Produkts
  final String produktId;

  /// Die ID der zugehörigen Bestellung
  final String bestellungId;

  /// Konstruktor für Bestellposition
  Bestellposition({
    required this.bestellpositionId,
    required this.menge,
    required this.einzelpreisGebucht,
    required this.rabattAngewendet,
    required this.steuersatzGebucht,
    required this.produktId,
    required this.bestellungId,
  });

  /// Berechneter Gesamtpreis Netto (ohne Steuern)
  double get gesamtpreisNetto =>
      (einzelpreisGebucht - rabattAngewendet) * menge;

  /// Berechneter Gesamtpreis Brutto (mit Steuern)
  double get gesamtpreisBrutto {
    double steuerFaktor = 1 + (steuersatzGebucht / 100);
    return gesamtpreisNetto * steuerFaktor;
  }

  /// Erstellt ein Bestellposition-Objekt aus JSON
  factory Bestellposition.fromJson(Map<String, dynamic> json) {
    return Bestellposition(
      bestellpositionId: json['bestellposition_id'] as String,
      menge: (json['menge'] as num).toInt(),
      einzelpreisGebucht: (json['einzelpreis_gebucht'] as num).toDouble(),
      rabattAngewendet: (json['rabatt_angewendet'] as num).toDouble(),
      steuersatzGebucht: (json['steuersatz_gebucht'] as num).toDouble(),
      produktId: json['produkt_id'] as String,
      bestellungId: json['bestellung_id'] as String,
    );
  }

  /// Konvertiert das Bestellposition-Objekt in JSON
  Map<String, dynamic> toJson() {
    return {
      'bestellposition_id': bestellpositionId,
      'menge': menge,
      'einzelpreis_gebucht': einzelpreisGebucht,
      'rabatt_angewendet': rabattAngewendet,
      'steuersatz_gebucht': steuersatzGebucht,
      'produkt_id': produktId,
      'bestellung_id': bestellungId,
    };
  }

  /// Konvertiert das Bestellposition in einen JSON-String
  String toJsonString() => json.encode(toJson());

  /// Erstellt ein Bestellposition-Objekt aus einem JSON-String
  factory Bestellposition.fromJsonString(String jsonString) =>
      Bestellposition.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
