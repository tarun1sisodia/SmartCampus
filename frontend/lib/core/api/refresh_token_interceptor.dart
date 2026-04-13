import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RefreshTokenInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Check if it's already a refresh attempt or logout attempt to avoid loops
      if (err.requestOptions.path.contains('/auth/refresh') || 
          err.requestOptions.path.contains('/auth/logout')) {
        return handler.next(err);
      }

      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          // Attempt to refresh token
          final response = await _dio.post('/auth/refresh', data: {
            'refreshToken': refreshToken,
          });

          if (response.statusCode == 200 || response.statusCode == 201) {
            final newAccessToken = response.data['data']['accessToken'];
            final newRefreshToken = response.data['data']['refreshToken'];

            await _storage.write(key: 'access_token', value: newAccessToken);
            if (newRefreshToken != null) {
              await _storage.write(key: 'refresh_token', value: newRefreshToken);
            }

            // Retry the original request with the new token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await _dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // If refresh fails, logout
          await _clearTokensAndLogout();
        }
      } else {
        await _clearTokensAndLogout();
      }
    }
    super.onError(err, handler);
  }

  Future<void> _clearTokensAndLogout() async {
    await _storage.deleteAll();
    // TODO: Emit global logout event or navigate to login
    // One way is using a global stream or event bus
  }
}
