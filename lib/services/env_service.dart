import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

/// EnvService: A service for accessing environment variables
/// This service provides a clean interface for accessing environment variables
/// and handles fallback values for missing variables.
class EnvService extends GetxService {
  // Singleton pattern implementation
  static final EnvService _instance = EnvService._internal();
  static EnvService get instance => Get.find<EnvService>();
  factory EnvService() => _instance;
  EnvService._internal();

  // Initialize the environment service
  Future<EnvService> init() async {
    print('Initializing EnvService...');
    await dotenv.load();
    print('EnvService initialized.');
    return this;
  }

  // API Configuration
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // App Configuration
  String get appName => dotenv.env['APP_NAME'] ?? 'SmartCampus';
  String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  String get appEnvironment => dotenv.env['APP_ENV'] ?? 'development';
  bool get isProduction => appEnvironment == 'production';
  bool get isDevelopment => appEnvironment == 'development';
  bool get isStaging => appEnvironment == 'staging';

  // Storage Configuration
  String get storageEncryptionKey => 
      dotenv.env['STORAGE_ENCRYPTION_KEY'] ?? 'AttendanceAppSecretKey';

  // Feature Flags
  bool get enableOfflineMode => 
      dotenv.env['ENABLE_OFFLINE_MODE']?.toLowerCase() == 'true';
  bool get enablePushNotifications => 
      dotenv.env['ENABLE_PUSH_NOTIFICATIONS']?.toLowerCase() == 'true';

  // Helper method to get any environment variable with a fallback
  String get(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  // Helper method to get a boolean environment variable with a fallback
  bool getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  // Helper method to get an integer environment variable with a fallback
  int getInt(String key, {int defaultValue = 0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  // Helper method to get a double environment variable with a fallback
  double getDouble(String key, {double defaultValue = 0.0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }
}