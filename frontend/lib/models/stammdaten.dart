/// Stammdaten des Katalogs: Kategorien und Zustände.
library;

class Kategorie {
  const Kategorie({
    required this.kategorieId,
    required this.bezeichnung,
    required this.slug,
    required this.kategorieRabatt,
    required this.steuersatz,
  });

  final String kategorieId;
  final String bezeichnung;
  final String slug;

  /// Rabatt in Prozent, der für alle Produkte der Kategorie gilt.
  final double kategorieRabatt;
  final double steuersatz;

  factory Kategorie.fromJson(Map<String, dynamic> json) => Kategorie(
    kategorieId: json['kategorie_id'] as String,
    bezeichnung: json['bezeichnung'] as String,
    slug: json['slug'] as String,
    kategorieRabatt: (json['kategorie_rabatt'] as num).toDouble(),
    steuersatz: (json['steuersatz'] as num).toDouble(),
  );
}

class Zustand {
  const Zustand({
    required this.zustandId,
    required this.bezeichnung,
    required this.beschreibung,
  });

  final String zustandId;
  final String bezeichnung;
  final String beschreibung;

  factory Zustand.fromJson(Map<String, dynamic> json) => Zustand(
    zustandId: json['zustand_id'] as String,
    bezeichnung: json['bezeichnung'] as String,
    beschreibung: json['beschreibung'] as String,
  );
}
