import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../../app/dependency_injection.dart';
import 'sync_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize DI in the background process
      await initDependencyInjection();
      
      final syncService = getIt<SyncService>();
      await syncService.syncPendingAttendance();
      
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

class BackgroundTaskService {
  static const String syncTaskName = 'com.smartcampus.sync_task';
  static const String iosTaskId = 'com.smartcampus.ios.sync';

  Future<void> init() async {
    if (kIsWeb) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          startOnBoot: true,
          requiresBatteryNotLow: false,
          requiredNetworkType: NetworkType.ANY,
        ),
        (String taskId) async {
          await initDependencyInjection();
          await getIt<SyncService>().syncPendingAttendance();
          BackgroundFetch.finish(taskId);
        },
        (String taskId) async {
          BackgroundFetch.finish(taskId);
        },
      );
    }
  }

  Future<void> schedulePeriodicSync() async {
    if (kIsWeb) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await Workmanager().registerPeriodicTask(
        'smart-campus-sync',
        syncTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await BackgroundFetch.scheduleTask(
        TaskConfig(
          taskId: iosTaskId,
          delay: 15 * 60 * 1000,
          periodic: true,
          stopOnTerminate: false,
          enableHeadless: true,
          requiredNetworkType: NetworkType.ANY,
        ),
      );
    }
  }
}
