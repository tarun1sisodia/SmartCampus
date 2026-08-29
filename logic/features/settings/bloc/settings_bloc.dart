// =============================================================
// settings_bloc.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/settings/bloc/settings_bloc.dart)
// Events + state + bloc for theme & language (persisted in Hive).
// =============================================================

// EVENTS: LoadSettings | UpdateThemeMode(themeMode) | UpdateLocale(locale)

// class SettingsState : themeMode + locale, copyWith helper (defaults: light + english)

// class SettingsBloc(HiveService) :
//   _onLoadSettings :
//     dark_mode == true ? dark : light ; language <- box ('en' default) -> emit state
//   _onUpdateThemeMode : persist 'dark_mode' bool in settings box -> emit new theme
//   _onUpdateLocale    : persist language code -> emit new locale
