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

  static ChipThemeData createChipTheme(Color primaryColor, Color backgroundColor, Color textColor, Brightness brightness) {
    return ChipThemeData(
      disabledColor: brightness == Brightness.dark ? TColors.darkerGrey : TColors.grey.withAlpha(102),
      selectedColor: primaryColor.withAlpha(brightness == Brightness.dark ? 102 : 51),
      secondarySelectedColor: primaryColor.withAlpha(brightness == Brightness.dark ? 102 : 51),
      labelStyle: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
      secondaryLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: 14,
      ),
      deleteIconColor: brightness == Brightness.dark ? TColors.white.withAlpha(179) : TColors.darkGrey,
      checkmarkColor: brightness == Brightness.dark ? Colors.white : primaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.sm,
        vertical: TSizes.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
        side: BorderSide(color: brightness == Brightness.dark ? TColors.darkGrey : TColors.grey.withAlpha(77)),
      ),
      backgroundColor: backgroundColor,
      elevation: 0,
      shadowColor: TColors.dark.withAlpha(brightness == Brightness.dark ? 13 : 26),
    );
  }

  static final lightChipThemeData = createChipTheme(TColors.primary, TColors.white, TColors.textPrimary, Brightness.light);
  static final darkChipThemeData = createChipTheme(TColors.primary, TColors.darkerGrey, TColors.white, Brightness.dark);
}

