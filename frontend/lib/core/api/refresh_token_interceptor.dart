import 'package:dio/dio.dart';
import '../../env/env_config.dart';
import '../../app/dependency_injection.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import 'endpoints.dart';
import '../services/secure_storage_service.dart';

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor(
    this._dio, {
    SecureStorageService? storageService,
    void Function()? onSessionExpired,
  })  : _storageService = storageService ?? SecureStorageService(),
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final SecureStorageService _storageService;
  final void Function()? _onSessionExpired;
  bool _isRefreshing = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (_isRefreshOrLogout(err.requestOptions.path) || _isRefreshing) {
        return handler.next(err);
      }

      final refreshToken = await _storageService.readRefreshToken();
      if (refreshToken != null) {
        try {
          _isRefreshing = true;
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: _dio.options.baseUrl.isEmpty
                  ? EnvConfig.apiBaseUrl
                  : _dio.options.baseUrl,
              connectTimeout: _dio.options.connectTimeout,
              receiveTimeout: _dio.options.receiveTimeout,
              headers: _dio.options.headers,
            ),
          );

          final response = await refreshDio.post(Endpoints.refresh, data: {
            'refreshToken': refreshToken,
          });

          if (response.statusCode == 200 || response.statusCode == 201) {
            final newAccessToken = response.data['data']['accessToken'];
            final newRefreshToken = response.data['data']['refreshToken'];

            await _storageService.writeTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken ?? refreshToken,
            );

            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await _dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
          await _clearTokensAndLogout();
        } catch (_) {
          await _clearTokensAndLogout();
        } finally {
          _isRefreshing = false;
        }
      } else {
        await _clearTokensAndLogout();
      }
    }
    super.onError(err, handler);
  }

  bool _isRefreshOrLogout(String path) {
    return path.contains(Endpoints.refresh) || path.contains(Endpoints.logout);
  }

  Future<void> _clearTokensAndLogout() async {
    await _storageService.deleteTokens();
    if (getIt.isRegistered<AuthBloc>()) {
      getIt<AuthBloc>().add(AuthLogoutRequested());
    }
    _onSessionExpired?.call();
  }
}
