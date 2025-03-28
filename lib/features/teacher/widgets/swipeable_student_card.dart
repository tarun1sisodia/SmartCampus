import 'package:flutter/material.dart';
import '../../../models/student_model.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class SwipeableStudentCard extends StatelessWidget {
  final StudentModel student;
  final Function(String) onStatusChanged;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  
  const SwipeableStudentCard({
    Key? key,
    required this.student,
    required this.onStatusChanged,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    
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
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status indicator at the top
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.md,
                  vertical: TSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(student.attendanceStatus, dark),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                ),
                child: Text(
                  _getStatusText(student.attendanceStatus),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: TSizes.spaceBtwItems),
              
              // Student avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: _getStatusColor(student.attendanceStatus, dark).withOpacity(0.2),
                child: Text(
                  student.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(student.attendanceStatus, dark),
                  ),
                ),
              ),
              
              const SizedBox(height: TSizes.spaceBtwItems),
              
              // Student name
              Text(
                student.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              
              // Roll number
              Text(
                'Roll Number: ${student.rollNumber}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Swipe instructions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swipe_left, color: Colors.red.withOpacity(0.7)),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Text(
                    'Swipe Left - absent  Right - present',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Icon(Icons.swipe_right, color: Colors.green.withOpacity(0.7)),
                ],
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
        return dark ? TColors.yellow : TColors.deepPurple;
    }
  }
}
