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
        final data = response.data['data'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userJson = data['user'];

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
  
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }
}
