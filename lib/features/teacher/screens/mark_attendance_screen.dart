import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/common/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/attendance_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class MarkAttendanceScreen extends StatelessWidget {
  final attendanceController = Get.find<AttendanceController>();

  MarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    // Add responsive sizing variables
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width < 1024 && screenSize.width > 500;
    final isMobile = screenSize.width <= 500;
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);

    // Calculate responsive padding
    final cardPadding =
        isMobile
            ? (isLandscape ? TSizes.xs : TSizes.sm)
            : (isLandscape ? TSizes.sm : TSizes.md);

    // Calculate avatar size based on device
    final avatarSize =
        isTablet ? (isLandscape ? 18.0 : 22.0) : (isLandscape ? 16.0 : 20.0);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mark Attendance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () => attendanceController.loadStudentsForSession(),
            icon: const Icon(Iconsax.refresh),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.carouselAttendance),
            icon: const Icon(Iconsax.slider_horizontal_1),
            tooltip: 'Carousel View',
          ),
        ],
      ),
      floatingActionButton: Obx(
        () =>
            attendanceController.isStudentsLoaded.value
                ? FloatingActionButton.extended(
                  onPressed: () => _showSubmitConfirmation(context),
                  backgroundColor: dark ? TColors.blue : TColors.yellow,
                  icon: const Icon(Iconsax.tick_square),
                  label: const Text('Submit Attendance'),
                )
                : const SizedBox.shrink(),
      ),
      body: Obx(() {
        if (attendanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (attendanceController.currentSessionId.value.isEmpty) {
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

        return RefreshIndicator(
          onRefresh: () async {
            // Show loading indicator while refreshing
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
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(
                      student.attendanceStatus,
                      dark,
                    ),
                    radius: 20,
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name.substring(0, 1)
                          : "?",
                      style: TextStyle(
                        color: dark ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: avatarSize * 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  title: Text(
                    student.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          isMobile
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
                          // color: dark ? Colors.white70 : Colors.black54,
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
                    onChanged: (value) {
                      attendanceController.updateStudentStatus(
                        student.id,
                        value!,
                      );
                    },
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
    final dark = THelperFunction.isDarkMode(context);

    Get.dialog(
      AlertDialog(
        title: const Text('Submit Attendance'),
        content: const Text(
          'Are you sure you want to submit the attendance for this session?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
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
