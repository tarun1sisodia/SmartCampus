import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

/// TCardTheme implements:
/// - Law of Common Region: Cards create visual boundaries around related content
/// - Aesthetic-Usability Effect: Clean, consistent card design
/// - Law of Proximity: Consistent internal spacing
class TCardTheme {
  TCardTheme._();

  // Light theme card
  static final CardTheme lightCardTheme = CardTheme(
    color: TColors.white,
    shadowColor: TColors.dark.withOpacity(0.1),
    elevation: 2,

    // Consistent corner radius (Aesthetic-Usability Effect)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
    ),

    // Consistent spacing (Law of Proximity)
    margin: EdgeInsets.all(TSizes.sm),

    // Subtle border for definition
    clipBehavior: Clip.antiAlias,
  );

  // Dark theme card
  static final CardTheme darkCardTheme = CardTheme(
    color: TColors.darkerGrey,
    shadowColor: Colors.black.withOpacity(0.3),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
    ),
    margin: EdgeInsets.all(TSizes.sm),
    clipBehavior: Clip.antiAlias,
  );
}
