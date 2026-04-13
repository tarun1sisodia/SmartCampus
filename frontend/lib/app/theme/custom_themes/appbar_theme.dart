import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';

// TAppbarTheme implements:
// - Jakob's Law: Following standard AppBar conventions users expect
// - Law of Similarity: Consistent styling between modes
// - Fitts's Law: Appropriate sizing for interactive elements
class TAppbarTheme {
  TAppbarTheme._();

  static AppBarTheme createAppBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : TColors.dark;

    return AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: iconColor,
        size: 24,
        opticalSize: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: iconColor,
        size: 24,
        opticalSize: 24,
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: iconColor,
        letterSpacing: -0.5,
      ),
      toolbarHeight: 56.0,
      titleSpacing: 16.0,
    );
  }

  static final lightAppBarTheme = createAppBarTheme(Brightness.light);
  static final darkAppBarTheme = createAppBarTheme(Brightness.dark);
}

