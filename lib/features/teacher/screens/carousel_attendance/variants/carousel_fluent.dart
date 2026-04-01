import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';

class CarouselFluent extends StatelessWidget {
  const CarouselFluent({super.key});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    const accentColor = Color(0xFF0078D4);

    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();

    return Container(
      color: fluentBg,
      child: Obx(() {
        if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator(color: accentColor));
        if (attendanceController.students.isEmpty) return _buildEmptyState(accentColor);

        return Column(
          children: [
            _buildFluentTimer(controller, accentColor),
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
                  return _buildFluentStudentCard(student, attendanceController, accentColor);
                },
              ),
            ),
            _buildNavFluent(controller, attendanceController.students.length, accentColor),
            _buildActionFluent(controller, attendanceController, carouselController, accentColor),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(Color accent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 64, color: accent.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('No Students Found', style: TextStyle(color: accent.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildFluentTimer(CarouselAttendanceController controller, Color accent) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildFluentStudentCard(dynamic student, dynamic attendanceController, Color accent) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 120, height: 120, decoration: BoxDecoration(color: accent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)), child: Center(child: Icon(Iconsax.user, size: 64, color: accent.withValues(alpha: 0.2)))),
          const SizedBox(height: 32),
          Text(student.name, style: const TextStyle(color: Color(0xFF201F1E), fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Text('RECORD: ${status.toUpperCase()}', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5));
          }),
        ],
      ),
    );
  }

  Widget _buildNavFluent(CarouselAttendanceController controller, int total, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Obx(() => Text('${controller.currentIndex.value + 1} of $total', style: TextStyle(color: Colors.black.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 13))),
    );
  }

  Widget _buildActionFluent(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _fluentActionBtn('ABSENT', Colors.red, () => _mark(controller, attendanceController, carousel, 'absent')),
          const SizedBox(width: 16),
          _fluentActionBtn('LATE', Colors.orange, () => _mark(controller, attendanceController, carousel, 'late')),
          const SizedBox(width: 16),
          _fluentActionBtn('PRESENT', accent, () => _mark(controller, attendanceController, carousel, 'present')),
        ],
      ),
    );
  }

  Widget _fluentActionBtn(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1))),
        ),
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
