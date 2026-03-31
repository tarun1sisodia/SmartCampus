import 'package:flutter/material.dart';

import 'custom_themes/appbar_theme.dart';
import 'custom_themes/bottom_sheet_theme.dart';
import 'custom_themes/checkbox_theme.dart';
import 'custom_themes/chip_theme.dart';
import 'custom_themes/elevated_button_theme.dart';
import 'custom_themes/searchbar_theme.dart';
import 'custom_themes/text_field_theme.dart';
import 'custom_themes/text_theme.dart';
import 'custom_themes/card_theme.dart';
import 'theme_configs.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData createTheme(ThemeConfig config) {
    final brightness = config.isDark ? Brightness.dark : Brightness.light;
    
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: brightness,
      primaryColor: config.primary,
      scaffoldBackgroundColor: config.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Component themes using refactored methods
      textTheme: TtextTheme.createTextTheme(config.textPrimary, config.textSecondary),
      inputDecorationTheme: TTextFieldTheme.createInputDecorationTheme(
        config.primary, config.surface, config.textPrimary, config.error, brightness
      ),
      appBarTheme: TAppbarTheme.createAppBarTheme(brightness),
      bottomSheetTheme: TBottomSheetTheme.createBottomSheetTheme(config.surface, brightness),
      checkboxTheme: TCheckboxTheme.createCheckboxTheme(config.primary, config.background, brightness),
      chipTheme: TChipTheme.createChipTheme(config.primary, config.surface, config.textPrimary, brightness),
      elevatedButtonTheme: TElevatedButtonTheme.createElevatedButtonTheme(config.primary, Colors.white, brightness),
      searchBarTheme: TSearchbarTheme.createSearchBarTheme(config.surface, config.textPrimary, config.textSecondary, brightness),
      cardTheme: TCardTheme.createCardTheme(config.surface, brightness),
      
      iconTheme: IconThemeData(color: config.textPrimary),
      
      materialTapTargetSize: MaterialTapTargetSize.padded,
      
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: config.primary,
        onPrimary: config.isDark ? Colors.black : Colors.white,
        secondary: config.accent,
        onSecondary: config.isDark ? Colors.black : Colors.white,
        surface: config.surface,
        onSurface: config.textPrimary,
        error: config.error,
        onError: Colors.white,
        surfaceContainerHighest: config.surface, // Extra surface for cards
      ),
    );
  }

  // Default themes for backward compatibility
  // Using themes[7] (Executive Navy) and themes[1] (Onyx Brutalist) as defaults
  static ThemeData lightTheme = createTheme(AppThemes.themes[7]); 
  static ThemeData darkTheme = createTheme(AppThemes.themes[1]);
}
