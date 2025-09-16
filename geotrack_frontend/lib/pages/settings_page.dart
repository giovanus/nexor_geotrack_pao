import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geotrack_frontend/services/auth_service.dart'; // Changé ici
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _collectIntervalController =
      TextEditingController();
  final TextEditingController _syncIntervalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _collectIntervalController.text =
          (prefs.getInt('collect_interval') ?? 5).toString();
      _syncIntervalController.text =
          (prefs.getInt('sync_interval') ?? 10).toString();
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final collectInterval = int.parse(_collectIntervalController.text);
      final syncInterval = int.parse(_syncIntervalController.text);

      await prefs.setInt('collect_interval', collectInterval);
      await prefs.setInt('sync_interval', syncInterval);

      // Vous devrez peut-être adapter cette partie selon votre implémentation
      // des tâches périodiques
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres sauvegardés avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(
      // Changé ici
      context,
      listen: false,
    );
    await authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Section Intervalles
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer, color: Colors.deepPurple),
                          SizedBox(width: 12),
                          Text(
                            'Intervalles de Synchronisation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _collectIntervalController,
                        decoration: const InputDecoration(
                          labelText: 'Intervalle de collecte (minutes)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.gps_fixed),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un intervalle';
                          }
                          final val = int.tryParse(value);
                          if (val == null || val < 1) {
                            return 'Intervalle invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _syncIntervalController,
                        decoration: const InputDecoration(
                          labelText: 'Intervalle de synchronisation (minutes)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sync),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un intervalle';
                          }
                          final val = int.tryParse(value);
                          if (val == null || val < 1) {
                            return 'Intervalle invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Sauvegarder les paramètres'),
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section Compte
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_circle, color: Colors.deepPurple),
                          SizedBox(width: 12),
                          Text(
                            'Compte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.info, color: Colors.grey),
                        title: const Text('Version de l\'application'),
                        subtitle: const Text('1.0.0'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.privacy_tip,
                          color: Colors.grey,
                        ),
                        title: const Text('Politique de confidentialité'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.help, color: Colors.grey),
                        title: const Text('Aide et support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton de déconnexion
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _collectIntervalController.dispose();
    _syncIntervalController.dispose();
    super.dispose();
  }
}
