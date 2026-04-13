import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/device/device_utility.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';
import '../widgets/swipeable_student_card.dart';
import '../widgets/attendance_action_buttons.dart';
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
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Text(
          'SWIFT ATTENDANCE', 
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0)
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (carouselAttendanceController.attendanceController.currentSessionId.value.isNotEmpty) {
                carouselAttendanceController.attendanceController.loadStudentsForSession();
              } else {
                TSnackBar.showInfo(message: 'SELECT A SESSION FIRST', title: 'NO SESSION');
              }
            },
            icon: const Icon(Iconsax.refresh, color: TColors.slate900),
          ),
        ],
      ),
      body: Obx(() {
        final attendanceController = carouselAttendanceController.attendanceController;

        if (attendanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (attendanceController.currentSessionId.value.isEmpty) {
          return _buildEmptyState(context, Iconsax.calendar_1, 'NO SESSION SELECTED', 'PLEASE SELECT AN ATTENDANCE SESSION');
        }

        if (attendanceController.students.isEmpty) {
          return _buildEmptyState(context, Iconsax.people, 'NO STUDENTS FOUND', 'ADD STUDENTS TO THIS CLASS FIRST');
        }

        return Column(
          children: [
            // 1. Timer View (Sharp Header)
            _buildTimerSection(context),

            // 2. Carousel Section (Sharp Cards)
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

            // 3. Navigation Indicators (Bold & Structural)
            _buildNavigationRow(context, attendanceController.students.length),

            // 4. Action Buttons (Sharp Square Icons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

            // 5. Submit Button (Full Width, Sharp)
            _buildSubmitButton(context),
            const SizedBox(height: 24),
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
          Icon(icon, size: 64, color: TColors.slate300),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TColors.slate900)),
          Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: TColors.slate600), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Get.to(() => ClassListScreen()), 
            child: const Text('GO TO CLASSES')
          ),
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
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnded ? const Color(0xFFE11D48).withOpacity(0.1) : TColors.blue100.withOpacity(0.4),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isEnded ? const Color(0xFFE11D48) : TColors.executiveNavy, 
            width: 1.5
          ),
        ),
        child: SessionTimerWidget(remainingTime: timerText, isSessionActive: !isEnded, isCountdownMode: isCountdown),
      );
    });
  }

  Widget _buildNavigationRow(BuildContext context, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: carouselAttendanceController.isFirstStudent ? null : () {
              carouselAttendanceController.moveToPreviousStudent();
              carouselController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            icon: Icon(Icons.arrow_back_ios, size: 20, color: carouselAttendanceController.isFirstStudent ? TColors.slate300 : TColors.executiveNavy),
          ),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: TColors.executiveNavy,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${carouselAttendanceController.currentIndex.value + 1} / $total', 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)
            ),
          )),
          IconButton(
            onPressed: carouselAttendanceController.isLastStudent ? null : () {
              carouselAttendanceController.moveToNextStudent();
              carouselController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            icon: Icon(Icons.arrow_forward_ios, size: 20, color: carouselAttendanceController.isLastStudent ? TColors.slate300 : TColors.executiveNavy),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() => carouselAttendanceController.attendanceController.isStudentsLoaded.value
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showSubmitConfirmation(context),
                icon: const Icon(Iconsax.tick_square, size: 20),
                label: const Text('FINALIZE ATTENDANCE'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          )
        : const SizedBox.shrink());
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        backgroundColor: TColors.white,
        title: const Text('SUBMIT ATTENDANCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: const Text(
          'ARE YOU READY TO FINALIZE ATTENDANCE FOR THIS SESSION? DATA WILL BE SYNCED IMMEDIATELY.',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: TColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: const Text('WAIT', style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900))
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              carouselAttendanceController.submitAttendance();
            },
            child: const Text('YES, SUBMIT'),
          ),
        ],
      ),
    );
  }
}
