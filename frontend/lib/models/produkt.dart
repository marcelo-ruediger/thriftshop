/// Produkt - entspricht `ProduktAusgabe` im Backend.
library;

import '../core/config.dart';

class Produkt {
  const Produkt({
    required this.produktId,
    required this.produktnr,
    required this.bezeichnung,
    required this.slug,
    required this.produktInfo,
    required this.preis,
    required this.produktRabatt,
    required this.rabattProzent,
    required this.endpreis,
    required this.steuersatz,
    required this.lagerbestand,
    required this.zustandId,
    required this.kategorieId,
    required this.produktAktiv,
    required this.erstellungsdatum,
    this.bildpfad,
  });

  final String produktId;
  final String produktnr;
  final String bezeichnung;
  final String slug;
  final String produktInfo;

  /// Listenpreis (brutto) ohne Rabatt.
  final double preis;

  /// Am Produkt hinterlegter Rabatt in Prozent.
  final double produktRabatt;

  /// Wirksamer Rabatt in Prozent (der höhere von Produkt- und Kategorierabatt).
  final double rabattProzent;

  /// Preis, den der Kunde bezahlt.
  final double endpreis;
  final double steuersatz;
  final int lagerbestand;
  final String zustandId;
  final String kategorieId;
  final String? bildpfad;
  final bool produktAktiv;
  final DateTime erstellungsdatum;

  bool get reduziert => rabattProzent > 0;
  bool get ausverkauft => lagerbestand <= 0;
  bool get einzelstueck => lagerbestand == 1;
  String? get bildUrl => bildpfad == null ? null : AppConfig.bildUrl(bildpfad!);

  factory Produkt.fromJson(Map<String, dynamic> json) => Produkt(
    produktId: json['produkt_id'] as String,
    produktnr: json['produktnr'] as String,
    bezeichnung: json['bezeichnung'] as String,
    slug: json['slug'] as String,
    produktInfo: json['produkt_info'] as String,
    preis: (json['preis'] as num).toDouble(),
    produktRabatt: (json['produkt_rabatt'] as num).toDouble(),
    rabattProzent: (json['rabatt_prozent'] as num).toDouble(),
    endpreis: (json['endpreis'] as num).toDouble(),
    steuersatz: (json['steuersatz'] as num).toDouble(),
    lagerbestand: (json['lagerbestand'] as num).toInt(),
    zustandId: json['zustand_id'] as String,
    kategorieId: json['kategorie_id'] as String,
    bildpfad: json['bildpfad'] as String?,
    produktAktiv: json['produkt_aktiv'] as bool,
    erstellungsdatum: DateTime.parse(json['erstellungsdatum'] as String),
  );

  /// Für den im Browser gespeicherten Warenkorb.
  Map<String, dynamic> toJson() => {
    'produkt_id': produktId,
    'produktnr': produktnr,
    'bezeichnung': bezeichnung,
    'slug': slug,
    'produkt_info': produktInfo,
    'preis': preis,
    'produkt_rabatt': produktRabatt,
    'rabatt_prozent': rabattProzent,
    'endpreis': endpreis,
    'steuersatz': steuersatz,
    'lagerbestand': lagerbestand,
    'zustand_id': zustandId,
    'kategorie_id': kategorieId,
    'bildpfad': bildpfad,
    'produkt_aktiv': produktAktiv,
    'erstellungsdatum': erstellungsdatum.toIso8601String(),
  };
}

/// Eingabedaten zum Anlegen oder Bearbeiten eines Produkts (`ProduktAnfrage`).
class ProduktEingabe {
  const ProduktEingabe({
    required this.bezeichnung,
    required this.produktInfo,
    required this.preis,
    required this.produktRabatt,
    required this.zustandId,
    required this.kategorieId,
    required this.produktAktiv,
    this.lagerbestand,
    this.bildpfad,
  });

  final String bezeichnung;
  final String produktInfo;
  final double preis;
  final double produktRabatt;

  /// `null` lässt den Bestand unverändert. Beim Bearbeiten wird er nur gesendet,
  /// wenn er im Formular geändert wurde - sonst würde ein veralteter Wert einen
  /// Bestand überschreiben, den Bestellungen inzwischen verringert haben.
  final int? lagerbestand;
  final String zustandId;
  final String kategorieId;
  final String? bildpfad;
  final bool produktAktiv;

  Map<String, dynamic> toJson() => {
    'bezeichnung': bezeichnung,
    'produkt_info': produktInfo,
    // Als Text mit zwei Nachkommastellen - das Backend rechnet mit Decimal
    'preis': preis.toStringAsFixed(2),
    'produkt_rabatt': produktRabatt.toStringAsFixed(2),
    'lagerbestand': ?lagerbestand,
    'zustand_id': zustandId,
    'kategorie_id': kategorieId,
    'bildpfad': bildpfad,
    'produkt_aktiv': produktAktiv,
  };
}
