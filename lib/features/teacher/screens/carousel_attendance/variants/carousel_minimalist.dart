import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../controllers/carousel_attendance_controller.dart';
import '../../../widgets/session_timer_widget.dart';

class CarouselMinimalist extends StatelessWidget {
  const CarouselMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();

    return Container(
      color: Colors.white,
      child: Obx(() {
        if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (attendanceController.students.isEmpty) return _buildEmptyState();

        return Column(
          children: [
            _buildTimerMinimal(controller),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: attendanceController.students.length,
                options: CarouselOptions(
                  height: 380,
                  viewportFraction: 0.8,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => controller.currentIndex.value = index,
                ),
                itemBuilder: (context, index, realIndex) {
                  final student = attendanceController.students[index];
                  return _buildMinimalStudentCard(student, attendanceController);
                },
              ),
            ),
            _buildNavMinimal(controller, carouselController, attendanceController.students.length),
            _buildActionMinimal(controller, attendanceController, carouselController),
            const SizedBox(height: 48),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text('No Students Found', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildTimerMinimal(CarouselAttendanceController controller) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildMinimalStudentCard(dynamic student, dynamic attendanceController) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 30, offset: const Offset(0, 15))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle), child: const Icon(Iconsax.user, size: 48, color: Colors.black12)),
          const SizedBox(height: 24),
          Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Text(status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: status == 'present' ? Colors.green[300] : (status == 'absent' ? Colors.red[300] : Colors.orange[300]), letterSpacing: 1));
          }),
        ],
      ),
    );
  }

  Widget _buildNavMinimal(CarouselAttendanceController controller, CarouselSliderController carousel, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Obx(() => Text('${controller.currentIndex.value + 1} of $total', style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w500, fontSize: 13))),
    );
  }

  Widget _buildActionMinimal(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _miniBtn(Iconsax.close_circle, Colors.red[400]!, () => _mark(controller, attendanceController, carousel, 'absent')),
          const SizedBox(width: 32),
          _miniBtn(Iconsax.clock, Colors.orange[400]!, () => _mark(controller, attendanceController, carousel, 'late')),
          const SizedBox(width: 32),
          _miniBtn(Iconsax.tick_circle, Colors.green[400]!, () => _mark(controller, attendanceController, carousel, 'present')),
        ],
      ),
    );
  }

  Widget _miniBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color.withValues(alpha: 0.05), shape: BoxShape.circle), child: Icon(icon, color: color, size: 32)));
  }

  void _mark(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel, String status) {
    final student = controller.currentStudent;
    if (student != null) {
      attendanceController.updateStudentStatus(student.id, status);
      if (!controller.isLastStudent) carousel.nextPage();
    }
  }
}
