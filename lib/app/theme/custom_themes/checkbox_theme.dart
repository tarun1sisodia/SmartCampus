import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

/// TCheckboxTheme implements:
/// - Fitts's Law: Appropriate sizing for interactive elements
/// - Aesthetic-Usability Effect: Clean, consistent checkbox design
/// - Doherty Threshold: Clear visual feedback on interaction
class TCheckboxTheme {
  TCheckboxTheme._();

  static CheckboxThemeData lightCheckBoxTheme = CheckboxThemeData(
    // Consistent shape (Law of Similarity)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.xs),
    ),

    // Clear visual feedback (Doherty Threshold)
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.white;
      } else {
        return TColors.dark;
      }
    }),

    // Fill color based on state
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary;
      } else if (states.contains(WidgetState.disabled)) {
        return TColors.grey;
      } else {
        return Colors.transparent;
      }
    }),

    // Border color based on state
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return TColors.primary.withOpacity(0.1);
      } else if (states.contains(WidgetState.hovered)) {
        return TColors.primary.withOpacity(0.05);
      } else {
        return Colors.transparent;
      }
    }),

    // Appropriate sizing (Fitts's Law)
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // Border styling
    side: BorderSide(
      color: TColors.grey,
      width: 1.5,
    ),

    // Subtle splash effect
    splashRadius: 20,
  );

  static CheckboxThemeData darkCheckBoxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.xs),
    ),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.white;
      } else {
        return TColors.white;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary;
      } else if (states.contains(WidgetState.disabled)) {
        return TColors.darkerGrey;
      } else {
        return Colors.transparent;
      }
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return TColors.primary.withOpacity(0.1);
      } else if (states.contains(WidgetState.hovered)) {
        return TColors.primary.withOpacity(0.05);
      } else {
        return Colors.transparent;
      }
    }),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    side: BorderSide(
      color: TColors.grey,
      width: 1.5,
    ),
    splashRadius: 20,
  );
}
