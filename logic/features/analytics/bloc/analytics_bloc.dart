// =============================================================
// analytics_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/analytics/bloc/analytics_bloc.dart)
// Events + states + bloc (all defined here).
// =============================================================

// EVENTS: AnalyticsLoadRequested(teacherId, startDate?, endDate?) | LoadStats(teacherId, range)

// STATES: AnalyticsInitial | AnalyticsLoading | AnalyticsLoaded(stats, range) | AnalyticsError(message)

// class AnalyticsBloc(AnalyticsRepository) :

// _onLoadRequested :  first load (default range = last 30 days)
//   build range from event or default
//   read cached stats (Hive, 1h TTL) -> if cache valid AND no custom range -> emit Loaded(cache) instantly
//   else emit loading
//   fetch fresh stats for the range -> emit Loaded
//   on error -> emit Error ONLY if nothing is on screen (keep stale data instead)

// _onLoadStats :  user picked a new date range
//   emit loading -> fetch for the chosen range -> emit Loaded ; error -> emit Error
