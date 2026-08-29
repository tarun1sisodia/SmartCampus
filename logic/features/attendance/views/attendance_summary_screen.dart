// =============================================================
// attendance_summary_screen.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/views/attendance_summary_screen.dart)
// =============================================================

// class AttendanceSummaryScreen(sessionId) :

// build :
//   BlocBuilder<AttendanceBloc> :
//     loaded -> count students per status: present / absent / late / pending
//     _buildSummaryBody :
//       header row of the 4 counts (pending shown only if > 0), color coded
//       list of student tiles: photo placeholder, name, roll, status color (green/red/orange/grey)
//       bottom actions:
//         'MARK PENDING' (if pending > 0) -> pop back to the carousel to finish remaining students
//         'DONE' -> context.go('/home')   // clear the stack back to dashboard
//     error -> centered error text
