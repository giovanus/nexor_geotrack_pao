import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geotrack_frontend/app.dart';
import 'package:geotrack_frontend/services/auto_collect_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");

  // Initialiser le service background uniquement sur les plateformes mobiles
  if (!kIsWeb) {
    await initializeBackgroundService();
  }

  runApp(const GeoTrackApp());
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // Configuration du service
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'geotrack_channel',
      initialNotificationTitle: 'GeoTrack Service',
      initialNotificationContent: 'Collecte GPS en cours',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  // Démarrer le service
  service.startService();
}

// Fonction de background pour iOS
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// Fonction principale du service
@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  // Pour Android, configurer le service foreground
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Démarrer les tâches périodiques
  startPeriodicTasks(service);
}

void startPeriodicTasks(ServiceInstance service) async {
  Timer.periodic(Duration(minutes: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await AutoCollectService.collectGpsDataBackground();
      }
    } else {
      await AutoCollectService.collectGpsDataBackground();
    }
  });

  Timer.periodic(Duration(minutes: 10), (timer) async {
    await AutoCollectService.syncGpsDataBackground();
  });
}
