import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geotrack_frontend/models/gps_data_model.dart';
import 'dart:convert';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _tokenKey = 'auth_token';
  final String _pendingDataKey = 'pending_gps_data';
  final String _syncedDataKey = 'synced_gps_data';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<void> savePendingGpsData(GpsData data) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = await getPendingGpsData();

    pendingData.add(data);

    final jsonList = pendingData.map((e) => e.toJson()).toList();
    await prefs.setString(_pendingDataKey, json.encode(jsonList));
  }

  Future<List<GpsData>> getPendingGpsData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pendingDataKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => GpsData.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> removePendingGpsData(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = await getPendingGpsData();

    final updatedData = pendingData.where((data) => data.id != id).toList();

    final jsonList = updatedData.map((e) => e.toJson()).toList();
    await prefs.setString(_pendingDataKey, json.encode(jsonList));
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingDataKey);
    await deleteToken();
  }

  /// Retourne toutes les données GPS (en attente et synchronisées)
  Future<List<GpsData>> getAllGpsData() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJsonString = prefs.getString(_pendingDataKey);
    final syncedJsonString = prefs.getString(_syncedDataKey);

    List<GpsData> allData = [];

    // Ajoute les données en attente
    if (pendingJsonString != null) {
      try {
        final List<dynamic> pendingJsonList = json.decode(pendingJsonString);
        allData.addAll(
          pendingJsonList.map((json) => GpsData.fromJson(json)).toList(),
        );
      } catch (e) {}
    }

    // Ajoute les données synchronisées
    if (syncedJsonString != null) {
      try {
        final List<dynamic> syncedJsonList = json.decode(syncedJsonString);
        allData.addAll(
          syncedJsonList.map((json) => GpsData.fromJson(json)).toList(),
        );
      } catch (e) {}
    }

    return allData;
  }

  Future<void> saveSyncedGpsData(GpsData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_syncedDataKey);

    List<GpsData> syncedData = [];
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      syncedData = jsonList.map((json) => GpsData.fromJson(json)).toList();
    }
    // Marquer comme synchronisé
    final synced = data.copyWith(synced: true);
    syncedData.add(synced);

    final jsonList = syncedData.map((e) => e.toJson()).toList();
    await prefs.setString(_syncedDataKey, json.encode(jsonList));
  }
}
