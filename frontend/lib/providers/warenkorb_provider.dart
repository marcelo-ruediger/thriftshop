/// Der Warenkorb - lebt im Browser, bis die Bestellung abgeschickt wird.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/produkt.dart';
import '../models/warenkorb_item.dart';

class WarenkorbProvider extends ChangeNotifier {
  WarenkorbProvider(this._prefs) {
    _wiederherstellen();
  }

  static const _schluessel = 'warenkorb';
  final SharedPreferences _prefs;

  List<WarenkorbItem> _items = [];
  String? _hinweis;

  List<WarenkorbItem> get items => List.unmodifiable(_items);
  bool get istLeer => _items.isEmpty;

  /// Anzahl aller Artikel (Mengen summiert) - für das Badge am Warenkorb-Symbol.
  int get anzahl => _items.fold(0, (summe, item) => summe + item.menge);
  double get summe => _items.fold(0, (summe, item) => summe + item.summe);
  double get mwst => _items.fold(0, (summe, item) => summe + item.mwst);

  /// Meldung, wenn der Abgleich mit dem Katalog etwas verändert hat.
  String? get hinweis => _hinweis;

  int mengeVon(String produktId) {
    for (final item in _items) {
      if (item.produkt.produktId == produktId) return item.menge;
    }
    return 0;
  }

  /// Legt ein Produkt in den Warenkorb, höchstens bis zum Lagerbestand.
  /// Gibt zurück, wie viele Stück tatsächlich hinzugekommen sind.
  int hinzufuegen(Produkt produkt, {int menge = 1}) {
    final vorhanden = mengeVon(produkt.produktId);
    final neu = (vorhanden + menge).clamp(0, produkt.lagerbestand);
    if (neu == vorhanden) return 0;
    _setzen(produkt, neu);
    return neu - vorhanden;
  }

  void mengeAendern(String produktId, int menge) {
    final index = _items.indexWhere((i) => i.produkt.produktId == produktId);
    if (index == -1) return;
    final produkt = _items[index].produkt;
    _setzen(produkt, menge.clamp(0, produkt.lagerbestand));
  }

  void entfernen(String produktId) {
    _items = _items.where((i) => i.produkt.produktId != produktId).toList();
    _geaendert();
  }

  void leeren() {
    _items = [];
    _hinweis = null;
    _geaendert();
  }

  void hinweisSchliessen() {
    _hinweis = null;
    notifyListeners();
  }

  /// Gleicht den Warenkorb mit dem frisch geladenen Katalog ab: übernimmt aktuelle
  /// Preise und Bestände und entfernt, was nicht mehr erhältlich ist.
  void abgleichen(List<Produkt> katalog) {
    if (_items.isEmpty || katalog.isEmpty) return;
    final aktuell = {for (final p in katalog) p.produktId: p};
    final neu = <WarenkorbItem>[];
    var entfernt = false;
    var reduziert = false;

    for (final item in _items) {
      final produkt = aktuell[item.produkt.produktId];
      if (produkt == null || produkt.ausverkauft) {
        entfernt = true;
        continue;
      }
      if (item.menge > produkt.lagerbestand) reduziert = true;
      neu.add(
        WarenkorbItem(
          produkt: produkt,
          menge: item.menge.clamp(1, produkt.lagerbestand),
        ),
      );
    }

    _items = neu;
    if (entfernt) {
      _hinweis = 'Mindestens ein Artikel ist inzwischen vergriffen und wurde entfernt.';
    } else if (reduziert) {
      _hinweis = 'Die Menge wurde an den verfügbaren Bestand angepasst.';
    }
    _geaendert();
  }

  void _setzen(Produkt produkt, int menge) {
    final rest = _items.where((i) => i.produkt.produktId != produkt.produktId);
    final index = _items.indexWhere((i) => i.produkt.produktId == produkt.produktId);
    if (menge <= 0) {
      _items = rest.toList();
    } else if (index == -1) {
      _items = [..._items, WarenkorbItem(produkt: produkt, menge: menge)];
    } else {
      _items = [
        for (final item in _items)
          item.produkt.produktId == produkt.produktId ? item.kopie(menge: menge) : item,
      ];
    }
    _geaendert();
  }

  void _geaendert() {
    _prefs.setString(_schluessel, jsonEncode([for (final i in _items) i.toJson()]));
    notifyListeners();
  }

  void _wiederherstellen() {
    final gespeichert = _prefs.getString(_schluessel);
    if (gespeichert == null) return;
    try {
      _items = (jsonDecode(gespeichert) as List)
          .map((e) => WarenkorbItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Unlesbarer Stand (z.B. aus einer älteren Version) - mit leerem Warenkorb starten
      _prefs.remove(_schluessel);
    }
  }
}
