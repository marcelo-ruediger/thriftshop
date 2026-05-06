/// Das Bestellung-Modell für den Thriftshop
/// Entspricht dem Python-Bestellung-Modell aus dem Backend
import 'dart:convert';

/// Eine Bestellung im Thriftshop
class Bestellung {
  /// Die eindeutige ID der Bestellung
  final String bestellungId;

  /// Die laufende Nummer der Bestellung
  final int laufendeNr;

  /// Der Status der Bestellung
  final String status;

  /// Das Bestelldatum
  final DateTime bestelldatum;

  /// Die ID des Kunden, der die Bestellung aufgegeben hat
  final String benutzerId;

  /// Konstruktor für Bestellung
  Bestellung({
    required this.bestellungId,
    required this.laufendeNr,
    required this.status,
    required this.bestelldatum,
    required this.benutzerId,
  });

  /// Erstellt eine Bestellung aus JSON
  factory Bestellung.fromJson(Map<String, dynamic> json) {
    return Bestellung(
      bestellungId: json['bestellung_id'] as String,
      laufendeNr: (json['laufende_nr'] as num).toInt(),
      status: json['status'] as String,
      bestelldatum: DateTime.parse(json['bestelldatum'] as String),
      benutzerId: json['benutzer_id'] as String,
    );
  }

  /// Konvertiert die Bestellung in JSON
  Map<String, dynamic> toJson() {
    return {
      'bestellung_id': bestellungId,
      'laufende_nr': laufendeNr,
      'status': status,
      'bestelldatum': bestelldatum.toIso8601String(),
      'benutzer_id': benutzerId,
    };
  }

  /// Konvertiert die Bestellung in einen JSON-String
  String toJsonString() => json.encode(toJson());

  /// Erstellt eine Bestellung aus einem JSON-String
  factory Bestellung.fromJsonString(String jsonString) =>
      Bestellung.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
