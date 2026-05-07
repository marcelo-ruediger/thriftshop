/// Das Kategorie-Modell für den Thriftshop
/// Entspricht dem Python-Kategorie-Modell aus dem Backend
library;

import 'dart:convert';

/// Eine Kategorie für Produkte im Thriftshop
class Kategorie {
  /// Die eindeutige ID der Kategorie
  final String kategorieId;

  /// Die Bezeichnung der Kategorie
  final String bezeichnung;

  /// Der URL-slug der Kategorie
  final String slug;

  /// Der Rabatt für diese Kategorie in Prozent
  final double kategorieRabatt;

  /// Der Steuersatz für diese Kategorie in Prozent
  final double steuersatz;

  /// Konstruktor für Kategorie
  Kategorie({
    required this.kategorieId,
    required this.bezeichnung,
    required this.slug,
    required this.kategorieRabatt,
    required this.steuersatz,
  });

  /// Erstellt eine Kategorie aus JSON
  factory Kategorie.fromJson(Map<String, dynamic> json) {
    return Kategorie(
      kategorieId: json['kategorie_id'] as String,
      bezeichnung: json['bezeichnung'] as String,
      slug: json['slug'] as String,
      kategorieRabatt: (json['kategorie_rabatt'] as num).toDouble(),
      steuersatz: (json['steuersatz'] as num).toDouble(),
    );
  }

  /// Konvertiert die Kategorie in JSON
  Map<String, dynamic> toJson() {
    return {
      'kategorie_id': kategorieId,
      'bezeichnung': bezeichnung,
      'slug': slug,
      'kategorie_rabatt': kategorieRabatt,
      'steuersatz': steuersatz,
    };
  }

  /// Konvertiert die Kategorie in einen JSON-String
  String toJsonString() => json.encode(toJson());

  /// Erstellt eine Kategorie aus einem JSON-String
  factory Kategorie.fromJsonString(String jsonString) =>
      Kategorie.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
