import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';

/// TBottomSheetTheme implements:
/// - Law of Common Region: Creates visual boundaries around related content
/// - Aesthetic-Usability Effect: Clean, consistent design
/// - Law of Proximity: Consistent spacing
/// - Jakob's Law: Familiar bottom sheet patterns
class TBottomSheetTheme {
  TBottomSheetTheme._();

  static BottomSheetThemeData lightBottomSheetTheme = BottomSheetThemeData(
    // Show drag handle for better usability (Jakob's Law)
    showDragHandle: true,
    dragHandleColor: TColors.grey,
    dragHandleSize: Size(40, 4),

    // Background styling
    backgroundColor: TColors.white,
    modalBackgroundColor: TColors.white,

    // Shadow for depth perception
    shadowColor: TColors.dark.withOpacity(0.1),
    elevation: 5,

    // Constraints for consistent sizing
    constraints: BoxConstraints(
      minWidth: double.infinity,
      minHeight: 100,
    ),

    // Consistent shape (Law of Similarity)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(TSizes.cardRadiusLg),
      ),
    ),

    // Clip behavior for rounded corners
    clipBehavior: Clip.antiAlias,
  );

  static BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    dragHandleColor: TColors.grey,
    dragHandleSize: Size(40, 4),
    backgroundColor: TColors.dark,
    modalBackgroundColor: TColors.dark,
    shadowColor: Colors.black.withOpacity(0.5),
    elevation: 5,
    constraints: BoxConstraints(
      minWidth: double.infinity,
      minHeight: 100,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(TSizes.cardRadiusLg),
      ),
    ),
    clipBehavior: Clip.antiAlias,
  );
}
