import 'package:flutter/material.dart';
import '../../models/kategorie.dart';
import '../../services/api_service.dart';

class KategorieService {
  final ApiService _apiService = ApiService();
  List<Kategorie> _kategorien = [];
  Map<String, String> _kategorieMap = {};

  List<Kategorie> get kategorien => _kategorien;
  Map<String, String> get kategorieMap => _kategorieMap;

  Future<void> loadKategorien() async {
    try {
      final response = await _apiService.get('/kategorien/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _kategorien = data
            .map((item) => Kategorie.fromJson(item as Map<String, dynamic>))
            .toList();

        // Map von ID zu Bezeichnung erstellen
        _kategorieMap = {
          for (var kategorie in _kategorien)
            kategorie.kategorieId: kategorie.bezeichnung,
        };
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Kategorien: $e');
    }
  }

  String getKategorieName(String? kategorieId) {
    if (kategorieId == null || kategorieId.isEmpty) return 'Unbekannt';
    return _kategorieMap[kategorieId] ?? 'Unbekannt';
  }
}
