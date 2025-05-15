import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

//ChipTheme implements:
// Fitts's Law: Appropriate sizing for interactive elements
// Aesthetic-Usability Effect: Clean, consistent chip design
// Law of Proximity: Consistent spacing
// Law of Similarity: Consistent styling
class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipThemeData = ChipThemeData(
    // Disabled state styling
    disabledColor: TColors.grey.withAlpha(102),

    // Selected state styling (Doherty Threshold - clear feedback)
    selectedColor: TColors.primary.withAlpha(51),
    secondarySelectedColor: TColors.primary.withAlpha(51),

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
      side: BorderSide(color: TColors.grey.withAlpha(77)),
    ),

    // Background color
    backgroundColor: TColors.white,

    // Shadow for depth perception
    elevation: 0,
    shadowColor: TColors.dark.withAlpha(26),
  );

  static ChipThemeData darkChipThemeData = ChipThemeData(
    disabledColor: TColors.darkerGrey,
    selectedColor: TColors.primary.withAlpha(102),
    secondarySelectedColor: TColors.primary.withAlpha(102),
    labelStyle: TextStyle(
      color: TColors.white,
      fontSize: 14,
    ),
    secondaryLabelStyle: TextStyle(
      color: TColors.primary.withAlpha(230),
      fontSize: 14,
    ),
    deleteIconColor: TColors.white.withAlpha(179),
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
    shadowColor: TColors.dark.withAlpha(13),
  );
}
