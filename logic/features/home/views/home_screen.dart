// =============================================================
// home_screen.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/home/views/home_screen.dart)
// =============================================================

// class HomeScreen (StatefulWidget) :

// initState() : dispatch LoadTodaySessions

// build :
//   appbar: profile icon -> push /profile ; logout icon -> dispatch LogoutRequested
//   BlocBuilder<HomeBloc, HomeState> :
//     loading    -> _buildShimmerState() (skeleton loading cards)
//     error      -> error widget with retry -> dispatch LoadTodaySessions again
//     loaded     -> stats overview row + "Today's Sessions" list:
//                     session card tap -> push /session/<id>
//                     "View All"       -> push /history
//   floating action button (scan icon) -> push /attendance/qr/scan (QR scanner)
