import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: accessTokenKey, value: accessToken);
    await _storage.write(key: refreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: refreshTokenKey);

  Future<void> deleteTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }

  // Backward-compatible static helpers while legacy modules are migrated.
  static final SecureStorageService _compat = SecureStorageService();
  static Future<void> saveTokensStatic(String access, String refresh) =>
      _compat.writeTokens(accessToken: access, refreshToken: refresh);
  static Future<String?> getAccessTokenStatic() => _compat.readAccessToken();
  static Future<String?> getRefreshTokenStatic() => _compat.readRefreshToken();
  static Future<void> clearTokensStatic() => _compat.deleteTokens();

  // Preserve existing method names used across legacy modules.
  static Future<void> saveTokens(String access, String refresh) =>
      saveTokensStatic(access, refresh);
  static Future<String?> getAccessToken() => getAccessTokenStatic();
  static Future<String?> getRefreshToken() => getRefreshTokenStatic();
  static Future<void> clearTokens() => clearTokensStatic();
}
