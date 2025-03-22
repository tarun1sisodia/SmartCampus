import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../controllers/attendance_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sized.dart';
import '../../../utils/helpers/helper_function.dart';

class MarkAttendanceScreen extends StatelessWidget {
  final attendanceController = Get.find<AttendanceController>();

  MarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mark Attendance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          TextButton.icon(
            onPressed: () => attendanceController.submitAttendance(),
            icon: const Icon(Iconsax.tick_square),
            label: const Text('Submit'),
            style: TextButton.styleFrom(
              foregroundColor: dark ? TColors.yellow : TColors.deepPurple,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (attendanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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
                  'No Students',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  'There are no students in this class',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Instructions
            Container(
              margin: const EdgeInsets.all(TSizes.defaultSpace),
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: dark ? TColors.darkerGrey : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: Column(
                children: [
                  Text(
                    'Swipe Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(Iconsax.arrow_right_3, color: Colors.green),
                          Text(
                            'Present',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Iconsax.arrow_left_2, color: Colors.red),
                          Text(
                            'Absent',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Students count
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TSizes.defaultSpace,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Students',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${attendanceController.students.length} Total',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // Students list with swipe actions
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                itemCount: attendanceController.students.length,
                itemBuilder: (context, index) {
                  final student = attendanceController.students[index];

                  // Determine the background color based on attendance status
                  Color? backgroundColor;
                  if (student.attendanceStatus == 'present') {
                    backgroundColor = Colors.green.withOpacity(0.2);
                  } else if (student.attendanceStatus == 'absent') {
                    backgroundColor = Colors.red.withOpacity(0.2);
                  }

                  return Slidable(
                    key: Key(student.id),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dismissible: DismissiblePane(
                        onDismissed:
                            () => attendanceController.markStudentAbsent(index),
                      ),
                      children: [
                        SlidableAction(
                          onPressed:
                              (_) =>
                                  attendanceController.markStudentAbsent(index),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Iconsax.close_circle,
                          label: 'Absent',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dismissible: DismissiblePane(
                        onDismissed:
                            () =>
                                attendanceController.markStudentPresent(index),
                      ),
                      children: [
                        SlidableAction(
                          onPressed:
                              (_) => attendanceController.markStudentPresent(
                                index,
                              ),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Iconsax.tick_circle,
                          label: 'Present',
                        ),
                      ],
                    ),
                    child: Container(
                      color: backgroundColor,
                      child: Card(
                        margin: const EdgeInsets.only(
                          bottom: TSizes.spaceBtwItems,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TSizes.cardRadiusMd,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(TSizes.md),
                          leading: CircleAvatar(
                            backgroundColor:
                                dark ? TColors.yellow : TColors.deepPurple,
                            child: Text(
                              student.name.substring(0, 1),
                              style: TextStyle(
                                color: dark ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: TSizes.spaceBtwItems / 2),
                              Text(
                                'Roll Number: ${student.rollNumber}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: _buildAttendanceStatusIcon(
                            student.attendanceStatus,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  // Build attendance status icon
  Widget _buildAttendanceStatusIcon(String? status) {
    if (status == 'present') {
      return const CircleAvatar(
        backgroundColor: Colors.green,
        radius: 15,
        child: Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
      );
    } else if (status == 'absent') {
      return const CircleAvatar(
        backgroundColor: Colors.red,
        radius: 15,
        child: Icon(Iconsax.close_circle, color: Colors.white, size: 18),
      );
    } else {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 15,
        child: Icon(Iconsax.message_question, color: Colors.white, size: 18),
      );
    }
  }
}
