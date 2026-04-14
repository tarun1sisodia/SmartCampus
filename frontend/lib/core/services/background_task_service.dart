import 'package:background_fetch/background_fetch.dart' as bf;
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart' as wm;
import '../../app/dependency_injection.dart';
import 'sync_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
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
      await wm.Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await bf.BackgroundFetch.configure(
        bf.BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          startOnBoot: true,
          requiresBatteryNotLow: true,
          requiredNetworkType: bf.NetworkType.ANY,
        ),
        (String taskId) async {
          await initDependencyInjection();
          await getIt<SyncService>().syncPendingAttendance();
          bf.BackgroundFetch.finish(taskId);
        },
        (String taskId) async {
          bf.BackgroundFetch.finish(taskId);
        },
      );
    }
  }

  Future<void> schedulePeriodicSync() async {
    if (kIsWeb) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await wm.Workmanager().registerPeriodicTask(
        'smart-campus-sync',
        syncTaskName,
        frequency: const Duration(minutes: 15),
        constraints: wm.Constraints(
          networkType: wm.NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await bf.BackgroundFetch.scheduleTask(
        bf.TaskConfig(
          taskId: iosTaskId,
          delay: 15 * 60 * 1000,
          periodic: true,
          stopOnTerminate: false,
          enableHeadless: true,
          requiredNetworkType: bf.NetworkType.ANY,
        ),
      );
    }
  }
}
