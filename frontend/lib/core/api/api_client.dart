import 'package:dio/dio.dart';
import '../../env/env_config.dart';
import 'token_interceptor.dart';
import 'refresh_token_interceptor.dart';
import 'mock_interceptor.dart';
import '../services/secure_storage_service.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorageService;

  ApiClient({SecureStorageService? secureStorageService})
      : _secureStorageService = secureStorageService ?? SecureStorageService(),
        _dio = Dio(
          BaseOptions(
            baseUrl: EnvConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    if (EnvConfig.useMockData) {
      _dio.interceptors.add(MockInterceptor());
    } else {
      _dio.interceptors.add(
        TokenInterceptor(storageService: _secureStorageService),
      );
      _dio.interceptors.add(
        RefreshTokenInterceptor(
          _dio,
          storageService: _secureStorageService,
        ),
      );
    }
    
    // LogInterceptor in debug mode only
    assert(() {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
      return true;
    }());
  }

  Dio get dio => _dio;
}
