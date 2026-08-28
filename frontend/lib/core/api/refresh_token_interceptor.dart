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

  /// Single-flight refresh: all concurrent 401s await the same in-flight
  /// refresh call. Without this, two parallel requests could both attempt a
  /// refresh — the first rotates the refresh token, the second then fails
  /// with the (now revoked) old token and logs the user out.
  Future<_RefreshResult?>? _refreshFuture;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (_isRefreshOrLogout(err.requestOptions.path)) {
        return handler.next(err);
      }

      final refreshToken = await _storageService.readRefreshToken();
      if (refreshToken == null) {
        await _clearTokensAndLogout();
        return super.onError(err, handler);
      }

      try {
        final refreshed = await (_refreshFuture ??= _performRefresh(refreshToken));
        _refreshFuture = null;

        if (refreshed == null) {
          await _clearTokensAndLogout();
          return super.onError(err, handler);
        }

        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
        final retryResponse = await _dio.fetch(opts);
        return handler.resolve(retryResponse);
      } catch (_) {
        _refreshFuture = null;
        await _clearTokensAndLogout();
      }
    }
    super.onError(err, handler);
  }

  Future<_RefreshResult?> _performRefresh(String refreshToken) async {
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl.isEmpty
            ? EnvConfig.apiBaseUrl
            : _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
      ),
    );

    final response = await refreshDio.post(
      Endpoints.refresh,
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      return null;
    }

    final newAccessToken = response.data['data']['accessToken'] as String?;
    if (newAccessToken == null || newAccessToken.isEmpty) return null;

    final newRefreshToken = response.data['data']['refreshToken'] as String?;
    await _storageService.writeTokens(
      accessToken: newAccessToken,
      refreshToken: (newRefreshToken == null || newRefreshToken.isEmpty)
          ? refreshToken
          : newRefreshToken,
    );
    return _RefreshResult(newAccessToken);
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

class _RefreshResult {
  final String accessToken;
  const _RefreshResult(this.accessToken);
}
