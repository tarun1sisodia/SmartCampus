import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_x;
import '../../common/utils/constants/api_constants.dart';
import '../services/secure_storage_service.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.backendBaseUrl, // Use dynamic URL from constants
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Attempt refresh
          final refreshToken = await SecureStorageService.getRefreshToken();
          if (refreshToken != null) {
            try {
              // Create a special Dio instance for refresh to avoid interceptor loops
              final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
              final response = await refreshDio.post('/auth/refresh', data: {
                'refreshToken': refreshToken,
              });
              
              final newAccess = response.data['data']['accessToken'];
              await SecureStorageService.saveTokens(newAccess, refreshToken);
              
              // Retry original request
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              final retry = await _dio.fetch(error.requestOptions);
              return handler.resolve(retry);
            } catch (e) {
              // Refresh failed - logout
              await SecureStorageService.clearTokens();
              get_x.Get.offAllNamed('/login');
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  static Dio get dio => _dio;
}
