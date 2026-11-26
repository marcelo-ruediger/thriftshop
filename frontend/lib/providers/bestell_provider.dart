/// Bestellungen des angemeldeten Kunden: laden, aufgeben, stornieren.
library;

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/bestellung.dart';
import '../models/warenkorb_item.dart';
import '../services/shop_api.dart';

class BestellProvider extends ChangeNotifier {
  BestellProvider(this._api);

  final ShopApi _api;

  List<Bestellung>? _bestellungen;
  bool _laedt = false;
  String? _fehler;

  /// `null`, solange noch nie geladen wurde.
  List<Bestellung>? get bestellungen => _bestellungen;
  bool get laedt => _laedt;
  String? get fehler => _fehler;

  Future<void> laden() async {
    _laedt = true;
    _fehler = null;
    notifyListeners();
    try {
      _bestellungen = await _api.meineBestellungen();
    } on ApiFehler catch (fehler) {
      _fehler = fehler.nachricht;
    } finally {
      _laedt = false;
      notifyListeners();
    }
  }

  /// Gibt die Bestellung auf. Wirft [ApiFehler], z.B. wenn ein Artikel vergriffen ist.
  Future<Bestellung> bestellen(
    List<WarenkorbItem> items, {
    required String zahlungsart,
    required double erwarteteSumme,
    String? anmerkung,
  }) async {
    final bestellung = await _api.bestellen(
      mengen: {for (final item in items) item.produkt.produktId: item.menge},
      zahlungsart: zahlungsart,
      erwarteteSumme: erwarteteSumme,
      anmerkung: anmerkung,
    );
    // Nur eine bereits geladene Liste ergänzen. Sonst sähe eine nie geladene
    // Historie so aus, als bestünde sie nur aus dieser einen Bestellung.
    final geladen = _bestellungen;
    if (geladen != null) {
      _bestellungen = [bestellung, ...geladen];
      notifyListeners();
    }
    return bestellung;
  }

  /// Eine einzelne Bestellung - aus dem Speicher oder frisch vom Server.
  Future<Bestellung> eine(String id) async {
    for (final bestellung in _bestellungen ?? const <Bestellung>[]) {
      if (bestellung.bestellungId == id) return bestellung;
    }
    return _api.bestellung(id);
  }

  Future<void> stornieren(String id) async {
    final storniert = await _api.stornieren(id);
    _bestellungen = [
      for (final b in _bestellungen ?? const <Bestellung>[])
        b.bestellungId == id ? storniert : b,
    ];
    notifyListeners();
  }

  /// Beim Abmelden: nichts vom vorherigen Benutzer behalten.
  void leeren() {
    _bestellungen = null;
    _fehler = null;
    notifyListeners();
  }
}
