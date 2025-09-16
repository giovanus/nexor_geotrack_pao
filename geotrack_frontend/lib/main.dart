import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geotrack_frontend/app.dart';
import 'package:geotrack_frontend/services/auto_collect_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case AutoCollectService.collectTask:
        await AutoCollectService.collectGpsData();
        return true;
      case AutoCollectService.syncTask:
        await AutoCollectService.syncGpsData();
        return true;
      default:
        return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");

  // Initialiser Workmanager uniquement sur les plateformes mobiles
  if (!kIsWeb) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  runApp(const GeoTrackApp());
}
