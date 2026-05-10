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
      final response = await _apiService.get('/bestellungen/meine-bestellungen');
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

  /// Platziert eine neue Bestellung und gibt die erstellte Bestellung zurück
  /// 
  /// Gibt das erstellte [Bestellung]-Objekt mit der backend-generierten ID und Bestellnummer zurück.
  Future<Bestellung> placeOrder(List<WarenkorbItem> items, double totalPrice) async {
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
        // Neue Bestellung aus der Response erstellen
        final responseData = response.data as Map<String, dynamic>;
        final newBestellung = Bestellung(
          bestellungId: responseData['bestellung_id'] as String,
          laufendeNr: (responseData['laufende_nr'] as num).toInt(),
          status: responseData['status'] as String,
          bestelldatum: DateTime.now(), // Wird vom Backend gesetzt, wir ermitteln es nicht
          benutzerId: '', // Wird später beim Laden aktualisiert
        );

        // Bestellung zur Liste hinzufügen
        _bestellungen.insert(0, newBestellung);
        
        // Neuen Kunden-Bereich synchronisieren
        notifyListeners();

        return newBestellung;
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

  Future<List<Bestellung>> loadAllBestellungen({int limit = 50, int offset = 0}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/bestellungen/',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _allBestellungen = data.cast<Map<String, dynamic>>();
        return _allBestellungen
            .map((item) => Bestellung.fromJson(item))
            .toList();
      } else {
        throw Exception('Konnte alle Bestellungen nicht laden');
      }
    } on Exception catch (e) {
      throw Exception('Fehler beim Laden: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String bestellungId, String neuerStatus) async {
    try {
      final response = await _apiService.patch(
        '/bestellungen/$bestellungId/status',
        data: neuerStatus,
      );
      if (response.statusCode == 200) {
        await loadAllBestellungen();
      }
    } on Exception catch (e) {
      throw Exception('Fehler beim Aktualisieren des Status: $e');
    }
  }

  Future<List<Bestellposition>> loadBestellpositionen(String bestellungId) async {
    try {
      final response = await _apiService.get('/bestellposition/bestellung/$bestellungId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _selectedBestellungPositionen = data
            .map((item) => Bestellposition.fromJson(item as Map<String, dynamic>))
            .toList();
        return _selectedBestellungPositionen!;
      } else {
        throw Exception('Konnte Bestellpositionen nicht laden');
      }
    } on Exception catch (e) {
      throw Exception('Fehler beim Laden: $e');
    }
  }
}
