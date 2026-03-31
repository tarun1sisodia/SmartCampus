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

    return InputDecorationTheme(
      errorMaxLines: 3,
      prefixIconColor: primaryColor,
      suffixIconColor: primaryColor,
      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.w900,
        fontSize: 12,
      ),
      labelStyle: TextStyle(
        fontSize: 14,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: textColor.withAlpha(128),
        fontWeight: FontWeight.w500,
      ),
      errorStyle: const TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.w700),
      isCollapsed: false,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      filled: false, // No filled, borderless inputs
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: const BorderSide(width: 1.5, color: TColors.slate400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: const BorderSide(width: 1.5, color: TColors.slate400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: BorderSide(width: 1.5, color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: const BorderSide(width: 1.5, color: TColors.rose500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: const BorderSide(width: 2.0, color: TColors.rose500),
      ),
    );
  }

  static final lightInputDecoration = createInputDecorationTheme(TColors.primary, TColors.white, TColors.textPrimary, TColors.error, Brightness.light);
  static final darkInputDecoration = createInputDecorationTheme(TColors.primary, TColors.darkerGrey, TColors.white, TColors.error, Brightness.dark);
}

