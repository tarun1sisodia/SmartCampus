import 'package:flutter/material.dart';
import '../common/utils/constants/colors.dart';
import '../common/utils/constants/sized.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: TColors.primary,
      colorScheme: const ColorScheme.light(
        primary: TColors.primary,
        secondary: TColors.secondary,
        surface: TColors.slate50,
        error: TColors.error,
      ),
      scaffoldBackgroundColor: TColors.slate50,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: TColors.slate900),
        titleTextStyle: TextStyle(color: TColors.slate900, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: TColors.slate400, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Colors.white, width: 1.5),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: TColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: TColors.primary,
        secondary: TColors.secondary,
        surface: TColors.slate950,
        error: TColors.error,
      ),
      scaffoldBackgroundColor: TColors.slate950,
      appBarTheme: const AppBarTheme(
        backgroundColor: TColors.slate950,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: TColors.slate50, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: TColors.slate900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: TColors.slate700, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
      ),
    );
  }
}
