/// AuthProvider für Authentifizierungs-Management
/// Verwaltet Benutzer-Session und Login-Status

import 'package:flutter/foundation.dart';

import '../models/benutzer.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  Benutzer? _benutzer;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  Benutzer? get benutzer => _benutzer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  final AuthService _authService = AuthService();

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      if (_authService.isAuthenticated) {
        _benutzer = _authService.benutzer;
        _isAuthenticated = true;
      } else {
        _errorMessage = 'Login fehlgeschlagen';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Login: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // name wird in vorname/nachname aufgeteilt
      final parts = name.split(' ');
      final vorname = parts.isNotEmpty ? parts[0] : '';
      final nachname = parts.length > 1
          ? name.substring(name.indexOf(' ') + 1)
          : '';

      await _authService.register(
        vorname: vorname,
        nachname: nachname,
        email: email,
        telefonnummer: '',
        password: password,
      );

      if (_authService.isAuthenticated) {
        _benutzer = _authService.benutzer;
        _isAuthenticated = true;
      } else {
        _errorMessage = 'Registration fehlgeschlagen';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler bei Registration: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _benutzer = null;
      _isAuthenticated = false;
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Benutzer benutzer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateProfile(benutzer);
      _benutzer = _authService.benutzer;
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Update: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      _benutzer = null;
      _isAuthenticated = false;
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Löschen: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (!_isAuthenticated || _benutzer == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.getCurrentUser();
      _benutzer = _authService.benutzer;
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
