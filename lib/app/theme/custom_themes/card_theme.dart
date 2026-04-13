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
      elevation: 0, // No shadows
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(
          color: brightness == Brightness.dark ? Color(0xFF334155) : Color(0xFF94A3B8),
          width: TSizes.cardBorderWidth,
        ),
      ),
      margin: const EdgeInsets.all(TSizes.sm),
      clipBehavior: Clip.antiAlias,
    );
  }

  static final lightCardTheme = createCardTheme(TColors.lightContainerHighlight, Brightness.light);
  static final darkCardTheme = createCardTheme(TColors.darkSurface, Brightness.dark);
}
