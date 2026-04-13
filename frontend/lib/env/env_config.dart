class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api/v1',
  );
  @Deprecated('Use apiBaseUrl')
  static const String apiUrl = apiBaseUrl;
  static const bool enableBiometric = bool.fromEnvironment('ENABLE_BIOMETRIC', defaultValue: true);
  static const bool enablePushNotifications = bool.fromEnvironment('ENABLE_PUSH_NOTIFICATIONS', defaultValue: true);
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static void validate() {
    assert(apiBaseUrl.isNotEmpty, 'API_BASE_URL must not be empty');
  }
}
