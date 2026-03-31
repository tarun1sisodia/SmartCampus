import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

//TSearchbarTheme implements:
//- Jakob's Law: Familiar search patterns
//- Fitts's Law: Appropriate sizing for interactive elements
//- Aesthetic-Usability Effect: Clean, consistent search design
class TSearchbarTheme {
  TSearchbarTheme._();

  static SearchBarThemeData createSearchBarTheme(Color backgroundColor, Color textColor, Color hintColor, Brightness brightness) {
    return SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0.5),
      backgroundColor: WidgetStatePropertyAll(backgroundColor),
      shadowColor: WidgetStatePropertyAll(brightness == Brightness.dark ? Colors.black.withAlpha(77) : Colors.black.withAlpha(25)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: TSizes.md)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(color: brightness == Brightness.dark ? TColors.darkGrey : TColors.grey.withAlpha(77)),
      )),
      textStyle: WidgetStatePropertyAll(TextStyle(
        color: textColor,
        fontSize: 14,
      )),
      hintStyle: WidgetStatePropertyAll(TextStyle(
        color: hintColor,
        fontSize: 14,
      )),
    );
  }

  static final lightSearchBar = createSearchBarTheme(Colors.white, TColors.textPrimary, TColors.darkGrey, Brightness.light);
  static final darkSearchBar = createSearchBarTheme(TColors.darkerGrey, TColors.white, TColors.white.withAlpha(179), Brightness.dark);
}

