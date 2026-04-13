import 'package:flutter/material.dart';

//colors implements:
//Aesthetic-Usability Effect: Pleasing, harmonious color palette
//Hick's Law: Limited color options to reduce decision complexity
//Law of Similarity: Consistent color application
//Visual Hierarchy: Clear distinction between primary/secondary colors
class TColors {
  TColors._();

  // CORPORATE COLOR PALETTE - Sharp, Bold & High Contrast
  static const Color executiveNavy = Color(0xFF1E3A8A); // blue-900
  static const Color deepOceanCyan = Color(0xFF22D3EE); // cyan-400
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  static const Color slate1000 = Color(0xFF020617);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color rose500 = Color(0xFFF43F5E); // Danger action
  static const Color cyan400 = Color(0xFF22D3EE);

  // PRIMARY COLOR PALETTE - Core brand colors
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // SECONDARY COLOR PALETTE - Complementary colors
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryDark = Color(0xFF4F46E5);
  static const Color secondaryLight = Color(0xFFA5B4FC);

  // ACCENT COLOR - For highlights and emphasis
  static const Color accent = deepOceanCyan;

  // FUNCTIONAL COLORS - For specific UI purposes
  static const Color info = blue100;
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = rose500;

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
  static const Color textPrimary = slate900;
  static const Color textSecondary = slate600;
  static const Color textTertiary = slate400;
  static const Color textWhite = slate50;

  // BACKGROUND COLORS - For surfaces and containers
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static Color dark54 = Color(0xFF272727).withAlpha(138);
  static const Color primaryBackground = Color(0xFFF3F5FF);
  static const Color secondaryBackground = Color(0xFFFFFDE7);

  // CONTAINER COLORS - For cards, dialogs, etc.
  static const Color lightContainer = Color(0xFFF6F6F6);
  static const Color lightContainerHighlight = Color(0xFFF8F8F8);
  static Color darkContainer = TColors.white.withAlpha(26);

  // BUTTON COLORS - For interactive elements
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // BORDER COLORS - For dividers, separators, etc.
  static const Color borderPrimary = slate400;
  static const Color borderSecondary = slate700;

  // NEUTRAL SHADES - For UI elements
  static const Color black = slate950;
  static const Color darkerGrey = slate900;
  static const Color darkGrey = slate700;
  static const Color grey = slate400;
  static const Color softGrey = slate50;
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color white = Colors.white;

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

  // CARD GRADIENTS - For card backgrounds
  static const Gradient cardGradient1 = LinearGradient(
    colors: [Color(0xFFFEAC5E), Color(0xFFC779D0), Color(0xFF4BC0C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradient2 = LinearGradient(
    colors: [Color(0xFF43C6AC), Color(0xFFF8FFAE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient cardGradient3 = LinearGradient(
    colors: [Color(0xFF30E8BF), Color(0xFFFF8235)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradient4 = LinearGradient(
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradient5 = LinearGradient(
    colors: [Color(0xFFDA4453), Color(0xFF89216B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // UX-OPTIMIZED GRADIENTS - For light and dark mode harmony
  static const Gradient uxGradient1 = LinearGradient(
    colors: [Color(0xFF4B68FF), Color(0xFF6F85FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient uxGradient2 = LinearGradient(
    colors: [Color(0xFFFFE248), Color(0xFFFFF176)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient uxGradient3 = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient uxGradient4 = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFFF6F61)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient uxGradient5 = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient uxGradient6 = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFFE082)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient uxGradient7 = LinearGradient(
    colors: [Color(0xFF6B3FF7), Color(0xFF9C67FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient uxGradient8 = LinearGradient(
    colors: [Color(0xFF2EC272), Color(0xFF66E6A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient uxGradient9 = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient uxGradient10 = LinearGradient(
    colors: [Color(0xFF4B0082), Color(0xFF8A2BE2)],
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
  static Color darkElevated = Colors.white.withAlpha(13);
  static const Color backgroundLight = Color(0xFFF8F8F8); // Same as light
  static const Color backgroundDark = Color(0xFF121212); // Same as dark
}
