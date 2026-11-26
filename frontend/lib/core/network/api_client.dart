/// HTTP-Client für das FastAPI-Backend: hängt den JWT an, vereinheitlicht Fehler.
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Fehler einer API-Anfrage mit einer Meldung, die dem Benutzer gezeigt werden kann.
class ApiFehler implements Exception {
  const ApiFehler(this.nachricht, {this.status});

  final String nachricht;

  /// HTTP-Statuscode; `null`, wenn der Server gar nicht erreicht wurde.
  final int? status;

  bool get keineVerbindung => status == null;

  @override
  String toString() => nachricht;
}

/// Speichert den JWT im Browser bzw. auf dem Gerät.
class TokenSpeicher {
  TokenSpeicher(this._prefs);

  static const _schluessel = 'auth_token';
  final SharedPreferences _prefs;

  String? get token => _prefs.getString(_schluessel);
  Future<void> speichern(String token) => _prefs.setString(_schluessel, token);
  Future<void> loeschen() => _prefs.remove(_schluessel);
}

class ApiClient {
  ApiClient(this._tokens) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBasis,
        // Großzügig, weil kostenlose Hosting-Tarife den Server nach Inaktivität
        // schlafen legen und der erste Aufruf ihn erst wieder startet.
        connectTimeout: const Duration(seconds: 75),
        receiveTimeout: const Duration(seconds: 75),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (optionen, handler) {
          final token = _tokens.token;
          if (token != null) {
            optionen.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(optionen);
        },
      ),
    );
  }

  final TokenSpeicher _tokens;
  late final Dio _dio;

  /// Wird aufgerufen, wenn der Server ein gesendetes Token ablehnt (abgelaufen/ungültig).
  void Function()? beiAbgelaufenerSitzung;

  Future<dynamic> get(String pfad, {Map<String, dynamic>? parameter}) =>
      _senden(() => _dio.get(pfad, queryParameters: parameter));

  Future<dynamic> post(String pfad, {Object? daten}) =>
      _senden(() => _dio.post(pfad, data: daten));

  Future<dynamic> put(String pfad, {Object? daten}) =>
      _senden(() => _dio.put(pfad, data: daten));

  Future<dynamic> patch(String pfad, {Object? daten}) =>
      _senden(() => _dio.patch(pfad, data: daten));

  Future<dynamic> delete(String pfad) => _senden(() => _dio.delete(pfad));

  /// Lädt eine Datei als multipart/form-data hoch.
  Future<dynamic> hochladen(
    String pfad, {
    required String feld,
    required Uint8List bytes,
    required String dateiname,
    required String mimeTyp,
  }) {
    final formular = FormData.fromMap({
      feld: MultipartFile.fromBytes(
        bytes,
        filename: dateiname,
        contentType: DioMediaType.parse(mimeTyp),
      ),
    });
    return _senden(() => _dio.post(pfad, data: formular));
  }

  Future<dynamic> _senden(Future<Response<dynamic>> Function() anfrage) async {
    try {
      return (await anfrage()).data;
    } on DioException catch (fehler) {
      throw _uebersetzen(fehler);
    }
  }

  ApiFehler _uebersetzen(DioException fehler) {
    final antwort = fehler.response;
    if (antwort == null) {
      final zeit =
          fehler.type == DioExceptionType.connectionTimeout ||
          fehler.type == DioExceptionType.receiveTimeout ||
          fehler.type == DioExceptionType.sendTimeout;
      return ApiFehler(
        zeit
            ? 'Der Server antwortet nicht. Bitte versuche es gleich noch einmal.'
            : 'Der Server ist gerade nicht erreichbar. Bitte prüfe deine Verbindung.',
      );
    }

    final status = antwort.statusCode ?? 0;
    final hatteToken = fehler.requestOptions.headers.containsKey('Authorization');
    if (status == 401 && hatteToken) beiAbgelaufenerSitzung?.call();

    return ApiFehler(_nachricht(antwort.data, status), status: status);
  }

  /// FastAPI liefert Fehler als `{"detail": "..."}` bzw. bei Validierungsfehlern
  /// als Liste von Objekten mit dem Feld `msg`.
  String _nachricht(dynamic daten, int status) {
    final detail = daten is Map ? daten['detail'] : null;
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      return 'Bitte prüfe deine Eingaben.';
    }
    return switch (status) {
      401 => 'Bitte melde dich an.',
      403 => 'Dafür fehlt dir die Berechtigung.',
      404 => 'Das wurde nicht gefunden.',
      >= 500 => 'Auf dem Server ist ein Fehler aufgetreten.',
      _ => 'Die Anfrage ist fehlgeschlagen ($status).',
    };
  }
}
