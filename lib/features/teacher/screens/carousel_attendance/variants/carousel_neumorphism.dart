import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';

class CarouselNeumorphism extends StatelessWidget {
  const CarouselNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();
    const bgColor = Color(0xFFE0E5EC);

    return Container(
      color: bgColor,
      child: Obx(() {
        if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (attendanceController.students.isEmpty) return _buildEmptyState();

        return Column(
          children: [
            _buildNeuTimer(controller, bgColor),
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
                  return _buildNeuStudentCard(student, attendanceController, bgColor);
                },
              ),
            ),
            _buildNavNeu(controller, attendanceController.students.length, bgColor),
            _buildActionNeu(controller, attendanceController, carouselController, bgColor),
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
        children: const [
          Icon(Iconsax.people, size: 64, color: Color(0xFFCBD5E1)),
          SizedBox(height: 16),
          Text('No Students Found', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4D565F))),
        ],
      ),
    );
  }

  Widget _buildNeuTimer(CarouselAttendanceController controller, Color bgColor) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
            BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
          ],
        ),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildNeuStudentCard(dynamic student, dynamic attendanceController, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(10, 10), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8, inset: true),
                BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8, inset: true),
              ],
            ),
            child: const Icon(Iconsax.user, size: 52, color: Color(0xFFA3B1C6)),
          ),
          const SizedBox(height: 24),
          Text(student.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF4D565F), letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Text(status.toUpperCase(), style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2));
          }),
        ],
      ),
    );
  }

  Widget _buildNavNeu(CarouselAttendanceController controller, int total, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Obx(() => Text('${controller.currentIndex.value + 1} / $total', style: const TextStyle(color: Color(0xFFA3B1C6), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5))),
    );
  }

  Widget _buildActionNeu(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _neuActionBtn(Iconsax.close_circle, Colors.redAccent, () => _mark(controller, attendanceController, carousel, 'absent'), bgColor),
          const SizedBox(width: 32),
          _neuActionBtn(Iconsax.clock, Colors.orangeAccent, () => _mark(controller, attendanceController, carousel, 'late'), bgColor),
          const SizedBox(width: 32),
          _neuActionBtn(Iconsax.tick_circle, Colors.greenAccent, () => _mark(controller, attendanceController, carousel, 'present'), bgColor),
        ],
      ),
    );
  }

  Widget _neuActionBtn(IconData icon, Color color, VoidCallback onTap, Color bgColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
            BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
          ],
        ),
        child: Icon(icon, color: color, size: 32),
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
