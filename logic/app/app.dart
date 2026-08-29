// =============================================================
// app.dart  ->  ALGORITHM ONLY (source: frontend/lib/app/app.dart)
// Root MaterialApp widget + global bloc providers.
// =============================================================

// import: flutter material, flutter_bloc, dependency_injection (getIt), routes, theme,
//         AuthBloc, HomeBloc, AttendanceBloc, AnalyticsBloc, SettingsBloc,
//         app_feedback_service, push_notification_service

// class App (StatefulWidget) / _AppState :

// initState() :
//   get AuthBloc from getIt and fire AuthAppStarted  -> app checks saved login session (auto-login or go to login)
//   create AppRouter(authBloc)                       -> navigation reacts to auth state
//   get PushNotificationService + AppFeedbackService from getIt
//   listen to pushService.lastOpenedSessionId        -> when user taps a session notification, open that session
//   fire SettingsBloc LoadSettings                   -> load saved theme mode (light/dark) + language

// dispose() :
//   remove the notification listener

// _onSessionNotificationOpened() :
//   read sessionId from the notifier; if empty do nothing
//   navigate to /session/<sessionId> and reset the notifier to null

// build(context) :
//   wrap app in MultiBlocProvider -> AuthBloc, HomeBloc, AttendanceBloc, AnalyticsBloc, SettingsBloc available app-wide
//   BlocBuilder on SettingsBloc -> rebuild MaterialApp when theme/locale changes
//   return MaterialApp.router with:
//     - light + dark themes, themeMode from settings state
//     - locale from settings state
//     - routerConfig = AppRouter.router (go_router)
//     - scaffoldMessengerKey = feedback service key (shows global snackbars even without context)
