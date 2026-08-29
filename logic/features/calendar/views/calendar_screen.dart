// =============================================================
// calendar_screen.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/calendar/views/calendar_screen.dart)
// =============================================================

// class CalendarScreen (StatefulWidget) :
//   uses a table calendar widget with focusedDay/selectedDay

// build :
//   BlocProvider CalendarBloc -> dispatch LoadMonth(current month)
//   on month/page change -> dispatch LoadMonth(newFocusedDay)
//   BlocBuilder :
//     loaded -> mark days that have sessions (dots/markers from sessionsByDay map)
//     loading -> skeleton ; error -> error text
//   day tap -> _showDaySessions(sessions of that day) :
//     bottom sheet list of that day's sessions
//     tap a session -> pop sheet + push /session/<id>
