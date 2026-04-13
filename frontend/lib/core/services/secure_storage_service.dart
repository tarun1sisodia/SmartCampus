import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  static Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  static Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  static Future<void> clearTokens() async => await _storage.deleteAll();
}
