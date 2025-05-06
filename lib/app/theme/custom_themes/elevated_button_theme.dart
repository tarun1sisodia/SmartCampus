import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

/// TElevatedButtonTheme implements:
/// - Fitts's Law: Appropriate sizing for interactive elements
/// - Aesthetic-Usability Effect: Clean, consistent button design
/// - Law of Proximity: Consistent spacing
/// - Doherty Threshold: Clear visual feedback on interaction
class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static final lightElevatedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      // Subtle elevation for depth perception
      elevation: 2,
      shadowColor: TColors.dark.withOpacity(0.3),

      // Clear color contrast (Aesthetic-Usability Effect)
      foregroundColor: TColors.white,
      backgroundColor: TColors.primary,

      // Disabled state styling
      disabledBackgroundColor: TColors.grey,
      disabledForegroundColor: TColors.darkGrey,

      // Subtle border for definition
      side: BorderSide(color: TColors.primary),

      // Consistent padding (Law of Proximity)
      padding: EdgeInsets.symmetric(
        vertical: TSizes.buttonHeight / 2,
        horizontal: TSizes.md,
      ),

      // Clear text styling
      textStyle: TextStyle(
        fontSize: 16,
        color: TColors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),

      // Consistent shape (Law of Similarity)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),

      // Minimum size for touch targets (Fitts's Law)
      minimumSize: Size(TSizes.buttonWidth, TSizes.buttonHeight),
    ),
  );

  static final darkElevatedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      shadowColor: TColors.dark.withOpacity(0.5),
      foregroundColor: TColors.white,
      backgroundColor: TColors.primary,
      disabledForegroundColor: TColors.grey,
      disabledBackgroundColor: TColors.darkerGrey,
      side: BorderSide(color: TColors.primary),
      padding: EdgeInsets.symmetric(
        vertical: TSizes.buttonHeight / 2,
        horizontal: TSizes.md,
      ),
      textStyle: TextStyle(
        fontSize: 16,
        color: TColors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),
      minimumSize: Size(TSizes.buttonWidth, TSizes.buttonHeight),
    ),
  );
}
