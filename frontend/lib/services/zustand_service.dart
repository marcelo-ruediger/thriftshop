import 'package:flutter/material.dart';
import '../../models/zustand.dart';
import '../../services/api_service.dart';

class ZustandService {
  final ApiService _apiService = ApiService();
  List<Zustand> _zustaende = [];
  Map<String, String> _zustandMap = {};
  Map<String, Color> _zustandColors = {};

  List<Zustand> get zustaende => _zustaende;
  Map<String, String> get zustandMap => _zustandMap;
  Map<String, Color> get zustandColors => _zustandColors;

  Future<void> loadZustaende() async {
    try {
      final response = await _apiService.get('/zustaende/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _zustaende = data
            .map((item) => Zustand.fromJson(item as Map<String, dynamic>))
            .toList();

        // Map von ID zu Bezeichnung erstellen
        _zustandMap = {
          for (var zustand in _zustaende)
            zustand.zustandId: zustand.bezeichnung,
        };

        // Farben für Zustände definieren
        _zustandColors = {
          for (var zustand in _zustaende)
            zustand.zustandId: _getColorForZustand(zustand.bezeichnung),
        };
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Zustände: $e');
    }
  }

  String getZustandName(String? zustandId) {
    if (zustandId == null || zustandId.isEmpty) return 'Unbekannt';
    return _zustandMap[zustandId] ?? 'Unbekannt';
  }

  Color getZustandColor(String? zustandId) {
    if (zustandId == null || zustandId.isEmpty) return Colors.grey;
    return _zustandColors[zustandId] ?? Colors.grey;
  }

  Color _getColorForZustand(String bezeichnung) {
    final lower = bezeichnung.toLowerCase();
    if (lower.contains('neu') || lower.contains('brandneu')) {
      return Colors.green;
    } else if (lower.contains('gebraucht') || lower.contains('gut')) {
      return Colors.blue;
    } else if (lower.contains('angerissen') || lower.contains('stark')) {
      return Colors.orange;
    } else if (lower.contains('pitch') || lower.contains('perfekt')) {
      return Colors.purple;
    } else {
      return Colors.teal;
    }
  }
}
