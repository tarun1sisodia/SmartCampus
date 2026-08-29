// =============================================================
// background_task_service.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/core/services/background_task_service.dart)
// Periodic background sync — Workmanager (Android) / background_fetch (iOS).
// =============================================================

// callbackDispatcher() (top-level, vm entry-point) :
//   executed by the OS in the background:
//   re-init dependency injection (fresh isolate has no memory of the app)
//   wait 2 seconds -> run SyncService.syncPendingAttendance()
//   return true on success / false on error

// class BackgroundTaskService :
//   init() :
//     skip on non-mobile platforms
//     android -> Workmanager.initialize(callbackDispatcher)
//     ios     -> BackgroundFetch.configure: min interval 15 min, continue after terminate,
//                start on boot, battery-not-low, any network; the callback re-inits DI then syncs

//   schedulePeriodicSync() :
//     skip on non-mobile
//     android -> registerPeriodicTask 'smart-campus-sync' every 15 min, requires network + battery not low
//     ios     -> schedule the periodic task with delay 15 min, periodic true
