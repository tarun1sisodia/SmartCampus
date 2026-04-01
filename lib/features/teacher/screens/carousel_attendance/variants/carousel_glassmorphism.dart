import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';

class CarouselGlassmorphism extends StatelessWidget {
  const CarouselGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() {
          if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (attendanceController.students.isEmpty) return _buildEmptyState();

          return Column(
            children: [
              _buildGlassTimer(controller),
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
                    return _buildGlassStudentCard(student, attendanceController);
                  },
                ),
              ),
              _buildNavGlass(controller, attendanceController.students.length),
              _buildActionGlass(controller, attendanceController, carouselController),
              const SizedBox(height: 48),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Iconsax.people, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text('No Students Found', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildGlassTimer(CarouselAttendanceController controller) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: _glassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
        ),
      );
    });
  }

  Widget _buildGlassStudentCard(dynamic student, dynamic attendanceController) {
    return _glassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 110, height: 110, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Iconsax.user, size: 56, color: Colors.white54)),
          const SizedBox(height: 24),
          Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavGlass(CarouselAttendanceController controller, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Obx(() => Text('${controller.currentIndex.value + 1} / $total', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1))),
    );
  }

  Widget _buildActionGlass(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _glassActionBtn(Iconsax.close_circle, Colors.redAccent, () => _mark(controller, attendanceController, carousel, 'absent')),
          const SizedBox(width: 24),
          _glassActionBtn(Iconsax.clock, Colors.orangeAccent, () => _mark(controller, attendanceController, carousel, 'late')),
          const SizedBox(width: 24),
          _glassActionBtn(Iconsax.tick_circle, Colors.greenAccent, () => _mark(controller, attendanceController, carousel, 'present')),
        ],
      ),
    );
  }

  Widget _glassActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: _glassContainer(
        padding: const EdgeInsets.all(16),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
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
