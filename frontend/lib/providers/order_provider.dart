/// OrderProvider für Bestell-Management
/// Verwaltet Bestellhistorie und Bestellstatus
library;

import 'package:flutter/foundation.dart';

import '../models/bestellung.dart';
import '../models/bestellposition.dart';
import '../models/warenkorb_item.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<Bestellung> _bestellungen = [];
  List<Map<String, dynamic>> _allBestellungen = [];
  List<Bestellposition>? _selectedBestellungPositionen;
  bool _isLoading = false;
  String? _errorMessage;

  List<Bestellung> get bestellungen => [..._bestellungen];
  List<Map<String, dynamic>> get allBestellungen => [..._allBestellungen];
  List<Bestellposition>? get selectedBestellungPositionen =>
      _selectedBestellungPositionen;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> loadBestellungen() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/bestellungen');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _bestellungen = data
            .map((item) => Bestellung.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = 'Konnte Bestellungen nicht laden';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Laden: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String bestellungId) async {
    try {
      // Stornierungsimplementierung - falls API vorsieht
      // Verwende delete statt patch, falls API-Endpunkt stornieren unterstützt
      final response = await _apiService.delete(
        '/bestellungen/$bestellungId/stornieren',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Bestellung aktualisieren
        await loadBestellungen();
      }
    } on Exception catch (e) {
      throw Exception('Fehler beim Stornieren: $e');
    }
  }

  Future<void> placeOrder(List<WarenkorbItem> items, double totalPrice) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Bestellungs-Daten erstellen
      final List<Map<String, dynamic>> bestellpositionen = items.map((item) {
        return {
          'produkt_id': item.produkt.produktId,
          'menge': item.menge,
          'preis': item.produkt.preis,
        };
      }).toList();

      final response = await _apiService.post(
        '/bestellungen',
        data: {
          'bestellpositionen': bestellpositionen,
          'gesamtpreis': totalPrice,
        },
      );

      if (response.statusCode == 201) {
        // Bestellung erfolgreich
        await loadBestellungen();
      } else {
        throw Exception('Bestellung fehlgeschlagen');
      }
    } on Exception catch (e) {
      throw Exception('Fehler beim Platzieren: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadBestellungen();
  }

  /// Admin: Alle Bestellungen laden
  Future<void> loadAllBestellungen({int limit = 100, int offset = 0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/bestellungen/?limit=$limit&offset=$offset',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _allBestellungen = data
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        _errorMessage = 'Konnte Bestellungen nicht laden';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Laden: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin: Bestellstatus aktualisieren
  Future<bool> updateStatus(String bestellungId, String neuerStatus) async {
    try {
      final response = await _apiService.patch(
        '/bestellungen/$bestellungId/status',
        data: {'neuer_status': neuerStatus},
      );
      if (response.statusCode == 200) {
        await loadAllBestellungen();
        return true;
      }
      return false;
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren: $e';
      notifyListeners();
      return false;
    }
  }

  /// Admin: Bestellpositionen für eine Bestellung laden
  Future<void> loadBestellpositionen(String bestellungId) async {
    try {
      final response = await _apiService.get('/bestellungen/$bestellungId');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['bestellpositionen'] != null) {
          _selectedBestellungPositionen = (data['bestellpositionen'] as List)
              .map(
                (pos) => Bestellposition.fromJson(pos as Map<String, dynamic>),
              )
              .toList();
        }
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Laden der Positionen: $e';
      notifyListeners();
    }
  }

  /// Admin: Bestellungen nach Status filtern
  List<Map<String, dynamic>> filterByStatus(String status) {
    if (status.isEmpty || status == 'Alle') {
      return _allBestellungen;
    }
    return _allBestellungen.where((b) => b['status'] == status).toList();
  }
}
