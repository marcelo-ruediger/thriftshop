/// ProfileProvider für Profil-Management
/// Verwaltet Benutzerprofile und Einstellungen

import 'package:flutter/foundation.dart';

import '../models/benutzer.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  Benutzer? _benutzer;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditing = false;

  Benutzer? get benutzer => _benutzer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEditing => _isEditing;

  final ApiService _apiService = ApiService();

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/benutzer/profil');
      if (response.statusCode == 200) {
        _benutzer = Benutzer.fromJson(response.data as Map<String, dynamic>);
      } else {
        _errorMessage = 'Konnte Profil nicht laden';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Laden: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startEditing() {
    _isEditing = true;
    notifyListeners();
  }

  void stopEditing() {
    _isEditing = false;
    notifyListeners();
  }

  Future<void> updateProfile(Benutzer benutzer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.put(
        '/benutzer/${benutzer.benutzerId}',
        data: {
          'email': benutzer.email,
          'vorname': benutzer.vorname,
          'nachname': benutzer.nachname,
          'telefonnummer': benutzer.telefonnummer,
        },
      );

      if (response.statusCode == 200) {
        _benutzer = Benutzer.fromJson(response.data as Map<String, dynamic>);
        _isEditing = false;
      } else {
        _errorMessage = 'Update fehlgeschlagen';
      }
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
      final response = await _apiService.delete(
        '/benutzer/${_benutzer?.benutzerId}',
      );
      if (response.statusCode == 200) {
        _benutzer = null;
      } else {
        _errorMessage = 'Löschen fehlgeschlagen';
      }
    } on Exception catch (e) {
      _errorMessage = 'Fehler beim Löschen: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}
