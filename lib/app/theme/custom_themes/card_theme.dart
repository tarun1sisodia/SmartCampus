import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

// TCardTheme implements:
// - Law of Common Region: Cards create visual boundaries around related content
// - Aesthetic-Usability Effect: Clean, consistent card design
// - Law of Proximity: Consistent internal spacing
class TCardTheme {
  TCardTheme._();

  static CardThemeData createCardTheme(Color surfaceColor, Brightness brightness) {
    return CardThemeData(
      color: surfaceColor,
      shadowColor: brightness == Brightness.dark ? Colors.black.withAlpha(77) : TColors.dark.withAlpha(26),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      margin: const EdgeInsets.all(TSizes.sm),
      clipBehavior: Clip.antiAlias,
    );
  }

  static final lightCardTheme = createCardTheme(TColors.lightContainerHighlight, Brightness.light);
  static final darkCardTheme = createCardTheme(TColors.darkSurface, Brightness.dark);
}
