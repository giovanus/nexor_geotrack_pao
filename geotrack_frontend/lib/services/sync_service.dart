import 'package:geotrack_frontend/models/gps_data_model.dart';
import 'package:geotrack_frontend/services/api_service.dart';
import 'package:geotrack_frontend/services/storage_service.dart';

class SyncService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<void> syncPendingData() async {
    try {
      final pendingData = await _storageService.getPendingGpsData();
      final token = await _storageService.getToken();

      if (token == null) {
        print('❌ No auth token available for sync');
        return;
      }

      if (pendingData.isEmpty) {
        print('✅ No pending data to sync');
        return;
      }

      // Nouvelle liste pour les données synchronisées avec succès
      final List<GpsData> successfullySynced = [];

      for (final data in pendingData) {
        if (data.id == null) {
          print('❌ Failed to sync data: id is null, skipping this entry.');
          continue;
        }
        try {
          // Envoyer les données à l'API
          await _apiService.sendGpsData(data);

          // Marquer la donnée comme synchronisée et l'ajouter à la liste
          final syncedData = data.copyWith(synced: true);
          successfullySynced.add(syncedData);

          print('✅ Data synced successfully: ${data.id}');
        } catch (e) {
          print('❌ Failed to sync data ${data.id}: $e');
          // Ne pas ajouter à successfullySynced en cas d'erreur
        }
      }

      // Supprimer toutes les données synchronisées de la liste d'attente
      for (final syncedData in successfullySynced) {
        await _storageService.removePendingGpsData(syncedData.id!);
        // Sauvegarder dans les données synchronisées
        await _storageService.saveSyncedGpsData(syncedData);
      }

      print('✅ Sync completed: ${successfullySynced.length} data synced');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }

  Future<void> addDataToSyncQueue(GpsData data) async {
    await _storageService.savePendingGpsData(data);
  }

  Future<int> getPendingSyncCount() async {
    final pendingData = await _storageService.getPendingGpsData();
    return pendingData.length;
  }
}
