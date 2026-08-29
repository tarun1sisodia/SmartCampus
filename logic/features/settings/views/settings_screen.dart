// =============================================================
// settings_screen.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/settings/views/settings_screen.dart)
// =============================================================

// class SettingsScreen (StatelessWidget, with UIFeedbackMixin) :

// build :
//   BlocBuilder<SettingsBloc> :
//     sections (_buildSectionHeader = title + divider):
//       appearance -> dark mode toggle -> dispatch UpdateThemeMode
//       profile    -> tile -> Navigator push ProfileScreen
//       logout     -> tile -> _showLogoutConfirm
//     footer: app version text

// _showLogoutConfirm :
//   dialog 'Are you sure?' CANCEL / LOGOUT
//   logout -> dispatch LogoutRequested + pop dialog (router then goes to /login)
