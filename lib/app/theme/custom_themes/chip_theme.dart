import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

/// TChipTheme implements:
/// - Fitts's Law: Appropriate sizing for interactive elements
/// - Aesthetic-Usability Effect: Clean, consistent chip design
/// - Law of Proximity: Consistent spacing
/// - Law of Similarity: Consistent styling
class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipThemeData = ChipThemeData(
    // Disabled state styling
    disabledColor: TColors.grey.withOpacity(0.4),

    // Selected state styling (Doherty Threshold - clear feedback)
    selectedColor: TColors.primary.withOpacity(0.2),
    secondarySelectedColor: TColors.primary.withOpacity(0.2),

    // Text styling
    labelStyle: TextStyle(
      color: TColors.textPrimary,
      fontSize: 14,
    ),
    secondaryLabelStyle: TextStyle(
      color: TColors.primary,
      fontSize: 14,
    ),

    // Icon styling
    deleteIconColor: TColors.darkGrey,
    checkmarkColor: TColors.primary,

    // Consistent padding (Law of Proximity)
    padding: EdgeInsets.symmetric(
      horizontal: TSizes.sm,
      vertical: TSizes.xs,
    ),

    // Shape and border
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
      side: BorderSide(color: TColors.grey.withOpacity(0.3)),
    ),

    // Background color
    backgroundColor: TColors.white,

    // Shadow for depth perception
    elevation: 0,
    shadowColor: TColors.dark.withOpacity(0.1),
  );

  static ChipThemeData darkChipThemeData = ChipThemeData(
    disabledColor: TColors.darkerGrey,
    selectedColor: TColors.primary.withOpacity(0.4),
    secondarySelectedColor: TColors.primary.withOpacity(0.4),
    labelStyle: TextStyle(
      color: TColors.white,
      fontSize: 14,
    ),
    secondaryLabelStyle: TextStyle(
      color: TColors.primary.withOpacity(0.9),
      fontSize: 14,
    ),
    deleteIconColor: TColors.white.withOpacity(0.7),
    checkmarkColor: TColors.white,
    padding: EdgeInsets.symmetric(
      horizontal: TSizes.sm,
      vertical: TSizes.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
      side: BorderSide(color: TColors.darkGrey),
    ),
    backgroundColor: TColors.darkerGrey,
    elevation: 0,
    shadowColor: TColors.dark.withOpacity(0.2),
  );
}
