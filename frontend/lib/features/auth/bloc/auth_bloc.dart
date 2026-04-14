import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'auth_repository.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onAppStarted(
      AuthAppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final accessToken = await _authRepository.getAccessToken();
      final refreshToken = await _authRepository.getRefreshToken();
      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        emit(AuthUnauthenticated());
        return;
      }

      if (_isTokenExpired(accessToken)) {
        final refreshed = await _authRepository.refreshTokenPair();
        if (!refreshed) {
          await _authRepository.logout();
          emit(AuthUnauthenticated());
          return;
        }
      }

      final user = await _authRepository.getCurrentUser();
      emit(AuthAuthenticated(user));
    } catch (_) {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    }
  }

  bool _isTokenExpired(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! num) return true;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
      return DateTime.now().toUtc().isAfter(expiresAt);
    } catch (_) {
      return true;
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Login failed: Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError('Login error: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.forgotPassword(event.email);
      emit(const AuthInfo('Password reset link sent to your email'));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Forgot password error: ${e.toString()}'));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(event.token, event.newPassword);
      emit(const AuthInfo('Password reset successful. Please login again.'));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Reset password error: ${e.toString()}'));
    }
  }
}
