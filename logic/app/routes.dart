// =============================================================
// routes.dart  ->  ALGORITHM ONLY (source: frontend/lib/app/routes.dart)
// All navigation routes + auth guard using go_router.
// =============================================================

// import: go_router, flutter_bloc, all screens, AuthBloc, GoRouterRefreshBloc helper

// class AppRouter(authBloc) :

// router = GoRouter with:
//   initialLocation '/home'
//   refreshListenable = GoRouterRefreshBloc(authBloc)  -> router re-evaluates on every auth state change
//   errorBuilder -> friendly "page not found" scaffold with a "Go to Home" button
//   redirect(context, state) :  the auth guard
//     read current auth state
//     if user NOT authenticated -> allow only /login and /forgot-password, else send to '/login'
//     if user authenticated and trying /login -> send to '/home'
//     otherwise allow
//   routes:
//     /login, /forgot-password                       -> public screens
//     StatefulShellRoute (indexed stack) -> MainScreen bottom-nav shell with 4 branches:
//       /home (HomeScreen), /calendar, /analytics, /settings   (each branch keeps its own state)
//     full-screen detail routes outside the shell:
//       /profile, /attendance/:sessionId (carousel marking),
//       /attendance/summary/:sessionId, /history (old /sessions/history redirects here),
//       /session/:sessionId (detail), /student/:studentId,
//       /attendance/qr/generate/:sessionId (teacher QR display), /attendance/qr/scan (scanner)

// goToSessionDetail(sessionId) : navigate to '/session/<sessionId>'

// _requiredPathParam(state, key) :
//   read path parameter; if missing/empty throw exception (defensive check)

// class GoRouterRefreshBloc (ChangeNotifier) :
//   listens to bloc stream; on every emission call notifyListeners() so go_router re-runs redirect
//   dispose() -> cancel the stream subscription
