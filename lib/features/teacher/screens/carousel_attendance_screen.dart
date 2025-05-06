import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../common/utils/device/device_utility.dart';
import '../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';
import '../widgets/swipeable_student_card.dart';
import '../widgets/attendance_action_buttons.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import 'class_list_screen.dart';

class CarouselAttendanceScreen extends StatelessWidget {
  final carouselAttendanceController = Get.put(CarouselAttendanceController());
  final CarouselSliderController carouselController =CarouselSliderController();

  CarouselAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //print('Building CarouselAttendanceScreen');
    final dark = THelperFunction.isDarkMode(context);
    // Inside the build method, add these responsive variables
    final screenSize = MediaQuery.of(context).size;
    //print('Screen size: $screenSize');
    // final isTablet = screenSize.width < 1024 && screenSize.width > 500;
    final isMobile = screenSize.width <= 500;
    //print('Is mobile: $isMobile');
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);
    //print('Is landscape: $isLandscape');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Attendance'),
        actions: [
          // Session timer in app bar
          Obx(
            () {
              //print(
              // 'Timer running: ${carouselAttendanceController.isTimerRunning.value}');
              return carouselAttendanceController.isTimerRunning.value
                  ? Padding(
                      padding: const EdgeInsets.only(right: TSizes.sm),
                      child: Center(
                        child: SessionTimerWidget(
                          remainingTime:
                              carouselAttendanceController.remainingTime.value,
                          isSessionActive: !carouselAttendanceController
                              .remainingTime.value
                              .contains('Ended'),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          IconButton(
            onPressed: () {
              //print('Refresh button pressed');
              // Only try to load students if a session is selected
              if (carouselAttendanceController
                  .attendanceController.currentSessionId.value.isNotEmpty) {
                //print('Loading students for session');
                carouselAttendanceController.attendanceController
                    .loadStudentsForSession();
              } else {
                //print('No session selected');
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
      body: Obx(() {
        //print('Building body with Obx');
        final attendanceController =
            carouselAttendanceController.attendanceController;

        if (attendanceController.isLoading.value) {
          //print('Loading state');
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
                  color: dark ? TColors.yellow : TColors.primary,
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
                //button to allow selecting a session
                ElevatedButton(
                  onPressed: () {
                    //print('Navigating to class list');
                    // Navigate to class list to select a class first
                    Get.to(() => ClassListScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? TColors.yellow : TColors.primary,
                    foregroundColor: dark ? TColors.dark : Colors.white,
                  ),
                  child: const Text('Select a Class'),
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
                  color: dark ? TColors.yellow : TColors.primary,
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

        //print(
        // 'Building main content with ${attendanceController.students.length} students');
        return Column(
          children: [
            Obx(
              () {
                //print('Building timer widget');
                return carouselAttendanceController.isTimerRunning.value
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
                          color:
                              dark ? TColors.darkerGrey : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(
                            TSizes.borderRadiusMd,
                          ),
                          border: Border.all(
                            color: dark
                                ? TColors.yellow.withOpacity(0.3)
                                : TColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: SessionTimerWidget(
                          remainingTime:
                              carouselAttendanceController.remainingTime.value,
                          isSessionActive: !carouselAttendanceController
                              .remainingTime.value
                              .contains('Ended'),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: attendanceController.students.length,
                options: CarouselOptions(
                  height: isLandscape
                      ? screenSize.height * 0.6
                      : screenSize.height * 0.4,
                  viewportFraction: isLandscape ? 0.6 : 0.85,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    //print('Carousel page changed to index: $index');
                    carouselAttendanceController.currentIndex.value = index;
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  final student = attendanceController.students[index];
                  //print('Building card for student: ${student.id}');
                  return SwipeableStudentCard(
                    student: student,
                    onStatusChanged: (status) {
                      //print('Status changed for student ${student.id} to $status');
                      attendanceController.updateStudentStatus(
                        student.id,
                        status,
                      );
                    },
                    onSwipeLeft: () {
                      //print('Swipe left detected');
                      carouselAttendanceController.moveToNextStudent();
                      // if (!carouselAttendanceController.isLastStudent) {
                      carouselController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      // }
                    },
                    onSwipeRight: () {
                      //print('Swipe right detected');
                      carouselAttendanceController.moveToNextStudent();
                      // if (!carouselAttendanceController.isLastStudent) {
                      carouselController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      // }
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: carouselAttendanceController.isFirstStudent
                        ? null
                        : () {
                            //print('Moving to previous student');
                            carouselAttendanceController
                                .moveToPreviousStudent();
                            carouselController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: carouselAttendanceController.isFirstStudent
                          ? Colors.grey
                          : dark
                              ? TColors.yellow
                              : TColors.primary,
                    ),
                  ),
                  Obx(
                    () {
                      //print('Current index: ${carouselAttendanceController.currentIndex.value}');
                      return Text(
                        '${carouselAttendanceController.currentIndex.value + 1}/${attendanceController.students.length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  ),
                  IconButton(
                    onPressed: carouselAttendanceController.isLastStudent
                        ? null
                        : () {
                            //print('Moving to next student');
                            carouselAttendanceController.moveToNextStudent();
                            carouselController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: carouselAttendanceController.isLastStudent
                          ? Colors.grey
                          : dark
                              ? TColors.yellow
                              : TColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: AttendanceActionButtons(
                onMarkAttendance: (status) {
                  //print('Marking attendance with status: $status');
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
            Padding(
              padding: EdgeInsets.only(
                bottom: isMobile ? TSizes.sm : TSizes.md,
              ),
              child: Obx(
                () {
                  //print(
                  // 'Students loaded: ${carouselAttendanceController.attendanceController.isStudentsLoaded.value}');
                  return carouselAttendanceController
                          .attendanceController.isStudentsLoaded.value
                      ? SizedBox(
                          width: isMobile ? 300 : 240,
                          height: isMobile ? 50 : 40,
                          child: ElevatedButton.icon(
                            onPressed: () => _showSubmitConfirmation(context),
                            icon: const Icon(Iconsax.tick_square, size: 20),
                            label: const Text('Submit Attendance'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  dark ? TColors.blue : TColors.yellow,
                              foregroundColor:
                                  dark ? Colors.white : TColors.dark,
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? TSizes.xs : TSizes.sm,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  TSizes.buttonRadius,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      }),
    );
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
                //print('Submit dialog cancelled');
                Get.back();
              },
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              //print('Submitting attendance');
              Get.back();
              carouselAttendanceController.submitAttendance();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? TColors.yellow : TColors.primary,
              foregroundColor: dark ? TColors.dark : Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
