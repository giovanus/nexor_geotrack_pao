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
    final pendingData = await getPendingGpsData();
    final syncedData = await getSyncedGpsData();

    // Combiner et trier par timestamp décroissant
    final allData = [...pendingData, ...syncedData];
    allData.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allData;
  }

  Future<void> saveSyncedGpsData(GpsData data) async {
    final prefs = await SharedPreferences.getInstance();
    final syncedData = await getSyncedGpsData();

    // Vérifier si la donnée existe déjà pour éviter les doublons
    final existingIndex = syncedData.indexWhere((d) => d.id == data.id);
    if (existingIndex != -1) {
      // Mettre à jour la donnée existante
      syncedData[existingIndex] = data.copyWith(synced: true);
    } else {
      // Ajouter la nouvelle donnée synchronisée
      syncedData.add(data.copyWith(synced: true));
    }

    final jsonList =
        syncedData
            .map(
              (e) => {
                ...e.toJson(),
                'synced': true, // S'assurer que synced est bien sauvegardé
                'id': e.id, // S'assurer que l'ID est sauvegardé
              },
            )
            .toList();

    await prefs.setString(_syncedDataKey, json.encode(jsonList));
  }

  // Ajouter cette méthode pour récupérer uniquement les données synchronisées
  Future<List<GpsData>> getSyncedGpsData() async {
    final prefs = await SharedPreferences.getInstance();
    final syncedJsonString = prefs.getString(_syncedDataKey);

    if (syncedJsonString == null) {
      return [];
    }

    try {
      final List<dynamic> syncedJsonList = json.decode(syncedJsonString);
      return syncedJsonList.map((json) => GpsData.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error decoding synced data: $e');
      return [];
    }
  }
}
