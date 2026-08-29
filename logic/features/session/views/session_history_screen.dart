// =============================================================
// session_history_screen.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/session/views/session_history_screen.dart)
// =============================================================

// class SessionHistoryScreen :

// build :
//   read teacherId from AuthBloc state (authenticated user id)
//   BlocProvider SessionBloc -> dispatch SessionHistoryRequested(teacherId)
//   BlocBuilder :
//     loaded -> list of past session cards; tap -> push /session/<id>
//     loading -> spinner ; error -> error message
