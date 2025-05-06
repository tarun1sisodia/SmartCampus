import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

/// TTextFieldTheme implements:
/// - Fitts's Law: Appropriate sizing for interactive elements
/// - Aesthetic-Usability Effect: Clean, consistent input design
/// - Law of Proximity: Consistent spacing
/// - Jakob's Law: Familiar input patterns
class TTextFieldTheme {
  TTextFieldTheme._();

  static InputDecorationTheme lightInputDecoration = InputDecorationTheme(
    // Improved error handling (Aesthetic-Usability Effect)
    errorMaxLines: 3,

    // Consistent icon styling (Law of Similarity)
    prefixIconColor: TColors.darkGrey,
    suffixIconColor: TColors.darkGrey,

    // Clear text styling (Visual Hierarchy)
    labelStyle: TextStyle().copyWith(
      fontSize: 14,
      color: TColors.textPrimary,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle().copyWith(
      color: TColors.darkGrey,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    errorStyle: TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: TColors.error,
      fontSize: 12,
    ),
    floatingLabelStyle: TextStyle().copyWith(
      color: TColors.primary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),

    // Consistent spacing (Law of Proximity)
    contentPadding: EdgeInsets.symmetric(
      horizontal: TSizes.md,
      vertical: TSizes.md - 2,
    ),

    // Consistent border styling (Aesthetic-Usability Effect)
    border: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: TColors.grey),
    ),
    enabledBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: TColors.grey),
    ),
    focusedBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1.5, color: TColors.primary),
    ),
    errorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: TColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 2, color: TColors.error),
    ),

    // Subtle fill color for better visibility
    filled: true,
    fillColor: TColors.white,
  );

  static InputDecorationTheme darkInputDecoration = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: TColors.grey,
    suffixIconColor: TColors.grey,
    labelStyle: TextStyle().copyWith(
      fontSize: 14,
      color: TColors.white,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle().copyWith(
      fontSize: 14,
      color: TColors.white.withAlpha(179), // 0.7 * 255 = 179
      fontWeight: FontWeight.normal,
    ),
    errorStyle: TextStyle().copyWith(
      fontWeight: FontWeight.normal,
      color: TColors.error.withAlpha(230), // 0.9 * 255 = 230
      fontSize: 12,
    ),
    floatingLabelStyle: TextStyle().copyWith(
      color: TColors.primary.withAlpha(230), // 0.9 * 255 = 230
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),

    // Consistent spacing (Law of Proximity)
    contentPadding: EdgeInsets.symmetric(
      horizontal: TSizes.md,
      vertical: TSizes.md - 2,
    ),

    // Dark theme border styling
    border: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: TColors.darkGrey),
    ),
    enabledBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: TColors.grey),
    ),
    focusedBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1.5, color: TColors.primary),
    ),
    errorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 1, color: TColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
      borderSide: BorderSide(width: 2, color: TColors.error),
    ),

    // Subtle fill color for better visibility in dark mode
    filled: true,
    fillColor: TColors.darkerGrey,
  );
}
