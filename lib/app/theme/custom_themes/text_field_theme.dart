import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

//TTextFieldTheme implements:
//- Fitts's Law: Appropriate sizing for interactive elements
//- Aesthetic-Usability Effect: Clean, consistent input design
//- Law of Proximity: Consistent spacing
//- Jakob's Law: Familiar input patterns
class TTextFieldTheme {
  TTextFieldTheme._();

  static InputDecorationTheme createInputDecorationTheme(Color primaryColor, Color surfaceColor, Color textColor, Color errorColor, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final hintColor = isDark ? Colors.white.withAlpha(179) : TColors.darkGrey;
    final iconColor = isDark ? Colors.grey : TColors.darkGrey;

    return InputDecorationTheme(
      errorMaxLines: 3,
      prefixIconColor: iconColor,
      suffixIconColor: iconColor,
      labelStyle: TextStyle(
        fontSize: 14,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: hintColor,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      errorStyle: TextStyle(
        fontStyle: FontStyle.normal,
        color: errorColor,
        fontSize: 12,
      ),
      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TSizes.md,
        vertical: TSizes.md - 2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: const BorderSide(width: 1, color: TColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: const BorderSide(width: 1, color: TColors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: BorderSide(width: 1.5, color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: BorderSide(width: 1, color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: BorderSide(width: 2, color: errorColor),
      ),
      filled: true,
      fillColor: surfaceColor,
    );
  }

  static final lightInputDecoration = createInputDecorationTheme(TColors.primary, TColors.white, TColors.textPrimary, TColors.error, Brightness.light);
  static final darkInputDecoration = createInputDecorationTheme(TColors.primary, TColors.darkerGrey, TColors.white, TColors.error, Brightness.dark);
}

