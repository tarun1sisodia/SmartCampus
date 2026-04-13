import 'package:dio/dio.dart';
import '../services/secure_storage_service.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor({SecureStorageService? storageService})
      : _storageService = storageService ?? SecureStorageService();

  final SecureStorageService _storageService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storageService.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
