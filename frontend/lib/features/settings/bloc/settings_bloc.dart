import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cache/hive_service.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadSettings extends SettingsEvent {}

class UpdateThemeMode extends SettingsEvent {
  const UpdateThemeMode(this.themeMode);
  final ThemeMode themeMode;

  @override
  List<Object?> get props => <Object?>[themeMode];
}

class UpdateLocale extends SettingsEvent {
  const UpdateLocale(this.locale);
  final Locale locale;

  @override
  List<Object?> get props => <Object?>[locale.languageCode, locale.countryCode];
}

class SettingsState extends Equatable {
  const SettingsState({
    required this.themeMode,
    required this.locale,
  });

  final ThemeMode themeMode;
  final Locale locale;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[themeMode, locale.languageCode, locale.countryCode];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._hiveService)
      : super(const SettingsState(
            themeMode: ThemeMode.light, locale: Locale('en'))) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateLocale>(_onUpdateLocale);
  }

  final HiveService _hiveService;

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final settings = _hiveService.settingsBox;
    final isDark = settings.get('dark_mode') == true;
    final langCode = (settings.get('language') ?? 'en').toString();
    emit(
      state.copyWith(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        locale: Locale(langCode),
      ),
    );
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    await _hiveService.settingsBox
        .put('dark_mode', event.themeMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onUpdateLocale(
    UpdateLocale event,
    Emitter<SettingsState> emit,
  ) async {
    await _hiveService.settingsBox.put('language', event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }
}
