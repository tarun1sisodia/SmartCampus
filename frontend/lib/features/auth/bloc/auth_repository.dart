import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepository(this._apiClient, {SecureStorageService? storageService})
      : _storageService = storageService ?? SecureStorageService();

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(Endpoints.login, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _extractPayload(response.data);
        final accessToken = data['accessToken']?.toString();
        final refreshToken = data['refreshToken']?.toString();
        final userJson = data['user'];

        if (accessToken == null ||
            refreshToken == null ||
            userJson is! Map<String, dynamic>) {
          throw Exception('Invalid login response payload');
        }

        // Store tokens
        await _storageService.writeTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        return UserModel.fromJson(userJson);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Map<String, dynamic> _extractPayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final nested = raw['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return raw;
    }
    throw Exception('Unexpected API response format');
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(Endpoints.logout);
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _storageService.deleteTokens();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.dio.post(Endpoints.forgotPassword, data: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _apiClient.dio.post(Endpoints.resetPassword, data: {
      'token': token,
      'newPassword': newPassword,
    });
  }

  Future<String?> getAccessToken() async => _storageService.readAccessToken();
  Future<String?> getRefreshToken() async => _storageService.readRefreshToken();

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.dio.get(Endpoints.me);
    final data = _extractPayload(response.data);
    final userJson = data['user'] ?? data;
    if (userJson is! Map<String, dynamic>) {
      throw Exception('Invalid current user response payload');
    }
    return UserModel.fromJson(userJson);
  }

  Future<bool> refreshTokenPair() async {
    final refreshToken = await _storageService.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final response = await _apiClient.dio.post(
      Endpoints.refresh,
      data: {'refreshToken': refreshToken},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      return false;
    }
    final data = _extractPayload(response.data);
    final accessToken = data['accessToken']?.toString();
    final newRefreshToken = data['refreshToken']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }
    await _storageService.writeTokens(
      accessToken: accessToken,
      refreshToken: (newRefreshToken == null || newRefreshToken.isEmpty)
          ? refreshToken
          : newRefreshToken,
    );
    return true;
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }
}
