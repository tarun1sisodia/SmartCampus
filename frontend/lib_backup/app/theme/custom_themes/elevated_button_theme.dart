import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

//TElevatedButtonTheme implements:
//- Fitts's Law: Appropriate sizing for interactive elements
//- Aesthetic-Usability Effect: Clean, consistent button design
//- Law of Proximity: Consistent spacing
//- Doherty Threshold: Clear visual feedback on interaction
class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static ElevatedButtonThemeData createElevatedButtonTheme(Color primaryColor, Color foregroundColor, Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: foregroundColor,
        backgroundColor: primaryColor,
        disabledBackgroundColor: brightness == Brightness.dark ? TColors.slate800 : TColors.slate400,
        disabledForegroundColor: brightness == Brightness.dark ? TColors.slate400 : TColors.slate600,
        side: BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 24,
        ),
        textStyle: TextStyle(
          fontSize: 14,
          color: foregroundColor,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.buttonRadius),
        ),
        minimumSize: const Size(TSizes.buttonWidth, TSizes.buttonHeight),
      ),
    );
  }

  static final lightElevatedButton = createElevatedButtonTheme(TColors.primary, TColors.white, Brightness.light);
  static final darkElevatedButton = createElevatedButtonTheme(TColors.primary, TColors.white, Brightness.dark);
}

