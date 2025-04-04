import 'package:attedance__/features/teacher/screens/class_list_screen.dart';
import 'package:attedance__/features/teacher/widgets/session_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../controllers/carousel_attendance_controller.dart';
import '../widgets/swipeable_student_card.dart';
import '../widgets/attendance_stats_card.dart';
import '../widgets/attendance_action_buttons.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class CarouselAttendanceScreen extends StatelessWidget {
  // Use Get.find instead of Get.put to avoid recreating the controller
  final carouselAttendanceController = Get.find<CarouselAttendanceController>();
  final CarouselSliderController carouselController = CarouselSliderController();

  CarouselAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Attendance'),
        // automaticallyImplyLeading: false,
        actions: [
          // Session timer in app bar
          // Obx(
          //   () =>
          //       carouselAttendanceController.isTimerRunning.value
          //           ? Padding(
          //             padding: const EdgeInsets.only(right: TSizes.sm),
          //             child: Center(
          //               child: SessionTimerWidget(
          //                 remainingTime:
          //                     carouselAttendanceController.remainingTime.value,
          //                 isSessionActive:
          //                     !carouselAttendanceController.remainingTime.value
          //                         .contains('Ended'),
          //               ),
          //             ),
          //           )
          //           : const SizedBox.shrink(),
          // ),
          SizedBox(width: TSizes.spaceBtwSections),
          IconButton(
            onPressed: () {
              // Only try to load students if a session is selected
              if (carouselAttendanceController.attendanceController.currentSessionId.value.isNotEmpty) {
                carouselAttendanceController.attendanceController.loadStudentsForSession();
              } else {
                // Show a message if no session is selected
                Get.snackbar(
                  'No Session Selected',
                  'Please select a session from the attendance screen first',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            icon: const Icon(Iconsax.refresh),
          ),
        ],
      ),
      // floatingActionButton: Obx(
      //   () =>
      //       carouselAttendanceController
      //               .attendanceController
      //               .isStudentsLoaded
      //               .value
      //           ? FloatingActionButton.extended(
      //             onPressed: () => _showSubmitConfirmation(context),
      //             backgroundColor: dark ? TColors.blue : TColors.yellow,
      //             icon: const Icon(Iconsax.tick_square),
      //             label: const Text('Submit Attendance'),
      //           )
      //           : const SizedBox.shrink(),
      // ),
      body: Obx(() {
        final attendanceController =
            carouselAttendanceController.attendanceController;

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
                const SizedBox(height: TSizes.spaceBtwItems),
                // Add this button to allow selecting a session
                ElevatedButton(
                  onPressed: () {
                    // Navigate to class list to select a class first
                    Get.to(() => ClassListScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? TColors.yellow : TColors.deepPurple,
                    foregroundColor: dark ? Colors.black : Colors.white,
                  ),
                  child: const Text('Select a Class'),
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

        return Column(
          children: [
            // Attendance stats card
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: AttendanceStatsCard(
                totalStudents: attendanceController.students.length,
                presentCount: carouselAttendanceController.presentCount.value,
                absentCount: carouselAttendanceController.absentCount.value,
                lateCount: carouselAttendanceController.lateCount.value,
                excusedCount: carouselAttendanceController.excusedCount.value,
              ),
            ),
            // Session timer above carousel - make it more visible
            Obx(
              () => carouselAttendanceController.isTimerRunning.value
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: TSizes.defaultSpace,
                        vertical: TSizes.sm,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.md,
                        vertical: TSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkerGrey : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                        border: Border.all(
                          color: dark ? TColors.yellow.withOpacity(0.3) : TColors.deepPurple.withOpacity(0.3),
                        ),
                      ),
                      child: SessionTimerWidget(
                        remainingTime: carouselAttendanceController.remainingTime.value,
                        isSessionActive: !carouselAttendanceController.remainingTime.value.contains('Ended'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Carousel of student cards
            Expanded(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: attendanceController.students.length,
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 0.85,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    carouselAttendanceController.currentIndex.value = index;
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  final student = attendanceController.students[index];
                  return SwipeableStudentCard(
                    student: student,
                    onStatusChanged: (status) {
                      attendanceController.updateStudentStatus(
                        student.id,
                        status,
                      );
                    },
                    onSwipeLeft: () {
                      carouselAttendanceController.moveToNextStudent();
                      // Add this line to move the carousel
                      if (!carouselAttendanceController.isLastStudent) {
                        carouselController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    onSwipeRight: () {
                      carouselAttendanceController.moveToNextStudent();
                      // Add this line to move the carousel
                      if (!carouselAttendanceController.isLastStudent) {
                        carouselController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  );
                },
              ),
            ),

            // Navigation indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        carouselAttendanceController.isFirstStudent
                            ? null
                            : () {
                              carouselAttendanceController
                                  .moveToPreviousStudent();
                              carouselController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color:
                          carouselAttendanceController.isFirstStudent
                              ? Colors.grey
                              : dark
                              ? TColors.yellow
                              : TColors.deepPurple,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${carouselAttendanceController.currentIndex.value + 1}/${attendanceController.students.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        carouselAttendanceController.isLastStudent
                            ? null
                            : () {
                              carouselAttendanceController.moveToNextStudent();
                              carouselController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color:
                          carouselAttendanceController.isLastStudent
                              ? Colors.grey
                              : dark
                              ? TColors.yellow
                              : TColors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: AttendanceActionButtons(
                onMarkAttendance: (status) {
                  final student = carouselAttendanceController.currentStudent;
                  if (student != null) {
                    attendanceController.updateStudentStatus(
                      student.id,
                      status,
                    );
                    carouselAttendanceController.moveToNextStudent();
                    if (!carouselAttendanceController.isLastStudent) {
                      carouselController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
              ),
            ),
            Obx(
              () =>
                  carouselAttendanceController
                          .attendanceController
                          .isStudentsLoaded
                          .value
                      ? FloatingActionButton.extended(
                        onPressed: () => _showSubmitConfirmation(context),
                        backgroundColor: dark ? TColors.blue : TColors.yellow,
                        icon: const Icon(Iconsax.tick_square),
                        label: const Text('Submit Attendance'),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        );
      }),
    );
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
              carouselAttendanceController.submitAttendance();
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
