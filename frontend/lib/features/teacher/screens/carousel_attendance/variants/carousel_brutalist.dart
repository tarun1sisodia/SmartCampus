import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../controllers/carousel_attendance_controller.dart';
import '../../../widgets/session_timer_widget.dart';

class CarouselBrutalist extends StatelessWidget {
  const CarouselBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();

    return Container(
      color: Colors.white,
      child: Obx(() {
        if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator(color: Colors.black));
        if (attendanceController.students.isEmpty) return _buildEmptyState(orange);

        return Column(
          children: [
            _buildBrutalTimer(controller, yellow),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: attendanceController.students.length,
                options: CarouselOptions(
                  height: 420,
                  viewportFraction: 0.85,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => controller.currentIndex.value = index,
                ),
                itemBuilder: (context, index, realIndex) {
                  final student = attendanceController.students[index];
                  return _buildBrutalStudentCard(student, attendanceController, yellow, orange, blue);
                },
              ),
            ),
            _buildNavBrutal(controller, attendanceController.students.length, blue),
            _buildActionBrutal(controller, attendanceController, carouselController, yellow, orange, blue),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(Color orange) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 64, color: orange.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('NO_NODES_FOUND', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildBrutalTimer(CarouselAttendanceController controller, Color yellow) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: yellow, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))]),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildBrutalStudentCard(dynamic student, dynamic attendanceController, Color yellow, Color orange, Color blue) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 4), boxShadow: [BoxShadow(color: yellow, offset: const Offset(12, 12))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 120, height: 120, decoration: BoxDecoration(color: orange, border: Border.all(color: Colors.black, width: 2), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))]), child: const Center(child: Icon(Iconsax.user, size: 64, color: Colors.black))),
          const SizedBox(height: 32),
          Text(student.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 1)),
          const SizedBox(height: 16),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), color: Colors.black, child: Text('STAT: ${status.toUpperCase()}', style: TextStyle(color: yellow, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)));
          }),
        ],
      ),
    );
  }

  Widget _buildNavBrutal(CarouselAttendanceController controller, int total, Color blue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Obx(() => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), color: blue, child: Text('NODE: ${controller.currentIndex.value + 1} / $total', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: Colors.white)))),
    );
  }

  Widget _buildActionBrutal(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel, Color yellow, Color orange, Color blue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _brutalActionBtn('ABS', orange, () => _mark(controller, attendanceController, carousel, 'absent')),
          const SizedBox(width: 16),
          _brutalActionBtn('LAT', yellow, () => _mark(controller, attendanceController, carousel, 'late')),
          const SizedBox(width: 16),
          _brutalActionBtn('PRE', blue, () => _mark(controller, attendanceController, carousel, 'present')),
        ],
      ),
    );
  }

  Widget _brutalActionBtn(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: color, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
          child: Center(child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2))),
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
