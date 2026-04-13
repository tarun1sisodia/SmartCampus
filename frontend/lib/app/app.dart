import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dependency_injection.dart';
import 'routes.dart';
import 'theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/home/bloc/home_bloc.dart';
import '../features/attendance/bloc/attendance_bloc.dart';
import '../features/analytics/bloc/analytics_bloc.dart';
import '../core/services/push_notification_service.dart';


class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;
  late final PushNotificationService _pushNotificationService;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _authBloc.add(AuthAppStarted());
    _appRouter = AppRouter(_authBloc);
    _pushNotificationService = getIt<PushNotificationService>();
    _pushNotificationService.lastOpenedSessionId.addListener(_onSessionNotificationOpened);
  }

  @override
  void dispose() {
    _pushNotificationService.lastOpenedSessionId.removeListener(_onSessionNotificationOpened);
    super.dispose();
  }

  void _onSessionNotificationOpened() {
    final sessionId = _pushNotificationService.lastOpenedSessionId.value;
    if (sessionId == null || sessionId.isEmpty) {
      return;
    }
    _appRouter.goToSessionDetail(sessionId);
    _pushNotificationService.lastOpenedSessionId.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<HomeBloc>(create: (context) => getIt<HomeBloc>()),
        BlocProvider<AttendanceBloc>(create: (context) => getIt<AttendanceBloc>()),
        BlocProvider<AnalyticsBloc>(create: (context) => getIt<AnalyticsBloc>()),
      ],

      child: MaterialApp.router(
        title: 'SmartCampus Teacher',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: _appRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
