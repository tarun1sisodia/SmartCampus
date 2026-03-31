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
        elevation: 2,
        shadowColor: brightness == Brightness.dark ? TColors.dark.withAlpha(128) : TColors.dark.withAlpha(77),
        foregroundColor: foregroundColor,
        backgroundColor: primaryColor,
        disabledBackgroundColor: brightness == Brightness.dark ? TColors.darkerGrey : TColors.grey,
        disabledForegroundColor: brightness == Brightness.dark ? TColors.grey : TColors.darkGrey,
        side: BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(
          vertical: TSizes.buttonHeight / 2,
          horizontal: TSizes.md,
        ),
        textStyle: TextStyle(
          fontSize: 16,
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
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

