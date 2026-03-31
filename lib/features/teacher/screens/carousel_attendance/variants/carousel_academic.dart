import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';

class CarouselAcademic extends StatelessWidget {
  const CarouselAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513);

    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();

    return Container(
      color: paperColor,
      child: Obx(() {
        if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator(color: inkColor));
        if (attendanceController.students.isEmpty) return _buildEmptyState(inkColor);

        return Column(
          children: [
            _buildScholarTimer(controller, inkColor, accentColor),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: attendanceController.students.length,
                options: CarouselOptions(
                  height: 420,
                  viewportFraction: 0.8,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => controller.currentIndex.value = index,
                ),
                itemBuilder: (context, index, realIndex) {
                  final student = attendanceController.students[index];
                  return _buildScholarStudentCard(student, attendanceController, inkColor, accentColor);
                },
              ),
            ),
            _buildNavScholar(controller, attendanceController.students.length, inkColor),
            _buildActionScholar(controller, attendanceController, carouselController, inkColor, accentColor),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(Color ink) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 64, color: ink.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text('No Records Found', style: TextStyle(color: ink.withOpacity(0.3), fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Serif')),
        ],
      ),
    );
  }

  Widget _buildScholarTimer(CarouselAttendanceController controller, Color ink, Color accent) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withOpacity(0.1))),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildScholarStudentCard(dynamic student, dynamic attendanceController, Color ink, Color accent) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withOpacity(0.05)), boxShadow: [BoxShadow(color: ink.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 120, height: 120, decoration: BoxDecoration(color: ink.withOpacity(0.05), shape: BoxShape.circle), child: Center(child: Icon(Iconsax.user, size: 64, color: ink.withOpacity(0.2)))),
          const SizedBox(height: 32),
          Text(student.name.toUpperCase(), style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1, fontFamily: 'Serif')),
          const SizedBox(height: 16),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Text('REGISTERED: ${status.toUpperCase()}', style: TextStyle(color: accent.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5, fontFamily: 'Serif'));
          }),
        ],
      ),
    );
  }

  Widget _buildNavScholar(CarouselAttendanceController controller, int total, Color ink) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Obx(() => Text('FOLIO: ${controller.currentIndex.value + 1} / $total', style: TextStyle(color: ink.withOpacity(0.3), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Serif'))),
    );
  }

  Widget _buildActionScholar(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel, Color ink, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _scholarActionBtn('ABS', ink.withOpacity(0.4), () => _mark(controller, attendanceController, carousel, 'absent')),
        const SizedBox(width: 24),
        _scholarActionBtn('LAT', ink.withOpacity(0.6), () => _mark(controller, attendanceController, carousel, 'late')),
        const SizedBox(width: 24),
        _scholarActionBtn('PRE', ink, () => _mark(controller, attendanceController, carousel, 'present')),
      ],
    );
  }

  Widget _scholarActionBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.zero),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Serif')),
      ),
    );
  }

  void _mark(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel, String status) {
    final student = controller.currentStudent;
    if (student != null) {
      attendanceController.updateStudentStatus(student.id, status);
      if (!controller.isLastStudent) carousel.nextPage();
    }
  }
}
