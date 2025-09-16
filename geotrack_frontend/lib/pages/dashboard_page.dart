import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geotrack_frontend/models/gps_data_model.dart';
import 'package:provider/provider.dart';
import 'package:geotrack_frontend/services/auth_service.dart';
import 'package:geotrack_frontend/services/gps_service.dart';
import 'package:geotrack_frontend/services/sync_service.dart';
import 'package:geotrack_frontend/services/storage_service.dart';
import 'package:geotrack_frontend/widgets/connection_status.dart';
import 'package:geotrack_frontend/widgets/sync_indicator.dart';
import 'package:geotrack_frontend/pages/settings_page.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  final GpsService _gpsService = GpsService();
  final SyncService _syncService = SyncService();
  final StorageService _storageService = StorageService();

  Map<String, dynamic> _stats = {};
  Timer? _statsTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startStatsTimer();
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _loadStats();
  }

  Future<void> _loadStats() async {
    // Implémentez cette méthode selon vos besoins
    // Pour l'instant, retournons des valeurs par défaut
    setState(() {
      _stats = {
        'pending_count': 0,
        'last_collection': null,
        'next_collection': DateTime.now().add(const Duration(minutes: 5)),
        'next_sync': DateTime.now().add(const Duration(minutes: 10)),
      };
    });
  }

  void _startStatsTimer() {
    _statsTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nexor GeoTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status de connexion
              const ConnectionStatus(),
              const SizedBox(height: 16),

              // Cartes de statistiques
              _buildStatsCards(),
              const SizedBox(height: 24),

              // Titre section données
              const Text(
                'Données en attente de synchronisation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Liste des données en attente
              _buildPendingDataList(),
              const SizedBox(height: 16),

              // Boutons d'action
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        // Carte principale avec indicateurs
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      'Statistiques de Collecte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      '📦 En attente',
                      '${_stats['pending_count'] ?? 0}',
                      Colors.orange,
                    ),
                    _buildStatCard(
                      '⏰ Prochaine collecte',
                      _formatTime(_stats['next_collection']),
                      Colors.blue,
                    ),
                    _buildStatCard(
                      '🔄 Prochaine sync',
                      _formatTime(_stats['next_sync']),
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Carte dernière collecte
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dernière collecte',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        _stats['last_collection'] != null
                            ? DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(_stats['last_collection'])
                            : 'Jamais',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            title.split(' ')[0], // Emoji seulement
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          title.split(' ').skip(1).join(' '),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatTime(dynamic time) {
    if (time is! DateTime) return 'N/A';
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.inMinutes < 1) return 'Maintenant';
    if (difference.inMinutes < 60) return '${difference.inMinutes}min';

    return '${difference.inHours}h${difference.inMinutes.remainder(60)}min';
  }

  Widget _buildPendingDataList() {
    return FutureBuilder<List<GpsData>>(
      future: _storageService.getPendingGpsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingData = snapshot.data ?? [];

        if (pendingData.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 8),
                Text(
                  'Toutes les données sont synchronisées',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                ),
                title: const Text('Données en attente'),
                trailing: Chip(
                  label: Text('${pendingData.length}'),
                  backgroundColor: Colors.orange.withOpacity(0.2),
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: pendingData.length,
                  itemBuilder: (context, index) {
                    final data = pendingData[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on, size: 20),
                      title: Text(
                        '${data.lat.toStringAsFixed(6)}, ${data.lon.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM HH:mm').format(data.timestamp),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Icon(
                        data.synced ?? false
                            ? Icons.check_circle
                            : Icons.access_time,
                        color:
                            data.synced ?? false ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      dense: true,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.gps_fixed, size: 20),
            label: const Text('Collecte Manuelle'),
            onPressed: _manualCollect,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.sync, size: 20),
            label: const Text('Synchroniser'),
            onPressed: _manualSync,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _manualCollect() async {
    try {
      // Utiliser _gpsService pour la collecte manuelle
      final location = await _gpsService.getCurrentLocation();
      await _storageService.savePendingGpsData(location);
      await _loadStats();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('📍 Position collectée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _manualSync() async {
    try {
      await _syncService.syncPendingData();
      await _loadStats();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Synchronisation réussie'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur de synchronisation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
