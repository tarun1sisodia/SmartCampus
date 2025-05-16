import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../common/utils/constants/text_strings.dart';
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
  final CarouselSliderController carouselController =
      CarouselSliderController();

  CarouselAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width <= 500;
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel'),
        actions: [
          IconButton(
            onPressed: () {
              if (carouselAttendanceController
                  .attendanceController.currentSessionId.value.isNotEmpty) {
                carouselAttendanceController.attendanceController
                    .loadStudentsForSession();
              } else {
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
                ElevatedButton(
                  onPressed: () {
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

        return Column(
          children: [
            // Timer widget - only show if timer is running
            Obx(
              () {
                if (!carouselAttendanceController.isTimerRunning.value) {
                  return const SizedBox.shrink();
                }

                // Get timer display information
                final timerText =
                    carouselAttendanceController.remainingTime.value;
                final isCountdown =
                    carouselAttendanceController.isCountdownMode.value;
                final isSessionEnded = timerText.contains('Ended');

                return Container(
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
                      color: isCountdown
                          ? (isSessionEnded
                              ? Colors.red.withAlpha(128)
                              : (dark
                                  ? TColors.yellow.withAlpha(77)
                                  : TColors.primary.withAlpha(77)))
                          : (dark
                              ? Colors.blue.withAlpha(77)
                              : Colors.blue.withAlpha(77)),
                    ),
                  ),
                  child: SessionTimerWidget(
                    remainingTime: timerText,
                    isSessionActive: !isSessionEnded,
                    isCountdownMode: isCountdown,
                  ),
                );
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
                      carouselController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onSwipeRight: () {
                      carouselAttendanceController.moveToNextStudent();
                      carouselController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
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
                Get.back();
              },
              child: const Text(TTexts.cancel)),
          ElevatedButton(
            onPressed: () {
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
