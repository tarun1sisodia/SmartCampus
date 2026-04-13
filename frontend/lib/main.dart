import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app/app.dart';
import 'app/dependency_injection.dart';
import 'env/env_config.dart';
import 'core/services/background_task_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (picks up google-services.json automatically on Android)
  await Firebase.initializeApp();

  // Validate and load environment
  EnvConfig.validate();
  
  // Initialize all dependencies (Hive, Database, Services, Repositories, Blocs)
  await initDependencyInjection();

  // Initialize background tasks
  final backgroundService = getIt<BackgroundTaskService>();
  await backgroundService.init();
  await backgroundService.schedulePeriodicSync();

  // Sync any pending offline attendance on startup.
  await getIt<SyncService>().syncPendingAttendance();

  // Initialize Push Notifications
  await getIt<PushNotificationService>().init();
  
  await SentryFlutter.init(
    (options) {
      options.dsn = EnvConfig.sentryDsn;
      options.tracesSampleRate = 0.1;
    },
    appRunner: () => runApp(const App()),
  );
}
