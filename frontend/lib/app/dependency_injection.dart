import 'package:get_it/get_it.dart';
import 'package:smart_campus/features/analytics/bloc/analytics_bloc.dart';
import 'package:smart_campus/features/analytics/bloc/analytics_repository.dart';
import 'package:smart_campus/features/attendance/bloc/attendance_bloc.dart';
import 'package:smart_campus/features/attendance/bloc/attendance_repository.dart';
import 'package:smart_campus/features/auth/bloc/auth_bloc.dart';
import 'package:smart_campus/features/auth/bloc/auth_repository.dart';
import 'package:smart_campus/features/home/bloc/home_bloc.dart';
import 'package:smart_campus/features/home/bloc/home_repository.dart';
import 'package:smart_campus/features/calendar/bloc/calendar_bloc.dart';
import 'package:smart_campus/features/calendar/repositories/calendar_repository.dart';
import 'package:smart_campus/features/student/bloc/student_profile_bloc.dart';
import 'package:smart_campus/features/student/repositories/student_repository.dart';
import 'package:smart_campus/features/profile/bloc/profile_bloc.dart';
import 'package:smart_campus/features/profile/repositories/profile_repository.dart';
import '../core/api/api_client.dart';
import '../core/database/app_database.dart';
import '../core/database/dao/pending_attendance_dao.dart';
import '../core/database/dao/session_cache_dao.dart';
import '../core/cache/hive_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../core/services/biometric_service.dart';
import '../core/services/push_notification_service.dart';
import '../core/services/secure_storage_service.dart';
import '../core/services/background_task_service.dart';
import '../features/session/bloc/session_bloc.dart';
import '../features/session/bloc/session_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencyInjection() async {
  // Core
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);
  getIt.registerLazySingleton<PendingAttendanceDao>(
    () => PendingAttendanceDao(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<SessionCacheDao>(
    () => SessionCacheDao(getIt<AppDatabase>()),
  );
  
  final hiveService = HiveService();
  await hiveService.init();
  getIt.registerSingleton<HiveService>(hiveService);
  
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Services
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<BackgroundTaskService>(() => BackgroundTaskService());
  
  // Sync Service (Requires ApiClient and Database)
  getIt.registerLazySingleton<SyncService>(() => SyncService(
    getIt<ApiClient>(),
    getIt<AppDatabase>(),
    getIt<HiveService>(),
  ));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepository(
    getIt<ApiClient>(),
    getIt<HiveService>(),
  ));
  getIt.registerLazySingleton<AttendanceRepository>(() => AttendanceRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<AnalyticsRepository>(() => AnalyticsRepository(
    getIt<ApiClient>(),
    getIt<HiveService>(),
  ));
  getIt.registerLazySingleton<SessionRepository>(() => SessionRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<CalendarRepository>(() => CalendarRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<StudentRepository>(() => StudentRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository(getIt<ApiClient>()));

  // Blocs
  getIt.registerFactory(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => HomeBloc(getIt<HomeRepository>()));
  getIt.registerFactory(() => AttendanceBloc(
    getIt<AttendanceRepository>(),
    getIt<ConnectivityService>(),
    getIt<AppDatabase>(),
  ));
  getIt.registerFactory(() => AnalyticsBloc(getIt<AnalyticsRepository>()));
  getIt.registerFactory(() => SessionBloc(getIt<SessionRepository>()));
  getIt.registerFactory(() => CalendarBloc(getIt<CalendarRepository>()));
  getIt.registerFactory(() => StudentProfileBloc(getIt<StudentRepository>()));
  getIt.registerFactory(() => ProfileBloc(getIt<ProfileRepository>()));


}
