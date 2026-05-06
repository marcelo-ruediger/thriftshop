/// Das Produkt-Modell für den Thriftshop
/// Entspricht dem Python-Produkt-Modell aus dem Backend
import 'dart:convert';

/// Ein Produkt im Thriftshop
class Produkt {
  /// Die eindeutige ID des Produkts
  final String produktId;

  /// Die laufende Nummer des Produkts
  final int laufendeNr;

  /// Die Bezeichnung des Produkts
  final String bezeichnung;

  /// Der URL-slug des Produkts
  final String slug;

  /// Die Produktinformationen
  final String produktInfo;

  /// Der Preis des Produkts
  final double preis;

  /// Der Rabatt für dieses Produkt in Prozent
  final double produktRabatt;

  /// Der aktuelle Lagerbestand
  final int lagerbestand;

  /// Die ID des Zustands des Produkts
  final String zustandId;

  /// Die ID der Kategorie des Produkts
  final String kategorieId;

  /// Gibt an, ob das Produkt aktiv ist
  final bool produktAktiv;

  /// Das Erstellungsdatum des Produkts
  final DateTime? erstellungsdatum;

  /// Die Produktnummer (kommt vom Backend als String)
  final String produktnr;

  /// Konstruktor für Produkt
  Produkt({
    required this.produktId,
    required this.laufendeNr,
    required this.bezeichnung,
    required this.slug,
    required this.produktInfo,
    required this.preis,
    required this.produktRabatt,
    required this.lagerbestand,
    required this.zustandId,
    required this.kategorieId,
    this.produktAktiv = true,
    required this.produktnr,
    DateTime? erstellungsdatum,
  }) : erstellungsdatum = erstellungsdatum ?? DateTime.now();

  /// Erstellt ein Produkt-Objekt aus JSON
  factory Produkt.fromJson(Map<String, dynamic> json) {
    return Produkt(
      produktId: json['produkt_id'] as String,
      laufendeNr: (json['laufende_nr'] as num).toInt(),
      bezeichnung: json['bezeichnung'] as String,
      slug: json['slug'] as String,
      produktInfo: json['produkt_info'] as String,
      preis: (json['preis'] as num).toDouble(),
      produktRabatt: (json['produkt_rabatt'] as num).toDouble(),
      lagerbestand: (json['lagerbestand'] as num).toInt(),
      zustandId: json['zustand_id'] as String,
      kategorieId: json['kategorie_id'] as String,
      produktAktiv: json['produkt_aktiv'] as bool? ?? true,
      erstellungsdatum: json['erstellungsdatum'] == null
          ? null
          : DateTime.parse(json['erstellungsdatum'] as String),
      produktnr: json['produktnr'] as String,
    );
  }

  /// Konvertiert das Produkt-Objekt in JSON
  Map<String, dynamic> toJson() {
    return {
      'produkt_id': produktId,
      'laufende_nr': laufendeNr,
      'bezeichnung': bezeichnung,
      'slug': slug,
      'produkt_info': produktInfo,
      'preis': preis,
      'produkt_rabatt': produktRabatt,
      'lagerbestand': lagerbestand,
      'zustand_id': zustandId,
      'kategorie_id': kategorieId,
      'produkt_aktiv': produktAktiv,
      'erstellungsdatum': erstellungsdatum?.toIso8601String(),
      'produktnr': produktnr,
    };
  }

  /// Konvertiert das Produkt in einen JSON-String
  String toJsonString() => json.encode(toJson());

  /// Erstellt ein Produkt-Objekt aus einem JSON-String
  factory Produkt.fromJsonString(String jsonString) =>
      Produkt.fromJson(json.decode(jsonString) as Map<String, dynamic>);
}
