import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus/core/api/api_client.dart';
import 'package:smart_campus/features/auth/bloc/auth_bloc.dart';
import 'package:smart_campus/features/auth/models/user_model.dart';
import 'package:smart_campus/features/auth/repositories/auth_repository.dart';
import 'package:smart_campus/features/auth/views/login_screen.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(ApiClient());

  @override
  Future<UserModel?> login(String email, String password) async {
    return const UserModel(
      id: 'teacher-1',
      name: 'Teacher One',
      email: 'teacher@smartcampus.com',
      role: 'teacher',
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login form submits without runtime errors', (tester) async {
    final bloc = AuthBloc(_FakeAuthRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'teacher@smartcampus.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    expect(bloc.state is AuthAuthenticated, isTrue);
    await bloc.close();
  });
}
