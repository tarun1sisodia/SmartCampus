// =============================================================
// session_detail_screen.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/session/views/session_detail_screen.dart)
// =============================================================

// class SessionDetailScreen(sessionId) :

// build :
//   BlocProvider SessionBloc -> dispatch SessionDetailsRequested(sessionId)
//   BlocBuilder :
//     loading -> spinner ; error -> error text
//     loaded :
//       _builderHeader(session, time) -> subject, section, date/time
//       _buildStatusChip(status) -> colored chip for scheduled/ongoing/completed
//       action buttons:
//         'MARK ATTENDANCE' -> push /attendance/<sessionId>       (carousel)
//         'SHOW QR'         -> push /attendance/qr/generate/<sessionId>
//       attendance record list: each row -> tap push /student/<studentId>
