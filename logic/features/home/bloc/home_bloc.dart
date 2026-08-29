// =============================================================
// home_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/home/bloc/home_bloc.dart)
// Events + states + bloc for the home dashboard (today's sessions).
// =============================================================

// EVENTS: HomeLoadRequested / LoadTodaySessions (alias)

// STATES: HomeInitial | HomeLoading | HomeLoaded(sessions) | HomeError(message)

// class HomeBloc(HomeRepository) :
//   _onLoadRequested() :
//     read cached today-sessions (Hive) -> if cache exists show it INSTANTLY (offline-first UX)
//     else emit loading
//     fetch fresh sessions from API -> emit Loaded
//     on error -> only emit Error if we have nothing on screen (keep stale data rather than failing)
