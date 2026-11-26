/// Laufzeit-Konfiguration: wo das Backend erreichbar ist.
library;

import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Optional beim Bauen gesetzt: `--dart-define=API_URL=https://mein-backend.example`
  static const String _apiUrl = String.fromEnvironment('API_URL');

  /// Adresse des Backends ohne abschließenden Schrägstrich.
  ///
  /// - Mit `API_URL` gebaut: genau diese Adresse.
  /// - Web-Release: dieselbe Adresse wie die Seite selbst (das Backend liefert
  ///   das Frontend mit aus).
  /// - Entwicklung: das lokal gestartete Backend.
  static final String server = () {
    if (_apiUrl.isNotEmpty) return _apiUrl.replaceFirst(RegExp(r'/+$'), '');
    if (kIsWeb && kReleaseMode) return Uri.base.origin;
    return 'http://localhost:8001';
  }();

  static String get apiBasis => '$server/api';

  /// Vollständige Adresse eines Produktbilds aus dem Feld `bildpfad`.
  static String bildUrl(String dateiname) => '$server/bilder/$dateiname';
}
