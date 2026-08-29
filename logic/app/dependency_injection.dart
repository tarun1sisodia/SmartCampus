// =============================================================
// dependency_injection.dart  ->  ALGORITHM ONLY (source: frontend/lib/app/dependency_injection.dart)
// Service locator (get_it): one place that builds and wires every object.
// =============================================================

// import: get_it + all blocs, repositories, api client, database, hive, services

// global: final getIt = GetIt.instance

// initDependencyInjection() async :
//   CORE:
//     create AppDatabase (SQLite) as singleton
//     register PendingAttendanceDao + SessionCacheDao (lazy, they use the db)
//     create HiveService, await init() (opens all boxes), register as singleton
//     register ApiClient (lazy singleton)  -> Dio + token interceptors
//   SERVICES (lazy singletons):
//     ConnectivityService, BiometricService, PushNotificationService(needs ApiClient),
//     SecureStorageService, BackgroundTaskService, AppFeedbackService
//     SyncService (needs ApiClient + Database + Hive + FeedbackService)
//   REPOSITORIES (lazy singletons, each takes ApiClient):
//     Auth, Home(+Hive), Attendance, Analytics(+Hive), Session, Calendar, Student, Profile
//   BLOCS:
//     AuthBloc + SettingsBloc as lazy singletons (app-wide, live whole session)
//     HomeBloc, AttendanceBloc, AnalyticsBloc, SessionBloc, CalendarBloc,
//     StudentProfileBloc, ProfileBloc registered as factories (fresh instance per screen)
//   QR FEATURES:
//     LocationService (lazy singleton), QrGeneratorBloc + QrScannerBloc (factories)
