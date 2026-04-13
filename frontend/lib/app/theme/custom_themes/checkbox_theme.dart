import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

//TCheckboxTheme implements:
//- Fitts's Law: Appropriate sizing for interactive elements
//- Aesthetic-Usability Effect: Clean, consistent checkbox design
//- Doherty Threshold: Clear visual feedback on interaction
class TCheckboxTheme {
  TCheckboxTheme._();

  static CheckboxThemeData createCheckboxTheme(Color primaryColor, Color checkColorValue, Brightness brightness) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.xs),
      ),
      checkColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return checkColorValue;
        } else {
          return brightness == Brightness.light ? TColors.dark : Colors.white;
        }
      }),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        } else if (states.contains(WidgetState.disabled)) {
          return brightness == Brightness.light ? TColors.grey : TColors.darkerGrey;
        } else {
          return Colors.transparent;
        }
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return primaryColor.withAlpha(26);
        } else if (states.contains(WidgetState.hovered)) {
          return primaryColor.withAlpha(13);
        } else {
          return Colors.transparent;
        }
      }),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      side: const BorderSide(
        color: TColors.grey,
        width: 1.5,
      ),
      splashRadius: 20,
    );
  }

  static final lightCheckBoxTheme = createCheckboxTheme(TColors.primary, TColors.white, Brightness.light);
  static final darkCheckBoxTheme = createCheckboxTheme(TColors.primary, TColors.white, Brightness.dark);
}

