import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../controllers/carousel_attendance_controller.dart';
import '../../../widgets/session_timer_widget.dart';

class CarouselCorporate extends StatelessWidget {
  const CarouselCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Obx(() {
        if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (attendanceController.students.isEmpty) return _buildEmptyState();

        return Column(
          children: [
            _buildTimerHUD(controller),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: attendanceController.students.length,
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 0.85,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => controller.currentIndex.value = index,
                ),
                itemBuilder: (context, index, realIndex) {
                  final student = attendanceController.students[index];
                  return _buildCorporateStudentCard(student, attendanceController);
                },
              ),
            ),
            _buildNavigationHUD(controller, carouselController, attendanceController.students.length),
            _buildActionHUD(controller, attendanceController, carouselController),
            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Iconsax.people, size: 64, color: Color(0xFFCBD5E1)),
          SizedBox(height: 16),
          Text('NO_STUDENTS_FOUND', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildTimerHUD(CarouselAttendanceController controller) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 2)),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildCorporateStudentCard(dynamic student, dynamic attendanceController) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 2), boxShadow: const [BoxShadow(color: Color(0xFFE2E8F0), offset: Offset(8, 8))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 120, height: 120, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF0F172A), width: 2)), child: const Icon(Iconsax.user, size: 64, color: Color(0xFF0F172A))),
          const SizedBox(height: 24),
          Text(student.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A), letterSpacing: 1)),
          Text('UID: ${student.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 2)),
          const SizedBox(height: 32),
          _buildStatusIndicator(student.id, attendanceController),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String id, dynamic attendanceController) {
    return Obx(() {
      final status = attendanceController.getStudentStatus(id);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: status == 'present' ? const Color(0xFF10B981) : (status == 'absent' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
        child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
      );
    });
  }

  Widget _buildNavigationHUD(CarouselAttendanceController controller, CarouselSliderController carousel, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _navBtn(Iconsax.arrow_left_2, () => carousel.previousPage()),
          const SizedBox(width: 24),
          Obx(() => Text('REGISTRY ${controller.currentIndex.value + 1} / $total', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0F172A), letterSpacing: 1))),
          const SizedBox(width: 24),
          _navBtn(Iconsax.arrow_right_3, () => carousel.nextPage()),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF0F172A))), child: Icon(icon, size: 16, color: const Color(0xFF0F172A))));
  }

  Widget _buildActionHUD(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _actionBtn('ABSENT', const Color(0xFFEF4444), () => _mark(controller, attendanceController, carousel, 'absent')),
          const SizedBox(width: 12),
          _actionBtn('LATE', const Color(0xFFF59E0B), () => _mark(controller, attendanceController, carousel, 'late')),
          const SizedBox(width: 12),
          _actionBtn('PRESENT', const Color(0xFF10B981), () => _mark(controller, attendanceController, carousel, 'present')),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: color, border: Border.all(color: const Color(0xFF0F172A), width: 2)),
          child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
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
