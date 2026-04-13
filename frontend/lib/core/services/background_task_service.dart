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

  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  Future<void> schedulePeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      '1',
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
