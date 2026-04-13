class EnvConfig {
  static const String apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5000/api/v1');
  static const bool enableBiometric = bool.fromEnvironment('ENABLE_BIOMETRIC', defaultValue: true);
  static const bool enablePushNotifications = bool.fromEnvironment('ENABLE_PUSH_NOTIFICATIONS', defaultValue: true);

  static void validate() {
    assert(apiUrl.isNotEmpty, 'API_URL must not be empty');
  }
}
