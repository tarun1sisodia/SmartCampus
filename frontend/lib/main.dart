import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app/app.dart';
import 'app/dependency_injection.dart';
import 'env/env_config.dart';
import 'core/services/background_task_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/sync_service.dart';

import 'core/utils/platform_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Validate and load environment
  EnvConfig.validate();

  // Initialize all dependencies (Core DB, Hive)
  await initDependencyInjection();

  runApp(const App());

  // After first frame, initialize non-critical services asynchronously
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeOptionalServices();
  });
}

Future<void> _initializeOptionalServices() async {
  const timeout = Duration(seconds: 4);
  debugPrint('🚀 Starting optional services initialization...');

  // 1. Firebase (Mobile only)
  if (PlatformHelper.isMobile) {
    try {
      await Firebase.initializeApp().timeout(timeout);
      debugPrint('✅ Firebase initialized');
    } catch (e) {
      debugPrint('⚠️ Firebase init failed or timed out: $e');
    }
  } else {
    debugPrint('📵 Skipping Firebase on non-mobile platform');
  }

  // 2. Background Tasks (Android only)
  if (PlatformHelper.isAndroid) {
    try {
      final backgroundService = getIt<BackgroundTaskService>();
      await backgroundService.init().timeout(timeout);
      await backgroundService.schedulePeriodicSync().timeout(timeout);
      debugPrint('✅ Background tasks initialized');
    } catch (e) {
      debugPrint('⚠️ Background tasks init failed: $e');
    }
  }

  // 3. Offline Sync (Android only for now)
  if (PlatformHelper.isAndroid) {
    try {
      await getIt<SyncService>().syncPendingAttendance().timeout(timeout);
      debugPrint('✅ Attendance sync completed');
    } catch (e) {
      debugPrint('⚠️ Initial sync failed: $e');
    }
  }

  // 4. Push Notifications (Mobile only)
  if (PlatformHelper.isMobile) {
    try {
      await getIt<PushNotificationService>().init().timeout(timeout);
      debugPrint('✅ Push notifications initialized');
    } catch (e) {
      debugPrint('⚠️ Push notifications init failed: $e');
    }
  }

  // 5. Sentry (Optional for local dev)
  try {
    await SentryFlutter.init(
      (options) {
        options.dsn = EnvConfig.sentryDsn;
        options.tracesSampleRate = 0.1;
      },
    ).timeout(timeout);
    debugPrint('✅ Sentry initialized');
  } catch (e) {
    debugPrint('⚠️ Sentry init failed: $e');
  }

  debugPrint('🏁 Async initialization routine finished');
}

