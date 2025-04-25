import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/common/utils/device/device_utility.dart';
import 'package:attedance__/common/widgets/student_avatar.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/attendance_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class MarkAttendanceScreen extends StatelessWidget {
  final attendanceController = Get.find<AttendanceController>();

  MarkAttendanceScreen({super.key}) {
    //print('MarkAttendanceScreen initialized');

    // Check if the session is running when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSessionStatus();
    });
  }

  // Method to check if the session is running
  void _checkSessionStatus() {
    if (attendanceController.currentSessionId.value.isNotEmpty &&
        !attendanceController
            .isSessionRunning(attendanceController.currentSessionId.value)) {
      // Show a message that the session is closed
      TSnackBar.showInfo(
        message:
            'This session is currently closed. You can view but not modify attendance.',
        title: 'Session Closed',
      );

      // Optionally, you could navigate back or disable editing
      // For now, we'll just show a warning and keep the screen in read-only mode
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('Building MarkAttendanceScreen');
    final dark = THelperFunction.isDarkMode(context);
    //print('Dark mode: $dark');

    final screenSize = MediaQuery.of(context).size;
    //print('Screen size: $screenSize');
    final isTablet = screenSize.width < 1024 && screenSize.width > 500;
    final isMobile = screenSize.width <= 500;
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);
    //print(
        // 'Device type - isTablet: $isTablet, isMobile: $isMobile, isLandscape: $isLandscape');

    final cardPadding = isMobile
        ? (isLandscape ? TSizes.xs : TSizes.sm)
        : (isLandscape ? TSizes.sm : TSizes.md);
    //print('Card padding: $cardPadding');

    final avatarSize =
        isTablet ? (isLandscape ? 18.0 : 22.0) : (isLandscape ? 16.0 : 20.0);
    //print('Avatar size: $avatarSize');

    // Check if session is running
    final isSessionRunning =
        attendanceController.currentSessionId.value.isNotEmpty &&
            attendanceController
                .isSessionRunning(attendanceController.currentSessionId.value);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mark Attendance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () {
              //print('Refresh button pressed');
              attendanceController.loadStudentsForSession();
            },
            icon: const Icon(Iconsax.refresh),
          ),
          IconButton(
            onPressed: () {
              //print('Carousel View button pressed');

              // Check if session is running before allowing access to carousel view
              if (!isSessionRunning) {
                TSnackBar.showInfo(
                  message: 'This session is currently closed',
                  title: 'Session Closed',
                );
                return;
              }

              Get.toNamed(AppRoutes.carouselAttendance);
            },
            icon: const Icon(Iconsax.slider_horizontal_1),
            tooltip: 'Carousel View',
          ),
        ],
      ),
      floatingActionButton: Obx(
        () {
          //print('FloatingActionButton state updated');
          return attendanceController.isStudentsLoaded.value
              ? FloatingActionButton.extended(
                  onPressed: () {
                    //print('Submit Attendance button pressed');

                    // Check if session is running before allowing submission
                    if (!isSessionRunning) {
                      TSnackBar.showInfo(
                        message:
                            'Cannot submit attendance for a closed session',
                        title: 'Session Closed',
                      );
                      return;
                    }

                    _showSubmitConfirmation(context);
                  },
                  backgroundColor: dark ? TColors.blue : TColors.yellow,
                  icon: const Icon(Iconsax.tick_square),
                  label: const Text('Submit Attendance'),
                )
              : const SizedBox.shrink();
        },
      ),
      body: Obx(() {
        //print('Body state updated');
        if (attendanceController.isLoading.value) {
          //print('Loading students...');
          return const Center(child: CircularProgressIndicator());
        }

        if (attendanceController.currentSessionId.value.isEmpty) {
          //print('No session selected');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.calendar_1,
                  size: 64,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'No Session Selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  'Please select an attendance session',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (attendanceController.students.isEmpty) {
          //print('No students found');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.people,
                  size: 64,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'No Students Found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  'Add students to this class to take attendance',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        //print('Displaying student list');
        return RefreshIndicator(
          onRefresh: () async {
            //print('Refreshing student list');
            await attendanceController.loadStudentsForSession();
          },
          color: dark ? TColors.yellow : TColors.deepPurple,
          backgroundColor: dark ? TColors.darkerGrey : Colors.white,
          displacement: 40.0,
          strokeWidth: 3.0,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          child: ListView.builder(
            padding: EdgeInsets.all(isMobile ? TSizes.sm : TSizes.defaultSpace),
            itemCount: attendanceController.students.length,
            itemBuilder: (context, index) {
              final student = attendanceController.students[index];
              //print('Rendering student: ${student.name}');
              return Card(
                margin: EdgeInsets.only(
                  bottom: isMobile ? TSizes.xs : TSizes.spaceBtwItems,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: cardPadding,
                    vertical: isMobile ? TSizes.xs : TSizes.sm,
                  ),
                  // Use StudentAvatar widget instead of CircleAvatar
                  leading: StudentAvatar(
                    imageUrl: student.imageUrl,
                    name: student.name,
                    size: 40,
                    isDarkMode: dark,
                  ),
                  title: Text(
                    student.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile
                              ? (isLandscape ? 14.0 : 16.0)
                              : (isLandscape ? 16.0 : 18.0),
                        ),
                    maxLines: index > 0 ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height:
                            isMobile ? TSizes.xs / 2 : TSizes.spaceBtwItems / 2,
                      ),
                      Text(
                        'Roll Number: ${student.rollNumber}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: isMobile ? 10.0 : 12.0,
                            ),
                      ),
                    ],
                  ),
                  trailing: DropdownButton<String>(
                    value: student.attendanceStatus ?? 'absent',
                    isDense: true,
                    underline: Container(
                      height: 1,
                      color: _getStatusColor(student.attendanceStatus, dark),
                    ),
                    onChanged: isSessionRunning
                        ? (value) {
                            //print(
                                // 'Updating attendance status for ${student.name} to $value');
                            attendanceController.updateStudentStatus(
                              student.id,
                              value!,
                            );
                          }
                        : null, // Disable dropdown if session is not running
                    items: const [
                      DropdownMenuItem(
                        value: 'present',
                        child: Text('Present'),
                      ),
                      DropdownMenuItem(value: 'absent', child: Text('Absent')),
                      DropdownMenuItem(value: 'late', child: Text('Late')),
                      DropdownMenuItem(
                        value: 'excused',
                        child: Text('Excused'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String? status, bool dark) {
    //print('Getting status color for status: $status');
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

  void _showSubmitConfirmation(BuildContext context) {
    //print('Showing submit confirmation dialog');
    final dark = THelperFunction.isDarkMode(context);

    Get.dialog(
      AlertDialog(
        title: const Text('Submit Attendance'),
        content: const Text(
          'Are you sure you want to submit the attendance for this session?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              //print('Cancel button pressed in dialog');
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              //print('Submit button pressed in dialog');
              Get.back();
              attendanceController.submitAttendance();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
              foregroundColor: dark ? Colors.black : Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
