/// Eine Position im Warenkorb.
library;

import 'produkt.dart';

class WarenkorbItem {
  const WarenkorbItem({required this.produkt, required this.menge});

  final Produkt produkt;
  final int menge;

  double get summe => produkt.endpreis * menge;

  /// Enthaltene Mehrwertsteuer (die Preise sind Bruttopreise) - wie im Backend
  /// je Position auf ganze Cent gerundet.
  double get mwst =>
      (summe * produkt.steuersatz / (100 + produkt.steuersatz) * 100).round() / 100;

  WarenkorbItem kopie({Produkt? produkt, int? menge}) =>
      WarenkorbItem(produkt: produkt ?? this.produkt, menge: menge ?? this.menge);

  factory WarenkorbItem.fromJson(Map<String, dynamic> json) => WarenkorbItem(
    produkt: Produkt.fromJson(json['produkt'] as Map<String, dynamic>),
    menge: (json['menge'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {'produkt': produkt.toJson(), 'menge': menge};
}
