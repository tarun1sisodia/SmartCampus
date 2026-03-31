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
import '../../../common/utils/constants/sized.dart';
import 'class_list_screen.dart';

class CarouselAttendanceScreen extends StatelessWidget {
  final carouselAttendanceController = Get.put(CarouselAttendanceController());
  final CarouselSliderController carouselController = CarouselSliderController();

  CarouselAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width <= 500;
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swift Attendance'),
        actions: [
          IconButton(
            onPressed: () {
              if (carouselAttendanceController.attendanceController.currentSessionId.value.isNotEmpty) {
                carouselAttendanceController.attendanceController.loadStudentsForSession();
              } else {
                Get.snackbar('No Session', 'Select a session first', snackPosition: SnackPosition.BOTTOM);
              }
            },
            icon: const Icon(Iconsax.refresh),
          ),
        ],
      ),
      body: Obx(() {
        final attendanceController = carouselAttendanceController.attendanceController;

        if (attendanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (attendanceController.currentSessionId.value.isEmpty) {
          return _buildEmptyState(context, Iconsax.calendar_1, 'No Session Selected', 'Please select an attendance session');
        }

        if (attendanceController.students.isEmpty) {
          return _buildEmptyState(context, Iconsax.people, 'No Students Found', 'Add students to this class first');
        }

        return Column(
          children: [
            // Timer View
            _buildTimerSection(context),

            // Carousel Section
            Expanded(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: attendanceController.students.length,
                options: CarouselOptions(
                  height: isLandscape ? screenSize.height * 0.6 : screenSize.height * 0.45,
                  viewportFraction: isLandscape ? 0.6 : 0.82,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => carouselAttendanceController.currentIndex.value = index,
                ),
                itemBuilder: (context, index, realIndex) {
                  final student = attendanceController.students[index];
                  return SwipeableStudentCard(
                    student: student,
                    onStatusChanged: (status) => attendanceController.updateStudentStatus(student.id, status),
                    onSwipeLeft: () => _nextPage(),
                    onSwipeRight: () => _nextPage(),
                  );
                },
              ),
            ),

            // Navigation Indicators
            _buildNavigationRow(context, attendanceController.students.length),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.md),
              child: AttendanceActionButtons(
                onMarkAttendance: (status) {
                  final student = carouselAttendanceController.currentStudent;
                  if (student != null) {
                    attendanceController.updateStudentStatus(student.id, status);
                    if (!carouselAttendanceController.isLastStudent) _nextPage();
                  }
                },
              ),
            ),

            // Submit Button
            _buildSubmitButton(context, isMobile),
            SizedBox(height: isMobile ? TSizes.md : TSizes.lg),
          ],
        );
      }),
    );
  }

  void _nextPage() {
    carouselAttendanceController.moveToNextStudent();
    carouselController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: TSizes.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: TSizes.lg),
          ElevatedButton(onPressed: () => Get.to(() => ClassListScreen()), child: const Text('Go to Classes')),
        ],
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context) {
    return Obx(() {
      if (!carouselAttendanceController.isTimerRunning.value) return const SizedBox.shrink();
      final timerText = carouselAttendanceController.remainingTime.value;
      final isCountdown = carouselAttendanceController.isCountdownMode.value;
      final isEnded = timerText.contains('Ended');

      return Container(
        margin: const EdgeInsets.all(TSizes.defaultSpace),
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
        decoration: BoxDecoration(
          color: isEnded ? Colors.red.withValues(alpha: 0.1) : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
          border: Border.all(color: isEnded ? Colors.red.withValues(alpha: 0.3) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: SessionTimerWidget(remainingTime: timerText, isSessionActive: !isEnded, isCountdownMode: isCountdown),
      );
    });
  }

  Widget _buildNavigationRow(BuildContext context, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: carouselAttendanceController.isFirstStudent ? null : () {
              carouselAttendanceController.moveToPreviousStudent();
              carouselController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            icon: Icon(Icons.arrow_back_ios, size: 18, color: carouselAttendanceController.isFirstStudent ? Colors.grey : Theme.of(context).colorScheme.primary),
          ),
          Obx(() => Text('${carouselAttendanceController.currentIndex.value + 1} / $total', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold))),
          IconButton(
            onPressed: carouselAttendanceController.isLastStudent ? null : () {
              carouselAttendanceController.moveToNextStudent();
              carouselController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            icon: Icon(Icons.arrow_forward_ios, size: 18, color: carouselAttendanceController.isLastStudent ? Colors.grey : Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isMobile) {
    return Obx(() => carouselAttendanceController.attendanceController.isStudentsLoaded.value
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
            child: ElevatedButton.icon(
              onPressed: () => _showSubmitConfirmation(context),
              icon: const Icon(Iconsax.tick_square, size: 20),
              label: const Text('Finalize Attendance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
              ),
            ),
          )
        : const SizedBox.shrink());
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.defaultDialog(
      title: 'Submit Attendance',
      middleText: 'Ready to finalize attendance for this session?',
      textConfirm: 'Yes, Submit',
      textCancel: 'Wait',
      confirmTextColor: Colors.white,
      buttonColor: Theme.of(context).colorScheme.primary,
      onConfirm: () {
        Get.back();
        carouselAttendanceController.submitAttendance();
      },
    );
  }
}
