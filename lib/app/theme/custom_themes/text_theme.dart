import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';

/// TtextTheme implements:
/// - Visual Hierarchy: Clear distinction between text styles
/// - Law of Similarity: Consistent text styling
/// - Aesthetic-Usability Effect: Readable, pleasing typography
class TtextTheme {
  TtextTheme._();

  static TextTheme lighttextTheme = TextTheme(
    // Display styles for large headers
    displayLarge: TextStyle().copyWith(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: TColors.textPrimary,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    
    // Headline styles for section headers
    headlineLarge: TextStyle().copyWith(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: TColors.textPrimary,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    headlineMedium: TextStyle().copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    headlineSmall: TextStyle().copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
      letterSpacing: 0,
      height: 1.4,
    ),
    
    // Title styles for card titles, dialogs, etc.
    titleLarge: TextStyle().copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleMedium: TextStyle().copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: TColors.textPrimary,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleSmall: TextStyle().copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: TColors.textPrimary,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    
    // Body styles for main content
    bodyLarge: TextStyle().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: TColors.textPrimary,
      letterSpacing: 0.25,
      height: 1.5, // Improved readability
    ),
    bodyMedium: TextStyle().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: TColors.textPrimary,
      letterSpacing: 0.25,
      height: 1.5,
    ),
    bodySmall: TextStyle().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: TColors.textSecondary, // Secondary color for less emphasis
      letterSpacing: 0.25,
      height: 1.5,
    ),
    
    // Label styles for buttons, fields, etc.
    labelLarge: TextStyle().copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: TColors.textPrimary,
      letterSpacing: 0.5,
      height: 1.4,
    ),
    labelMedium: TextStyle().copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: TColors.textPrimary,
      letterSpacing: 0.5,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 12, 
      color: TColors.textPrimary,
      letterSpacing: 0.5,
      height: 1.4,
    ),
  );

  static TextTheme darktextTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle().copyWith(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: TColors.white,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    
    // Headline styles
    headlineLarge: TextStyle().copyWith(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: TColors.white,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    headlineMedium: TextStyle().copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: TColors.white,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    headlineSmall: TextStyle().copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TColors.white,
      letterSpacing: 0,
      height: 1.4,
    ),
    
    // Title styles
    titleLarge: TextStyle().copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TColors.white,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleMedium: TextStyle().copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: TColors.white,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleSmall: TextStyle().copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: TColors.white,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    
    // Body styles
    bodyLarge: TextStyle().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: TColors.white,
      letterSpacing: 0.25,
      height: 1.5,
    ),
    bodyMedium: TextStyle().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: TColors.white,
      letterSpacing: 0.25,
      height: 1.5,
    ),
    bodySmall: TextStyle().copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: TColors.white.withOpacity(0.8), // Slightly dimmed for hierarchy
      letterSpacing: 0.25,
      height: 1.5,
    ),
    
    // Label styles
    labelLarge: TextStyle().copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: TColors.white,
      letterSpacing: 0.5,
      height: 1.4,
    ),
    labelMedium: TextStyle().copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: TColors.white,
      letterSpacing: 0.5,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 12, 
      color: TColors.white,
      letterSpacing: 0.5,
      height: 1.4,
    ),
  );
}
