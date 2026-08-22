import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus/features/profile/views/profile_screen.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/forgot_password_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/attendance/views/carousel_attendance_screen.dart';
import '../features/attendance/views/attendance_summary_screen.dart';
import '../features/analytics/views/analytics_screen.dart';
import '../features/session/views/session_history_screen.dart';
import '../features/session/views/session_detail_screen.dart';
import '../features/calendar/views/calendar_screen.dart';
import '../features/student/views/student_profile_screen.dart';
import '../features/attendance/views/teacher_qr_display_screen.dart';
import '../features/attendance/views/qr_scanner_screen.dart';

import '../features/settings/views/settings_screen.dart';
import '../features/home/views/main_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshBloc(authBloc),
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We could not open this page. Please return to Home.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    ),
    redirect: (context, state) {
      final authState = authBloc.state;
      final currentPath = state.uri.path;
      final isLoggingIn = currentPath == '/login';
      final isForgot = currentPath == '/forgot-password';

      if (authState is! AuthAuthenticated) {
        if (isLoggingIn || isForgot) return null;
        return '/login';
      }

      if (isLoggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Application Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
         
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Detail Routes (outside shell or inside, depending on UX preference)
      // Keeping them outside for "full-screen" detail experience
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/attendance/:sessionId',
        builder: (context, state) => CarouselAttendanceScreen(
          sessionId: _requiredPathParam(state, 'sessionId'),
        ),
      ),
      GoRoute(
        path: '/attendance/summary/:sessionId',
        builder: (context, state) => AttendanceSummaryScreen(
          sessionId: _requiredPathParam(state, 'sessionId'),
        ),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const SessionHistoryScreen(),
      ),
      GoRoute(
        path: '/sessions/history',
        redirect: (context, state) => '/history',
      ),
      GoRoute(
        path: '/session/:sessionId',
        builder: (context, state) => SessionDetailScreen(
          sessionId: _requiredPathParam(state, 'sessionId'),
        ),
      ),
      GoRoute(
        path: '/student/:studentId',
        builder: (context, state) => StudentProfileScreen(
          studentId: _requiredPathParam(state, 'studentId'),
        ),
      ),
      GoRoute(
        path: '/attendance/qr/generate/:sessionId',
        builder: (context, state) => TeacherQrDisplayScreen(
          sessionId: _requiredPathParam(state, 'sessionId'),
        ),
      ),
      GoRoute(
        path: '/attendance/qr/scan',
        builder: (context, state) => const QrScannerScreen(),
      ),
    ],
  );

  void goToSessionDetail(String sessionId) {
    router.go('/session/$sessionId');
  }

  String _requiredPathParam(GoRouterState state, String key) {
    final value = state.pathParameters[key];
    if (value == null || value.trim().isEmpty) {
      throw Exception('Missing required route parameter: $key');
    }
    return value;
  }
}

// Utility to make GoRouter react to BLoC state changes
class GoRouterRefreshBloc extends ChangeNotifier {
  late final dynamic _subscription;
  GoRouterRefreshBloc(BlocBase bloc) {
    _subscription = bloc.stream.listen((_) {
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
