import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';

// TtextTheme implements:
// - Visual Hierarchy: Clear distinction between text styles
// - Law of Similarity: Consistent text styling
// - Aesthetic-Usability Effect: Readable, pleasing typography
class TtextTheme {
  TtextTheme._();

  static TextTheme createTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
        letterSpacing: -0.5,
        height: 1.1,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
        letterSpacing: -0.25,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
        letterSpacing: -0.25,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: secondaryTextColor,
        letterSpacing: 1.0,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0.25,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0.25,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryTextColor,
        letterSpacing: 0.25,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
        letterSpacing: 0.5,
        height: 1.2,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
        letterSpacing: 0.5,
        height: 1.2,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: secondaryTextColor,
        letterSpacing: 0.5,
        height: 1.2,
      ),
    );
  }

  static final lighttextTheme = createTextTheme(TColors.textPrimary, TColors.textSecondary);
  static final darktextTheme = createTextTheme(TColors.white, TColors.white.withAlpha(204));
}
