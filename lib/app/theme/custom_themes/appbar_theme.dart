import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';

/// TAppbarTheme implements:
/// - Jakob's Law: Following standard AppBar conventions users expect
/// - Law of Similarity: Consistent styling between modes
/// - Fitts's Law: Appropriate sizing for interactive elements
class TAppbarTheme {
  TAppbarTheme._();

  // Light theme AppBar
  static final lightAppBarTheme = AppBarTheme(
    // Implementing Aesthetic-Usability Effect with clean design
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,

    // Implementing Fitts's Law with appropriate icon sizing
    iconTheme: IconThemeData(
      color: TColors.dark,
      size: 24,
      // Ensure touch targets are large enough
      opticalSize: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: TColors.dark,
      size: 24,
      opticalSize: 24,
    ),

    // Implementing Visual Hierarchy with clear title styling
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.dark,
      letterSpacing: 0.15, // Improved readability
    ),

    // Implementing Law of Proximity with consistent spacing
    toolbarHeight: 56.0, // Standard height
    titleSpacing: 16.0, // Consistent spacing
  );

  // Dark theme AppBar
  static final darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 24,
      opticalSize: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: Colors.white,
      size: 24,
      opticalSize: 24,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.15,
    ),
    toolbarHeight: 56.0,
    titleSpacing: 16.0,
  );
}
