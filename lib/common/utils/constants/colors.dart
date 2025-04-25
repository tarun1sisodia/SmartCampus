import 'package:flutter/material.dart';

class TColors {
  TColors._() {
    //print('TColors initialized');
  }

  // App Basic Colors
  static const Color primary = Color(0xFF4B68FF);
  static const Color secondary = Color(0xFFFFE248);
  static const Color accent = Color(0xFFB0C7FF);
  // Add these if they don't already exist

  // Gradient Colors
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFFAD0C4)],
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Background Colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  // Background Container Colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = TColors.white.withAlpha(25);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF4B68FF);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and Validation Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);

  // Social Colors
  static const Color facebook = Color(0xFF3B5998);
  static const Color google = Color(0xFFDB4437);
  static const Color twitter = Color(0xFF1DA1F2);

  //icon colors

  static const Color deepPurple = Colors.deepPurple;
  // Add these new color variables inside the TColors class

  // Additional Brand Colors
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

  // Gradient Colors - Additional
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

  // Material Colors
  static const Color teal = Colors.teal;
  static const Color amber = Colors.amber;
  static const Color coral = Color(0xFFFF7F50);
  static const Color turquoise = Color(0xFF40E0D0);
  static const Color lavender = Color(0xFFE6E6FA);
}
