// =============================================================
// main.dart  ->  ALGORITHM ONLY (source: frontend/lib/main.dart)
// Entry point of the SmartCampus Teacher app.
// =============================================================

// import: flutter material, firebase_core, sentry_flutter, app (App widget),
//         dependency_injection, env_config, background_task_service,
//         push_notification_service, sync_service, platform_helper

// main() async :
//   ensure Flutter bindings are initialized (needed before using plugins)
//   validate environment config (API base url, sentry dsn, feature flags)
//   await initDependencyInjection()  -> setup SQLite DB, Hive boxes, ApiClient, services, repositories, blocs
//   runApp(const App())  -> the app is loaded on screen
//   register a post-first-frame callback -> start non-critical services AFTER first paint (keeps startup fast)

// _initializeOptionalServices() :
//   every step wrapped in try-catch with a 4 second timeout, so one failed service never crashes or blocks the others
//   1. if platform is mobile          -> Firebase.initializeApp() (skip on web/desktop)
//   2. if platform is android         -> init BackgroundTaskService + schedule periodic sync (every 15 min)
//   3. if platform is android         -> SyncService.syncPendingAttendance() once at startup (push offline records)
//   4. if platform is mobile          -> PushNotificationService.init() (permission, FCM token, notification channel)
//   5. always (optional)              -> SentryFlutter.init() with dsn from env, 10% trace sample rate
//   log that the async init routine is finished
