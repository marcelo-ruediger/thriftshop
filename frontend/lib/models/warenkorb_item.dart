/// Warenkorb-Item für die Thriftshop-App
import '../models/produkt.dart';

class WarenkorbItem {
  final Produkt produkt;
  int menge;

  WarenkorbItem({
    required this.produkt,
    required this.menge,
  });

  Map<String, dynamic> toJson() {
    return {
      'produkt': produkt.toJson(),
      'menge': menge,
    };
  }

  factory WarenkorbItem.fromJson(Map<String, dynamic> json) {
    return WarenkorbItem(
      produkt: Produkt.fromJson(json['produkt'] as Map<String, dynamic>),
      menge: json['menge'] as int,
    );
  }

  WarenkorbItem copyWith({
    Produkt? produkt,
    int? menge,
  }) {
    return WarenkorbItem(
      produkt: produkt ?? this.produkt,
      menge: menge ?? this.menge,
    );
  }
}
