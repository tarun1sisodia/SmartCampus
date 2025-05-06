import 'package:flutter/material.dart';

/// TColors implements:
/// - Aesthetic-Usability Effect: Pleasing, harmonious color palette
/// - Hick's Law: Limited color options to reduce decision complexity
/// - Law of Similarity: Consistent color application
/// - Visual Hierarchy: Clear distinction between primary/secondary colors
class TColors {
  TColors._();

  // PRIMARY COLOR PALETTE - Core brand colors (Hick's Law - limited choices)
  static const Color primary = Color(0xFF4B68FF);
  static const Color primaryDark = Color(0xFF3451E0);
  static const Color primaryLight = Color(0xFF6F85FF);

  // SECONDARY COLOR PALETTE - Complementary colors
  static const Color secondary = Color(0xFFFFE248);
  static const Color secondaryDark = Color(0xFFE6C800);
  static const Color secondaryLight = Color(0xFFFFF176);

  // ACCENT COLOR - For highlights and emphasis
  static const Color accent = Color(0xFFB0C7FF);

  // FUNCTIONAL COLORS - For specific UI purposes
  static const Color info = Color(0xFF2196F3);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);

  // GRADIENT DEFINITIONS - For dimensional effects
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFFAD0C4)],
  );

  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  // TEXT COLORS - For typography hierarchy
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textWhite = Colors.white;

  // BACKGROUND COLORS - For surfaces and containers
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static Color dark54 = Color(0xFF272727).withOpacity(0.54);
  static const Color primaryBackground = Color(0xFFF3F5FF);
  static const Color secondaryBackground = Color(0xFFFFFDE7);

  // CONTAINER COLORS - For cards, dialogs, etc.
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = TColors.white.withOpacity(0.1);

  // BUTTON COLORS - For interactive elements
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // BORDER COLORS - For dividers, separators, etc.
  static const Color borderPrimary = Color(0xFFDEE2E6);
  static const Color borderSecondary = Color(0xFFE9ECEF);

  // NEUTRAL SHADES - For UI elements
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);

  // SOCIAL COLORS - For social media integration
  static const Color facebook = Color(0xFF3B5998);
  static const Color google = Color(0xFFDB4437);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color linkedin = Color(0xFF0077B5);

  // ADDITIONAL BRAND COLORS - For variety and emphasis
  static const Color blue = Color(0xFF0061FF);
  static const Color lightBlue = Color(0xFF00A7FF);
  static const Color purple = Color(0xFF6B3FF7);
  static const Color pink = Color(0xFFFF4593);
  static const Color red = Color(0xFFFF4B4B);
  static const Color green = Color(0xFF2EC272);
  static const Color yellow = Color(0xFFFFD912);
  static const Color orange = Color(0xFFFF8C00);
  static const Color mint = Color(0xFF2BFFC6);
  static const Color indigo = Color(0xFF4B0082);

  // GRADIENT COLORS - For dimensional effects
  static const Gradient blueGradient = LinearGradient(
    colors: [Color(0xFF0061FF), Color(0xFF60EFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient purpleGradient = LinearGradient(
    colors: [Color(0xFF6B3FF7), Color(0xFFFF4593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // MATERIAL COLORS - For variety
  static const Color teal = Colors.teal;
  static const Color amber = Colors.amber;
  static const Color coral = Color(0xFFFF7F50);
  static const Color turquoise = Color(0xFF40E0D0);
  static const Color lavender = Color(0xFFE6E6FA);

  // SEMANTIC COLORS - For specific meanings
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color busy = Color(0xFFE53935);
  static const Color away = Color(0xFFFFC107);

  // DARK MODE SPECIFIC COLORS
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static Color darkElevated = Colors.white.withOpacity(0.05);
  static const Color backgroundLight = Color(0xFFF8F8F8); // Same as light
  static const Color backgroundDark = Color(0xFF121212); // Same as dark
}
