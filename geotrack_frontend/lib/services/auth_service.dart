// auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geotrack_frontend/models/auth_model.dart';
import 'package:geotrack_frontend/utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  int _failedAttempts = 0;
  DateTime? _blockUntil;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  int get failedAttempts => _failedAttempts;
  DateTime? get blockUntil => _blockUntil;

  Future<LoginResponse> login(String pin) async {
    if (isBlocked()) {
      return LoginResponse(
        success: false,
        error:
            'Compte bloqué. Réessayez dans ${getRemainingBlockTime().inSeconds} secondes',
      );
    }

    try {
      final apiUrl = dotenv.get('API_BASE_URL', fallback: Constants.apiBaseUrl);

      // Test de connectivité
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return LoginResponse(
          success: false,
          error: 'Aucune connexion internet',
        );
      }

      final response = await http
          .post(
            Uri.parse('$apiUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'pin': pin}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        _isAuthenticated = true;
        _failedAttempts = 0;
        _blockUntil = null;

        await StorageService().saveToken(_token!);
        notifyListeners();
        return LoginResponse(success: true, token: _token);
      } else if (response.statusCode == 401) {
        _handleFailedAttempt();
        return LoginResponse(
          success: false,
          error: 'PIN incorrect. Tentatives restantes: ${3 - _failedAttempts}',
        );
      } else {
        final errorData = json.decode(response.body);
        return LoginResponse(
          success: false,
          error: errorData['detail'] ?? 'Erreur de connexion',
        );
      }
    } on SocketException {
      return LoginResponse(
        success: false,
        error: 'Impossible de se connecter au serveur',
      );
    } on TimeoutException {
      return LoginResponse(success: false, error: 'Timeout de connexion');
    } catch (e) {
      return LoginResponse(success: false, error: 'Erreur de connexion');
    }
  }

  void _handleFailedAttempt() {
    _failedAttempts++;

    if (_failedAttempts >= 3) {
      _blockUntil = DateTime.now().add(const Duration(seconds: 30));
    }

    notifyListeners();
  }

  bool isBlocked() {
    if (_blockUntil == null) return false;
    return DateTime.now().isBefore(_blockUntil!);
  }

  Duration getRemainingBlockTime() {
    if (_blockUntil == null) return Duration.zero;
    return _blockUntil!.difference(DateTime.now());
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _failedAttempts = 0;
    _blockUntil = null;
    _userEmail = null;
    await StorageService().deleteToken();
    notifyListeners();
  }

  Future<bool> checkAuth() async {
    final token = await StorageService().getToken();
    if (token != null) {
      _token = token;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> changePin(
    String email,
    String oldPin,
    String newPin,
  ) async {
    try {
      final apiUrl = dotenv.get('API_BASE_URL', fallback: Constants.apiBaseUrl);

      // Utiliser le token de l'instance au lieu du storage
      if (_token == null) {
        return {
          'success': false,
          'message': 'Non authentifié. Veuillez vous reconnecter',
        };
      }

      final response = await http.post(
        Uri.parse('$apiUrl/auth/change-pin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Utiliser _token directement
        },
        body: json.encode({
          'email': email,
          'old_pin': oldPin,
          'new_pin': newPin,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'PIN modifié avec succès'};
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide
        await logout();
        return {
          'success': false,
          'message': 'Session expirée. Veuillez vous reconnecter',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Erreur lors du changement de PIN',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  String? getEmailFromToken() {
    if (_token == null) return null;
    try {
      final parts = _token!.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      // Padding pour base64Url
      final padded = payload.padRight((payload.length + 3) & ~3, '=');
      final normalized = base64Url.normalize(padded);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      return payloadMap['sub']; // L'email est dans le claim "sub"
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  // Nouvelle méthode pour récupérer le PIN oublié
  Future<Map<String, dynamic>> forgotPin(String email) async {
    try {
      final apiUrl = dotenv.get('API_BASE_URL', fallback: Constants.apiBaseUrl);

      final response = await http.post(
        Uri.parse('$apiUrl/auth/forgot-pin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Nouveau PIN envoyé par email'};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Erreur lors de la récupération',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  void setUserEmail(String email) {
    _userEmail = email;
  }

  String? get userEmail => _userEmail;
}

Future<Map<String, dynamic>> register(String email, String pin) async {
  try {
    final apiUrl = dotenv.get('API_BASE_URL', fallback: Constants.apiBaseUrl);

    final response = await http.post(
      Uri.parse('$apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'pin': pin}),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Compte créé avec succès'};
    } else {
      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['detail'] ?? 'Erreur lors de l\'inscription',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Erreur de connexion'};
  }
}
