import 'package:dio/dio.dart';
import '../../env/env_config.dart';
import 'token_interceptor.dart';
import 'refresh_token_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: EnvConfig.apiUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(TokenInterceptor());
    _dio.interceptors.add(RefreshTokenInterceptor(_dio));
    
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
