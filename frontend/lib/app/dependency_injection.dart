import 'package:get_it/get_it.dart';
import 'package:smart_campus/features/analytics/bloc/analytics_bloc.dart';
import 'package:smart_campus/features/analytics/bloc/analytics_repository.dart';
import 'package:smart_campus/features/attendance/bloc/attendance_bloc.dart';
import 'package:smart_campus/features/attendance/bloc/attendance_repository.dart';
import 'package:smart_campus/features/auth/bloc/auth_bloc.dart';
import 'package:smart_campus/features/auth/bloc/auth_repository.dart';
import 'package:smart_campus/features/home/bloc/home_bloc.dart';
import 'package:smart_campus/features/home/bloc/home_repository.dart';
import '../core/api/api_client.dart';
import '../core/database/app_database.dart';
import '../core/cache/hive_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../core/services/biometric_service.dart';
import '../features/session/bloc/session_bloc.dart';
import '../features/session/bloc/session_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencyInjection() async {
  // Core
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);
  
  final hiveService = HiveService();
  await hiveService.init();
  getIt.registerSingleton<HiveService>(hiveService);
  
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // Services
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  
  // Sync Service (Requires ApiClient and Database)
  getIt.registerLazySingleton<SyncService>(() => SyncService(
    getIt<ApiClient>(),
    getIt<AppDatabase>(),
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

  // Blocs
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => HomeBloc(getIt<HomeRepository>()));
  getIt.registerFactory(() => AttendanceBloc(
    getIt<AttendanceRepository>(),
    getIt<ConnectivityService>(),
    getIt<AppDatabase>(),
  ));
  getIt.registerFactory(() => AnalyticsBloc(getIt<AnalyticsRepository>()));
  getIt.registerFactory(() => SessionBloc(getIt<SessionRepository>()));


}
