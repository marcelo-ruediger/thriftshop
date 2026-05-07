/// Das Zustand-Modell für den Thriftshop
/// Entspricht dem Python-Zustand-Modell aus dem Backend
library;

import 'dart:convert';

/// Der Zustand eines Produkts (z.B. neu, gebraucht, etc.)
class Zustand {
  /// Die eindeutige ID des Zustands
  final String zustandId;

  /// Die Bezeichnung des Zustands
  final String bezeichnung;

  /// Eine Beschreibung des Zustands
  final String beschreibung;

  /// Konstruktor für Zustand
  Zustand({
    required this.zustandId,
    required this.bezeichnung,
    required this.beschreibung,
  });

  /// Erstellt einen Zustand aus JSON
  factory Zustand.fromJson(Map<String, dynamic> json) {
    return Zustand(
      zustandId: json['zustand_id'] as String,
      bezeichnung: json['bezeichnung'] as String,
      beschreibung: json['beschreibung'] as String,
    );
  }

  /// Konvertiert den Zustand in JSON
  Map<String, dynamic> toJson() {
    return {
      'zustand_id': zustandId,
      'bezeichnung': bezeichnung,
      'beschreibung': beschreibung,
    };
  }

  /// Konvertiert den Zustand in einen JSON-String
  String toJsonString() => json.encode(toJson());

  /// Erstellt einen Zustand aus einem JSON-String
  factory Zustand.fromJsonString(String jsonString) =>
      Zustand.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
