import 'package:flutter/material.dart';
import '../../../models/student_model.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/device/device_utility.dart';
import '../../../common/utils/helpers/helper_function.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width <= 500;
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);

    // Card height calculation - taller in portrait, shorter in landscape
    final cardHeight = isLandscape ? 220.0 : 320.0;

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
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          side: BorderSide(
            color: _getStatusColor(student.attendanceStatus, dark),
            width: 2,
          ),
        ),
        child: SizedBox(
          height: cardHeight,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status indicator at the top
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: TSizes.sm,
                  vertical: TSizes.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(student.attendanceStatus, dark),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(TSizes.cardRadiusMd - 2),
                    topRight: Radius.circular(TSizes.cardRadiusMd - 2),
                  ),
                ),
                child: Text(
                  _getStatusText(student.attendanceStatus),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Student image - takes most of the card space
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image:
                        student.imageUrl != null && student.imageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(student.imageUrl!),
                                fit: BoxFit.contain,
                                onError: (exception, stackTrace) {
                                  //print('Error loading student image: $exception');
                                },
                              )
                            : null,
                  ),
                  child: student.imageUrl == null || student.imageUrl!.isEmpty
                      ? Center(
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name.substring(0, 1).toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(
                                  student.attendanceStatus, dark),
                            ),
                          ),
                        )
                      : null,
                ),
              ),

              // Student info at the bottom
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: dark ? Colors.grey[800] : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student name
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Roll number
                    Text(
                      'Roll: ${student.rollNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // // Swipe instructions
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Icon(
                    //       Icons.swipe_left,
                    //       color: Colors.red.withAlpha(179),
                    //       size: 16,
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       'Swipe to mark',
                    //       style: Theme.of(context).textTheme.bodySmall,
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Icon(
                    //       Icons.swipe_right,
                    //       color: Colors.green.withAlpha(179),
                    //       size: 16,
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
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
        return dark ? TColors.yellow : TColors.primary;
    }
  }
}
