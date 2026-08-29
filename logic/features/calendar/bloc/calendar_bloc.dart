// =============================================================
// calendar_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/calendar/bloc/calendar_bloc.dart)
// Events + states + bloc (all defined here).
// =============================================================

// EVENT:  LoadMonth(month: DateTime)
// STATES: CalendarInitial | CalendarLoading | CalendarLoaded(sessionsByDay) | CalendarError(msg)

// class CalendarBloc(CalendarRepository) :
//   _onLoadMonth(month) :
//     emit loading -> repo.fetchSessionsForMonth(year, month)
//     group sessions into map {date-without-time -> [sessions]} (putIfAbsent + add)
//     emit Loaded(grouped) ; error -> emit Error
