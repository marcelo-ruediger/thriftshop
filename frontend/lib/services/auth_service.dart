/// Auth-Service für die Thriftshop-App
library;
import 'package:dio/dio.dart';

import '../models/benutzer.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  final ApiService _apiService = ApiService();

  // Benutzer-Session
  Benutzer? _benutzer;
  bool _isAuthenticated = false;

  Benutzer? get benutzer => _benutzer;
  bool get isAuthenticated => _isAuthenticated;


  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['access_token'] as String;

        await _apiService.saveToken(token);
        _isAuthenticated = true;

        // Benutzer-Daten laden
        await _loadBenutzer();
      } else {
        throw Exception('Login fehlgeschlagen');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('E-Mail oder Passwort ist falsch');
      }
      throw _apiService.handleError(e);
    }
  }

  Future<void> register({
    required String vorname,
    required String nachname,
    required String email,
    required String telefonnummer,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {
          'vorname': vorname,
          'nachname': nachname,
          'email': email,
          'telefonnummer': telefonnummer,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        // Nach der Registrierung automatisch einloggen
        await login(email: email, password: password);
      } else {
        throw Exception('Registrierung fehlgeschlagen');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('E-Mail ist bereits registriert');
      }
      throw _apiService.handleError(e);
    }
  }

  Future<void> _loadBenutzer() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response.statusCode == 200) {
        _benutzer = Benutzer.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      // Fehler beim Laden der Benutzer-Daten - aber Login war erfolgreich
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.get('/auth/logout');
    } catch (e) {
      // Logout kann auch ohne Token funktionieren
    } finally {
      await _apiService.clearToken();
      _isAuthenticated = false;
      _benutzer = null;
    }
  }

  Future<bool> checkAuth() async {
    final token = _apiService.getToken();
    if (token == null) {
      _isAuthenticated = false;
      return false;
    }

    try {
      await _loadBenutzer();
      return _isAuthenticated;
    } catch (e) {
      _isAuthenticated = false;
      return false;
    }
  }

  // Fehlende Methoden für AuthProvider-Integration
  Future<void> updateProfile(Benutzer benutzer) async {
    try {
      final response = await _apiService.put(
        '/auth/profile',
        data: benutzer.toJson(),
      );
      if (response.statusCode == 200) {
        _benutzer = Benutzer.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Update fehlgeschlagen');
      }
    } on DioException catch (e) {
      throw _apiService.handleError(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await _apiService.delete('/auth/profile');
      if (response.statusCode == 200) {
        await clearSession();
      } else {
        throw Exception('Löschen fehlgeschlagen');
      }
    } on DioException catch (e) {
      throw _apiService.handleError(e);
    }
  }

  Future<Response> getCurrentUser() async {
    try {
      return await _apiService.get('/auth/me');
    } on DioException catch (e) {
      throw _apiService.handleError(e);
    }
  }

  Future<void> clearSession() async {
    await _apiService.clearToken();
    _isAuthenticated = false;
    _benutzer = null;
  }
}
