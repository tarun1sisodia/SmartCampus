import 'package:flutter/material.dart';

import 'constants.dart';

/// AppDimensions implements several UX laws:
/// - Fitts's Law: Appropriate sizing for interactive elements
/// - Law of Proximity: Consistent spacing to group related elements
/// - Miller's Law: Limited number of size options (small, medium, large)
class AppDimensions {
  AppDimensions._();

  // Card properties
  static const double cardElevation = 2.0;
  static const double cardRadius = 12.0;

  // Interactive element properties (Fitts's Law)
  static const double buttonRadius = 8.0;
  static const double inputRadius = 8.0;
  static const double minTouchTarget = 48.0; // Minimum size for touch targets

  // Spacing system (Law of Proximity)
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Typography scale (Visual hierarchy)
  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeTitle = 16.0;
  static const double fontSizeHeadline = 20.0;
  static const double fontSizeLargeTitle = 24.0;

  // Animation durations (Doherty Threshold)
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);
}

/// AppTheme implements:
/// - Aesthetic-Usability Effect: Visually pleasing, consistent design
/// - Hick's Law: Limited color palette
/// - Law of Similarity: Consistent styling across components
final ThemeData appTheme = ThemeData(
  primaryColor: TColors.primary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: TColors.primary,
    primary: TColors.primary,
    secondary: TColors.secondary,
    error: TColors.error,
    background: TColors.backgroundLight,
    // Expanded color scheme for better visual hierarchy
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: TColors.textPrimary,
    onBackground: TColors.textPrimary,
  ),
  scaffoldBackgroundColor: TColors.backgroundLight,

  // Card theme (Law of Common Region)
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: AppDimensions.cardElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
    ),
    margin: EdgeInsets.all(AppDimensions.spacingSmall),
  ),

  // AppBar theme (Jakob's Law)
  appBarTheme: AppBarTheme(
    backgroundColor: TColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    toolbarHeight: 56.0, // Standard height for familiarity
  ),

  // Text themes (Visual hierarchy)
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: TColors.textPrimary,
      height: 1.2, // Improved readability
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: TColors.textPrimary,
      height: 1.2,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: TColors.textPrimary,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: TColors.textPrimary,
      height: 1.5, // Improved readability
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: TColors.textPrimary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: TColors.textSecondary,
      height: 1.5,
    ),
  ),

  // Button themes (Fitts's Law)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: TColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      minimumSize:
          Size(AppDimensions.minTouchTarget, AppDimensions.minTouchTarget),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      ),
      elevation: 2, // Subtle shadow for depth
    ),
  ),

  // Text field theme (Fitts's Law + Aesthetic-Usability Effect)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      borderSide: BorderSide(color: TColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      borderSide: BorderSide(color: TColors.error),
    ),
    // Improved error styling
    errorStyle: TextStyle(
      color: TColors.error,
      fontSize: 12,
    ),
    // Helper text styling
    helperStyle: TextStyle(
      color: TColors.textSecondary,
      fontSize: 12,
    ),
  ),

  // Checkbox theme (Fitts's Law)
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary;
      }
      return Colors.transparent;
    }),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    side: BorderSide(color: Colors.grey.shade400),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  ),

  // Bottom navigation bar theme (Fitts's Law + Jakob's Law)
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: TColors.primary,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    unselectedLabelStyle: TextStyle(fontSize: 12),
    // Ensure adequate spacing
    landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
  ),

  // Implement Doherty Threshold with appropriate animations
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),

  // Snackbar theme (Law of Common Region + Aesthetic-Usability Effect)
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.grey.shade800,
    contentTextStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    actionTextColor: TColors.primary,
  ),
);
