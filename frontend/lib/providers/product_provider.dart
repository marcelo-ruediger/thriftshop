/// ProductProvider für Produkt-Management
/// Verwaltet Produktliste, Filter und Suchbegriff
library;

import 'package:flutter/foundation.dart';

import '../models/produkt.dart';
import '../models/kategorie.dart';
import '../services/api_service.dart';
import '../services/kategorie_service.dart';

class ProductProvider with ChangeNotifier {
  List<Produkt> _produkte = [];
  List<Produkt> _filteredProdukte = [];
  List<String> _categories = ['Alle'];
  List<Kategorie> _kategorien = [];
  String _selectedCategory = 'Alle';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Produkt> get produkte => _filteredProdukte;
  List<Produkt> get allProdukte => [..._produkte];
  List<String> get categories => _categories;
  List<Kategorie> get kategorien => _kategorien;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();
  final KategorieService _kategorieService = KategorieService();

  Future<void> loadProdukte() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Kategorien und Produkte parallel laden
      await Future.wait([
        _kategorieService.loadKategorien(),
        _loadProdukteData(),
      ]);

      // Kategorien aus dem Service aktualisieren
      _kategorien = _kategorieService.kategorien;
      _categories = ['Alle', ..._kategorien.map((k) => k.bezeichnung)];
    } catch (e) {
      _errorMessage = 'Fehler beim Laden: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProdukteData() async {
    try {
      final response = await _apiService.get('/produkte');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _produkte = data
            .map((item) => Produkt.fromJson(item as Map<String, dynamic>))
            .toList();
        _filterProdukte();
      } else {
        _errorMessage = 'Konnte Produkte nicht laden';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Laden: $e';
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _filterProdukte();
  }

  void filterBySearch(String query) {
    _searchQuery = query;
    _filterProdukte();
  }

  void _filterProdukte() {
    _filteredProdukte = _produkte.where((produkt) {
      // Filter nach Kategorie
      if (_selectedCategory != 'Alle') {
        // Kategorie-ID basierend auf Name finden
        final kategorie = _kategorien.firstWhere(
          (k) => k.bezeichnung == _selectedCategory,
          orElse: () => Kategorie(
            kategorieId: '',
            bezeichnung: '',
            slug: '',
            kategorieRabatt: 0,
            steuersatz: 0,
          ),
        );
        if (produkt.kategorieId != kategorie.kategorieId) {
          return false;
        }
      }
      // Filter nach Suchbegriff
      if (_searchQuery.isNotEmpty &&
          !produkt.bezeichnung.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          )) {
        return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadProdukte();
  }

  /// Erstellt ein neues Produkt
  Future<void> createProdukt(Produkt produkt) async {
    try {
      final response = await _apiService.post(
        '/produkte',
        data: produkt.toJson(),
      );
      if (response.statusCode == 201) {
        await loadProdukte();
      } else {
        _errorMessage = 'Konnte Produkt nicht erstellen';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Erstellen: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Aktualisiert ein bestehendes Produkt
  Future<void> updateProdukt(Produkt produkt) async {
    try {
      final response = await _apiService.put(
        '/produkte/${produkt.produktId}',
        data: produkt.toJson(),
      );
      if (response.statusCode == 200) {
        await loadProdukte();
      } else {
        _errorMessage = 'Konnte Produkt nicht aktualisieren';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Löscht ein Produkt
  Future<void> deleteProdukt(String produktId) async {
    try {
      final response = await _apiService.delete('/produkte/$produktId');
      if (response.statusCode == 204) {
        await loadProdukte();
      } else {
        _errorMessage = 'Konnte Produkt nicht löschen';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Löschen: $e';
    } finally {
      notifyListeners();
    }
  }
}
