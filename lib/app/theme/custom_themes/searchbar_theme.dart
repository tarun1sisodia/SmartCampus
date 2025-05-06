import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

/// TSearchbarTheme implements:
/// - Jakob's Law: Familiar search patterns
/// - Fitts's Law: Appropriate sizing for interactive elements
/// - Aesthetic-Usability Effect: Clean, consistent search design
class TSearchbarTheme {
  TSearchbarTheme._();
  
  static final lightSearchBar = SearchBarThemeData(
    // Subtle elevation for depth perception
    elevation: WidgetStatePropertyAll(0.5),
    
    // Consistent background color (Aesthetic-Usability Effect)
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    
    // Shadow color for depth
    shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.1)),
    
    // Appropriate sizing (Fitts's Law)
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: TSizes.md)
    ),
    
    // Consistent shape (Law of Similarity)
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(color: TColors.grey.withOpacity(0.3)),
      )
    ),
    
    // Text styling
    textStyle: WidgetStatePropertyAll(
      TextStyle(
        color: TColors.textPrimary,
        fontSize: 14,
      )
    ),
    
    // Hint styling
    hintStyle: WidgetStatePropertyAll(
      TextStyle(
        color: TColors.darkGrey,
        fontSize: 14,
      )
    ),
  );
  
  static final darkSearchBar = SearchBarThemeData(
    elevation: WidgetStatePropertyAll(1),
    backgroundColor: WidgetStatePropertyAll(TColors.darkerGrey),
    shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.3)),
    
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: TSizes.md)
    ),
    
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(color: TColors.darkGrey),
      )
    ),
    
    textStyle: WidgetStatePropertyAll(
      TextStyle(
        color: TColors.white,
        fontSize: 14,
      )
    ),
    
    hintStyle: WidgetStatePropertyAll(
      TextStyle(
        color: TColors.white.withOpacity(0.7),
        fontSize: 14,
      )
    ),
  );
}
