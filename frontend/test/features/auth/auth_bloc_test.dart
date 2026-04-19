import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/core/api/api_client.dart';
import 'package:smart_campus/features/auth/bloc/auth_bloc.dart';
import 'package:smart_campus/features/auth/repositories/auth_repository.dart';
import 'package:smart_campus/features/auth/models/user_model.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(ApiClient());

  bool shouldFailLogin = false;

  @override
  Future<UserModel?> login(String email, String password) async {
    if (shouldFailLogin) {
      throw Exception('Invalid credentials');
    }
    return const UserModel(
      id: 'teacher-1',
      name: 'Teacher',
      email: 'teacher@smartcampus.com',
      role: 'teacher',
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isAuthenticated() async => false;
}

void main() {
  group('AuthBloc', () {
    test('emits loading then authenticated on success', () async {
      final repo = _FakeAuthRepository();
      final bloc = AuthBloc(repo);

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoginRequested(email: 'teacher@smartcampus.com', password: 'secret123'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(states.any((s) => s is AuthLoading), isTrue);
      expect(states.any((s) => s is AuthAuthenticated), isTrue);

      await sub.cancel();
      await bloc.close();
    });

    test('emits error on failed login', () async {
      final repo = _FakeAuthRepository()..shouldFailLogin = true;
      final bloc = AuthBloc(repo);

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoginRequested(email: 'teacher@smartcampus.com', password: 'wrong'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(states.any((s) => s is AuthLoading), isTrue);
      expect(states.any((s) => s is AuthError), isTrue);

      await sub.cancel();
      await bloc.close();
    });
  });
}
