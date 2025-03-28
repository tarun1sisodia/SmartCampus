import 'package:flutter/material.dart';
import '../../../models/student_model.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/device/device_utility.dart';
import '../../../common/utils/helpers/helper_function.dart';
// Make sure this import is correct
import '../../../common/utils/constants/screen_size_calculator.dart';

class SwipeableStudentCard extends StatelessWidget {
  final StudentModel student;
  final Function(String) onStatusChanged;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const SwipeableStudentCard({
    super.key,
    required this.student,
    required this.onStatusChanged,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    // Use MediaQuery directly to avoid potential class reference issues
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width < 1024 && screenSize.width > 500;
    final isMobile = screenSize.width <= 500;
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);

    // Calculate responsive sizes
    final avatarSize =
        isTablet ? (isLandscape ? 50.0 : 70.0) : (isLandscape ? 40.0 : 60.0);

    final cardPadding =
        isMobile
            ? (isLandscape ? TSizes.sm : TSizes.md)
            : (isLandscape ? TSizes.md : TSizes.lg);

    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swiped right - mark as present
          onStatusChanged('present');
          onSwipeRight();
        } else if (details.primaryVelocity! < 0) {
          // Swiped left - mark as absent
          onStatusChanged('absent');
          onSwipeLeft();
        }
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          side: BorderSide(
            color: _getStatusColor(student.attendanceStatus, dark),
            width: 2,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          // Use LayoutBuilder to get constraints of the card
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available height for content
              final availableHeight = constraints.maxHeight;
              final isCompactHeight = availableHeight < 300;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status indicator at the top
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? TSizes.sm : TSizes.md,
                      vertical: isMobile ? TSizes.xs / 2 : TSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(student.attendanceStatus, dark),
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                    ),
                    child: Text(
                      _getStatusText(student.attendanceStatus),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: isCompactHeight ? TSizes.xs : TSizes.spaceBtwItems,
                  ),

                  // Student avatar - responsive size
                  CircleAvatar(
                    radius: avatarSize,
                    backgroundColor: _getStatusColor(
                      student.attendanceStatus,
                      dark,
                    ).withOpacity(0.2),
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name.substring(0, 1)
                          : "?",
                      style: TextStyle(
                        fontSize: avatarSize * 0.8,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(student.attendanceStatus, dark),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: isCompactHeight ? TSizes.xs : TSizes.spaceBtwItems,
                  ),

                  // Student name - responsive font size
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          isCompactHeight
                              ? 16 * textScaleFactor
                              : (isMobile ? 18 : 22) * textScaleFactor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(
                    height:
                        isCompactHeight
                            ? TSizes.xs / 2
                            : TSizes.spaceBtwItems / 2,
                  ),

                  // Roll number - responsive font size
                  Text(
                    'Roll Number: ${student.rollNumber}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize:
                          isCompactHeight
                              ? 12 * textScaleFactor
                              : (isMobile ? 14 : 16) * textScaleFactor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Only show swipe instructions if there's enough space
                  if (!isCompactHeight) ...[
                    SizedBox(
                      height: isLandscape ? TSizes.sm : TSizes.spaceBtwSections,
                    ),

                    // Swipe instructions - responsive layout
                    isLandscape
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swipe_left,
                              color: Colors.red.withOpacity(0.7),
                              size: isMobile ? 16 : 20,
                            ),
                            SizedBox(width: TSizes.xs),
                            Flexible(
                              child: Text(
                                'Swipe for attendance',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: TSizes.xs),
                            Icon(
                              Icons.swipe_right,
                              color: Colors.green.withOpacity(0.7),
                              size: isMobile ? 16 : 20,
                            ),
                          ],
                        )
                        : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.swipe_left,
                                  color: Colors.red.withOpacity(0.7),
                                  size: isMobile ? 16 : 20,
                                ),
                                SizedBox(width: TSizes.xs),
                                Text(
                                  'Swipe Left - absent',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: TSizes.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.swipe_right,
                                  color: Colors.green.withOpacity(0.7),
                                  size: isMobile ? 16 : 20,
                                ),
                                SizedBox(width: TSizes.xs),
                                Text(
                                  'Swipe Right - present',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      case 'excused':
        return 'Excused';
      default:
        return 'Not Marked';
    }
  }

  Color _getStatusColor(String? status, bool dark) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      default:
        return dark ? TColors.yellow : TColors.deepPurple;
    }
  }
}
