import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geotrack_frontend/services/gps_service.dart';
import 'package:geotrack_frontend/services/sync_service.dart';
import 'package:geotrack_frontend/services/storage_service.dart';
import 'package:geotrack_frontend/models/gps_data_model.dart';

class AutoCollectService {
  final GpsService _gpsService = GpsService();
  final SyncService _syncService = SyncService();
  final StorageService _storageService = StorageService();

  static const String collectTask = "gpsCollectTask";
  static const String syncTask = "gpsSyncTask";

  // Ajoutez ces méthodes statiques
  static Future<void> collectGpsDataBackground() async {
    final service = AutoCollectService();
    try {
      final location = await service._gpsService.getCurrentLocation();
      await service._storageService.savePendingGpsData(location);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_collection',
        DateTime.now().toIso8601String(),
      );

      print('📍 Donnée GPS collectée: ${location.lat}, ${location.lon}');
    } catch (e) {
      print('❌ Erreur collecte GPS: $e');
    }
  }

  static Future<void> syncGpsDataBackground() async {
    final service = AutoCollectService();
    try {
      final pendingCount = await service._syncService.getPendingSyncCount();
      if (pendingCount > 0) {
        await service._syncService.syncPendingData();
        print('✅ Synchronisation réussie: $pendingCount données');
      }
    } catch (e) {
      print('❌ Erreur synchronisation: $e');
    }
  }

  Future<void> initializeBackgroundServices() async {
    // Enregistrement des tâches périodiques
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    startPeriodicTasks();
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case collectTask:
          await collectGpsDataBackground(); // Utiliser la nouvelle méthode
          return true;
        case syncTask:
          await syncGpsDataBackground(); // Utiliser la nouvelle méthode
          return true;
        default:
          return false;
      }
    });
  }

  void startPeriodicTasks({int collectInterval = 5, int syncInterval = 10}) {
    // Arrêter les tâches existantes
    Workmanager().cancelAll();

    // Démarrer la collecte périodique
    Workmanager().registerPeriodicTask(
      collectTask,
      collectTask,
      frequency: Duration(minutes: collectInterval),
      constraints: Constraints(networkType: NetworkType.not_required),
    );

    // Démarrer la synchronisation périodique
    Workmanager().registerPeriodicTask(
      syncTask,
      syncTask,
      frequency: Duration(minutes: syncInterval),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> collectGpsData() async {
    final service = AutoCollectService();
    try {
      final location = await service._gpsService.getCurrentLocation();
      await service._storageService.savePendingGpsData(location);

      // Enregistrer le timestamp de la dernière collecte
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_collection',
        DateTime.now().toIso8601String(),
      );

      print('📍 Donnée GPS collectée: ${location.lat}, ${location.lon}');
    } catch (e) {
      print('❌ Erreur collecte GPS: $e');
    }
  }

  static Future<void> syncGpsData() async {
    final service = AutoCollectService();
    try {
      final pendingCount = await service._syncService.getPendingSyncCount();
      if (pendingCount > 0) {
        await service._syncService.syncPendingData();
        print('✅ Synchronisation réussie: $pendingCount données');
      }
    } catch (e) {
      print('❌ Erreur synchronisation: $e');
    }
  }

  Future<Map<String, dynamic>> getCollectionStats() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = await _storageService.getPendingGpsData();
    final lastCollection = prefs.getString('last_collection');

    return {
      'pending_count': pendingData.length,
      'last_collection':
          lastCollection != null ? DateTime.parse(lastCollection) : null,
      'next_collection': DateTime.now().add(const Duration(minutes: 5)),
      'next_sync': DateTime.now().add(const Duration(minutes: 10)),
    };
  }
}
