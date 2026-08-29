// =============================================================
// analytics_screen.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/analytics/views/analytics_screen.dart)
// =============================================================

// class AnalyticsScreen (StatefulWidget) :
//   _teacherId from AuthBloc state

// initState : dispatch AnalyticsLoadRequested(teacherId)  // default = last 30 days

// build :
//   BlocBuilder<AnalyticsBloc> :
//     loading -> shimmer/spinner ; error -> error text + retry
//     loaded :
//       date-range card -> pickers -> dispatch LoadStats(teacherId, range)
//       big overall attendance % card
//       subject breakdown list (bars) + trend chart (AttendancePercentageChart)
