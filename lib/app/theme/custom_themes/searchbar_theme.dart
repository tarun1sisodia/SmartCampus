import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

//TSearchbarTheme implements:
//- Jakob's Law: Familiar search patterns
//- Fitts's Law: Appropriate sizing for interactive elements
//- Aesthetic-Usability Effect: Clean, consistent search design
class TSearchbarTheme {
  TSearchbarTheme._();

  static final lightSearchBar = SearchBarThemeData(
    // Subtle elevation for depth perception
    elevation: WidgetStatePropertyAll(0.5),

    // Consistent background color (Aesthetic-Usability Effect)
    backgroundColor: WidgetStatePropertyAll(Colors.white),

    // Shadow color for depth
    shadowColor: WidgetStatePropertyAll(Colors.black.withAlpha(25)),

    // Appropriate sizing (Fitts's Law)
    padding:
        WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: TSizes.md)),

    // Consistent shape (Law of Similarity)
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      side: BorderSide(color: TColors.grey.withAlpha(77)),
    )),

    // Text styling
    textStyle: WidgetStatePropertyAll(TextStyle(
      color: TColors.textPrimary,
      fontSize: 14,
    )),

    // Hint styling
    hintStyle: WidgetStatePropertyAll(TextStyle(
      color: TColors.darkGrey,
      fontSize: 14,
    )),
  );

  static final darkSearchBar = SearchBarThemeData(
    elevation: WidgetStatePropertyAll(1),
    backgroundColor: WidgetStatePropertyAll(TColors.darkerGrey),
    shadowColor: WidgetStatePropertyAll(Colors.black.withAlpha(77)),
    padding:
        WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: TSizes.md)),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      side: BorderSide(color: TColors.darkGrey),
    )),
    textStyle: WidgetStatePropertyAll(TextStyle(
      color: TColors.white,
      fontSize: 14,
    )),
    hintStyle: WidgetStatePropertyAll(TextStyle(
      color: TColors.white.withAlpha(179),
      fontSize: 14,
    )),
  );
}
