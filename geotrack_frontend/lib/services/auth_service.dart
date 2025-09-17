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
  DateTime? _lastFailedAttempt;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<LoginResponse> login(String pin) async {
    try {
      final apiUrl = dotenv.get('API_BASE_URL', fallback: Constants.apiBaseUrl);

      print('Tentative de connexion avec PIN: $pin');
      print('URL: $apiUrl/auth/');

      // Test de connectivité d'abord
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          return LoginResponse(
            success: false,
            error: 'Aucune connexion internet',
          );
        }
      } catch (e) {
        print('Erreur vérification connectivité: $e');
      }

      final response = await http
          .post(
            Uri.parse('$apiUrl/auth/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'pin': pin}),
          )
          .timeout(const Duration(seconds: 30));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        _isAuthenticated = true;
        _failedAttempts = 0;

        await StorageService().saveToken(_token!);
        notifyListeners();
        return LoginResponse(success: true, token: _token);
      } else {
        _handleFailedAttempt(response.statusCode == 423);
        final errorData = json.decode(response.body);
        return LoginResponse(
          success: false,
          error:
              errorData['detail'] ??
              'Erreur de connexion (${response.statusCode})',
        );
      }
    } on SocketException catch (e) {
      print('Erreur socket: $e');
      return LoginResponse(
        success: false,
        error: 'Impossible de se connecter au serveur',
      );
    } on TimeoutException catch (e) {
      print('Timeout: $e');
      return LoginResponse(success: false, error: 'Timeout de connexion');
    } catch (e) {
      print('Erreur de connexion: $e');
      _handleFailedAttempt(false);
      return LoginResponse(
        success: false,
        error: 'Erreur de connexion: ${e.toString()}',
      );
    }
  }

  void _handleFailedAttempt(bool isLocked) {
    _failedAttempts++;
    _lastFailedAttempt = DateTime.now();

    // Si 3 tentatives échouées, bloquer pendant 30 secondes
    if (_failedAttempts >= 3 || isLocked) {
      _lastFailedAttempt = DateTime.now().add(const Duration(seconds: 30));
    }

    notifyListeners();
  }

  bool isBlocked() {
    if (_lastFailedAttempt == null) return false;
    return _failedAttempts >= 3 && DateTime.now().isBefore(_lastFailedAttempt!);
  }

  Duration getRemainingBlockTime() {
    if (!isBlocked()) return Duration.zero;
    return _lastFailedAttempt!.difference(DateTime.now());
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _failedAttempts = 0;
    _lastFailedAttempt = null;
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
}
