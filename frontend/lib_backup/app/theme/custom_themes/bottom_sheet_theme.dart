import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

// TBottomSheetTheme implements:
// - Law of Common Region: Creates visual boundaries around related content
// - Aesthetic-Usability Effect: Clean, consistent design
// - Law of Proximity: Consistent spacing
// - Jakob's Law: Familiar bottom sheet patterns
class TBottomSheetTheme {
  TBottomSheetTheme._();

  static BottomSheetThemeData createBottomSheetTheme(Color surfaceColor, Brightness brightness) {
    return BottomSheetThemeData(
      showDragHandle: true,
      dragHandleColor: TColors.grey,
      dragHandleSize: const Size(40, 4),
      backgroundColor: surfaceColor,
      modalBackgroundColor: surfaceColor,
      shadowColor: brightness == Brightness.dark ? Colors.black.withAlpha(128) : TColors.dark.withAlpha(26),
      elevation: 5,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 100,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  static final lightBottomSheetTheme = createBottomSheetTheme(TColors.white, Brightness.light);
  static final darkBottomSheetTheme = createBottomSheetTheme(TColors.dark, Brightness.dark);
}

