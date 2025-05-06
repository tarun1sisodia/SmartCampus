import 'package:flutter/material.dart';

import '../../common/utils/constants/colors.dart';
import 'custom_themes/appbar_theme.dart';
import 'custom_themes/bottom_sheet_theme.dart';
import 'custom_themes/checkbox_theme.dart';
import 'custom_themes/chip_theme.dart';
import 'custom_themes/elevated_button_theme.dart';
import 'custom_themes/searchbar_theme.dart';
import 'custom_themes/text_field_theme.dart';
import 'custom_themes/text_theme.dart';
import 'custom_themes/card_theme.dart'; // New file to create

/// TAppTheme implements several UX laws:
/// - Aesthetic-Usability Effect: Consistent, pleasing visual design
/// - Law of Similarity: Consistent styling across components
/// - Hick's Law: Limited color palette to reduce decision complexity
/// - Jakob's Law: Following platform conventions users already know
class TAppTheme {
  TAppTheme._();

  // Implementing Doherty Threshold - ensure UI responds quickly
  // by using lightweight theme definitions
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: TColors.blue,
    scaffoldBackgroundColor: TColors.white,

    // Implementing Law of Proximity with consistent spacing
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Component themes
    textTheme: TtextTheme.lighttextTheme,
    inputDecorationTheme: TTextFieldTheme.lightInputDecoration,
    appBarTheme: TAppbarTheme.lightAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.lightCheckBoxTheme,
    chipTheme: TChipTheme.lightChipThemeData,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButton,
    searchBarTheme: TSearchbarTheme.lightSearchBar,
    cardTheme: TCardTheme.lightCardTheme, // New theme to add
    iconTheme: IconThemeData(color: TColors.dark),

    // Implementing Fitts's Law with appropriate sizing
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // Implementing Law of Common Region with consistent surface treatments
    colorScheme: ColorScheme.light(
      primary: TColors.blue,
      secondary: TColors.blue.withOpacity(0.8),
      surface: TColors.white,
      error: Colors.red.shade700,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: TColors.dark,

    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Component themes
    textTheme: TtextTheme.darktextTheme,
    inputDecorationTheme: TTextFieldTheme.darkInputDecoration,
    appBarTheme: TAppbarTheme.darkAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.darkCheckBoxTheme,
    chipTheme: TChipTheme.darkChipThemeData,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButton,
    searchBarTheme: TSearchbarTheme.darkSearchBar,
    cardTheme: TCardTheme.darkCardTheme, // New theme to add
    iconTheme: IconThemeData(color: Colors.white),

    materialTapTargetSize: MaterialTapTargetSize.padded,

    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blue.shade300,
      surface: Colors.grey.shade900,
      error: Colors.red.shade300,
    ),
  );
}
