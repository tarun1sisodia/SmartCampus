import 'package:attedance__/app/bindings/app_bindings.dart';
import 'package:attedance__/common/utils/helpers/snackbar_helper.dart';
import 'package:attedance__/features/teacher/screens/carousel_attendance_screen.dart';
import 'package:attedance__/features/teacher/screens/mark_attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../controllers/attendance_controller.dart';
import '../../../models/class_model.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class AttendanceScreen extends StatelessWidget {
  final ClassModel classModel;
  final attendanceController = Get.put(AttendanceController());

  AttendanceScreen({super.key, required this.classModel}) {
    //print('AttendanceScreen initialized with classModel: $classModel');
  }

  @override
  Widget build(BuildContext context) {
    //print('Building AttendanceScreen');
    final dark = THelperFunction.isDarkMode(context);
    //print('Dark mode: $dark');

    // Set the selected class when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //print('Setting selected class in post frame callback');
      attendanceController.setSelectedClass(classModel);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          classModel.subjectName ?? 'Class Attendance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () {
              //print('Refreshing attendance sessions');
              attendanceController.loadAttendanceSessions(classModel.id);
            },
            icon: const Icon(Iconsax.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //print('Opening create session dialog');
          _showCreateSessionDialog(context);
        },
        backgroundColor: dark ? TColors.blue : TColors.yellow,
        icon: const Icon(Iconsax.calendar_add),
        label: const Text('New Session'),
      ),
      body: Obx(() {
        //print('Building Obx body');
        if (attendanceController.isLoading.value) {
          //print('Showing loading indicator');
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            //print('Refreshing attendance sessions');
            // Show loading indicator while refreshing
            attendanceController.attendanceSessions();
          },
          color: dark ? TColors.yellow : TColors.deepPurple,
          backgroundColor: dark ? TColors.darkerGrey : Colors.white,
          displacement: 40.0,
          strokeWidth: 3.0,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          child: Column(
            children: [
              // Class info card
              Container(
                margin: const EdgeInsets.all(TSizes.defaultSpace),
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: dark ? TColors.darkerGrey : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${classModel.courseName} - Year ${classModel.semester}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (classModel.section != null)
                      Text(
                        'Section: ${classModel.section}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    Row(
                      children: [
                        Icon(
                          Iconsax.people,
                          size: 16,
                          color: dark ? TColors.yellow : TColors.deepPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${attendanceController.students.length} Students',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sessions header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance Sessions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${attendanceController.attendanceSessions.length} Sessions',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              // Sessions list
              Expanded(
                child: attendanceController.attendanceSessions.isEmpty
                    ? Center(
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
                              'No Attendance Sessions',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 2),
                            Text(
                              'Create a new session to start taking attendance',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.defaultSpace,
                        ),
                        itemCount:
                            attendanceController.attendanceSessions.length,
                        itemBuilder: (context, index) {
                          //print('Building session item at index: $index');
                          final session =
                              attendanceController.attendanceSessions[index];
                          final formattedDate = DateFormat('EEEE, MMMM d, yyyy')
                              .format(session.date);

                          return Card(
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
                              onTap: () {
                                //print('Navigating to mark attendance screen');
                                // Set current session and navigate to mark attendance
                                attendanceController.currentSessionId.value =
                                    session.id;
                                Get.to(() => MarkAttendanceScreen());
                              },
                              leading: CircleAvatar(
                                backgroundColor:
                                    dark ? TColors.yellow : TColors.deepPurple,
                                child: Text(
                                  DateFormat('d').format(session.date),
                                  style: TextStyle(
                                    color: dark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                formattedDate,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: TSizes.spaceBtwItems / 2,
                                  ),
                                  if (session.startTime != null &&
                                      session.endTime != null)
                                    Text(
                                      'Time: ${session.startTime} - ${session.endTime}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  Text(
                                    'Created: ${DateFormat('MMM d, yyyy').format(session.createdAt ?? DateTime.now())}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Iconsax.play_circle),
                                    tooltip: 'Carousel View',
                                    onPressed: () {
                                      //print(
                                          // 'Navigating to carousel attendance screen');
                                      // Check if session is running before allowing access
                                      if (!attendanceController
                                          .isSessionRunning(session.id)) {
                                        // Show a message that the session is closed
                                        TSnackBar.showInfo(
                                          message:
                                              'This session is currently closed',
                                          title: 'Session Closed',
                                        );
                                        return; // Don't proceed further
                                      }
                                      // Set current session and navigate to carousel attendance
                                      attendanceController
                                          .currentSessionId.value = session.id;
                                      Get.to(
                                        () => CarouselAttendanceScreen(),
                                        binding: CarouselAttendanceBinding(),
                                      );
                                    },
                                  ),
                                  const Icon(Iconsax.arrow_right_3),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Show dialog to create a new attendance session
  void _showCreateSessionDialog(BuildContext context) {
    //print('Showing create session dialog');
    final dark = THelperFunction.isDarkMode(context);

    // Reset date to today
    attendanceController.sessionDate.value = DateTime.now();
    attendanceController.startTimeController.clear();
    attendanceController.endTimeController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Create Attendance Session'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date picker
              ListTile(
                title: const Text('Date'),
                subtitle: Obx(
                  () => Text(
                    DateFormat('EEEE, MMMM d, yyyy')
                        .format(attendanceController.sessionDate.value),
                  ),
                ),
                trailing: const Icon(Iconsax.calendar),
                onTap: () async {
                  //print('Opening date picker');
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: attendanceController.sessionDate.value,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );

                  if (pickedDate != null) {
                    //print('Selected date: $pickedDate');
                    attendanceController.sessionDate.value = pickedDate;
                  }
                },
              ),

              const SizedBox(height: TSizes.spaceBtwInputFields),

              // Start time field
              TextField(
                controller: attendanceController.startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time (Optional)',
                  hintText: 'e.g., 9:00 AM',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(TSizes.inputFieldRadius),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.clock),
                    onPressed: () async {
                      //print('Opening start time picker');
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        //print('Selected start time: $pickedTime');
                        attendanceController.startTimeController.text =
                            pickedTime.format(context);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwInputFields),

              // End time field
              TextField(
                controller: attendanceController.endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time (Optional)',
                  hintText: 'e.g., 10:00 AM',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(TSizes.inputFieldRadius),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.clock),
                    onPressed: () async {
                      //print('Opening end time picker');
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        //print('Selected end time: $pickedTime');
                        attendanceController.endTimeController.text =
                            pickedTime.format(context);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                //print('Canceling session creation');
                Get.back();
              },
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              //print('Creating new attendance session');
              attendanceController.createAttendanceSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
              foregroundColor: dark ? Colors.black : Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
