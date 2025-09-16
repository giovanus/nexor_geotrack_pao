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

      for (final data in pendingData) {
        try {
          await _apiService.sendGpsData(data);
          await _storageService.removePendingGpsData(data.id!);
          print('✅ Data synced successfully: ${data.id}');
        } catch (e) {
          print('❌ Failed to sync data ${data.id}: $e');
        }
      }
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
