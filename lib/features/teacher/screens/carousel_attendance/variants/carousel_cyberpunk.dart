import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';

class CarouselCyberpunk extends StatelessWidget {
  const CarouselCyberpunk({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);
    const yellow = Color(0xFFFFCC00);

    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          Obx(() {
            if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator(color: cyan));
            if (attendanceController.students.isEmpty) return _buildEmptyState(magenta);

            return Column(
              children: [
                _buildCyberTimer(controller, cyan, magenta),
                Expanded(
                  child: CarouselSlider.builder(
                    carouselController: carouselController,
                    itemCount: attendanceController.students.length,
                    options: CarouselOptions(
                      height: 420,
                      viewportFraction: 0.82,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) => controller.currentIndex.value = index,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      final student = attendanceController.students[index];
                      return _buildCyberStudentCard(student, attendanceController, cyan, magenta);
                    },
                  ),
                ),
                _buildNavCyber(controller, attendanceController.students.length, cyan),
                _buildActionCyber(controller, attendanceController, carouselController, cyan, magenta, yellow),
                const SizedBox(height: 64),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter(color: cyan.withValues(alpha: 0.04))));
  }

  Widget _buildEmptyState(Color magenta) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 64, color: magenta.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('NO_NODES_FOUND', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildCyberTimer(CarouselAttendanceController controller, Color cyan, Color magenta) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan, width: 2), boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.2), blurRadius: 10)]),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildCyberStudentCard(dynamic student, dynamic attendanceController, Color cyan, Color magenta) {
    return Container(
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan.withValues(alpha: 0.3), width: 2), boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.1), blurRadius: 20)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 120, height: 120, decoration: BoxDecoration(border: Border.all(color: cyan), shape: BoxShape.circle), child: Center(child: Icon(Iconsax.user, size: 64, color: cyan))),
          const SizedBox(height: 32),
          Text(student.name.toUpperCase(), style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1, fontFamily: 'Courier')),
          const SizedBox(height: 16),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Text('STAT: ${status.toUpperCase()}', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier'));
          }),
        ],
      ),
    );
  }

  Widget _buildNavCyber(CarouselAttendanceController controller, int total, Color cyan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Obx(() => Text('NODE_SYNC: ${controller.currentIndex.value + 1} / $total', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Courier'))),
    );
  }

  Widget _buildActionCyber(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel, Color cyan, Color magenta, Color yellow) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _cyberActionBtn('ABS', magenta, () => _mark(controller, attendanceController, carousel, 'absent')),
          const SizedBox(width: 16),
          _cyberActionBtn('LAT', yellow, () => _mark(controller, attendanceController, carousel, 'late')),
          const SizedBox(width: 16),
          _cyberActionBtn('PRE', cyan, () => _mark(controller, attendanceController, carousel, 'present')),
        ],
      ),
    );
  }

  Widget _cyberActionBtn(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: color, width: 2), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)]),
          child: Center(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Courier'))),
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

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
