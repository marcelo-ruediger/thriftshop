/// CartProvider für Warenkorb-Management
/// Verwaltet Warenkorb-Items und berechnet Gesamtpreis
library;

import 'package:flutter/foundation.dart';

import '../models/warenkorb_item.dart';
import '../models/produkt.dart';

class CartProvider with ChangeNotifier {
  final List<WarenkorbItem> _items = [];

  List<WarenkorbItem> get items => [..._items];

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.produkt.preis * item.menge;
    }
    return total;
  }

  int get itemCount {
    int count = 0;
    for (var item in _items) {
      count += item.menge;
    }
    return count;
  }

  void addItem(Produkt produkt, {int quantity = 1}) {
    // Prüfen ob das Produkt bereits im Warenkorb ist
    final existingIndex = _items.indexWhere(
      (item) => item.produkt.produktId == produkt.produktId,
    );

    if (existingIndex != -1) {
      // Produkt existiert bereits - Menge erhöhen
      _items[existingIndex].menge += quantity;
    } else {
      // Neues Produkt zum Warenkorb hinzufügen
      _items.add(WarenkorbItem(produkt: produkt, menge: quantity));
    }
    notifyListeners();
  }

  void removeItem(String produktId) {
    _items.removeWhere((item) => item.produkt.produktId == produktId);
    notifyListeners();
  }

  void updateQuantity(String produktId, int quantity) {
    final item = _items.firstWhere(
      (item) => item.produkt.produktId == produktId,
    );
    item.menge = quantity;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
