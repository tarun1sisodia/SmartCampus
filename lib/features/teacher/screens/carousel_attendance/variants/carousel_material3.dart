import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';

class CarouselMaterial3 extends StatelessWidget {
  const CarouselMaterial3({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Obx(() {
        if (attendanceController.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (attendanceController.students.isEmpty) return _buildEmptyState(theme);

        return Column(
          children: [
            _buildM3Timer(controller, theme),
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
                  return _buildM3StudentCard(student, attendanceController, theme);
                },
              ),
            ),
            _buildNavM3(controller, attendanceController.students.length, theme),
            _buildActionM3(controller, attendanceController, carouselController, theme),
            const SizedBox(height: 48),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No Students Found', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildM3Timer(CarouselAttendanceController controller, ThemeData theme) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(24)),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildM3StudentCard(dynamic student, dynamic attendanceController, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 60, backgroundColor: theme.colorScheme.primaryContainer, child: Icon(Iconsax.user, size: 56, color: theme.colorScheme.onPrimaryContainer)),
          const SizedBox(height: 32),
          Text(student.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 12),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Text(status.toUpperCase(), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.black, letterSpacing: 1.5));
          }),
        ],
      ),
    );
  }

  Widget _buildNavM3(CarouselAttendanceController controller, int total, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Obx(() => Text('${controller.currentIndex.value + 1} / $total', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildActionM3(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _m3ActionBtn(Iconsax.close_circle, theme.colorScheme.error, () => _mark(controller, attendanceController, carousel, 'absent'), theme),
          const SizedBox(width: 24),
          _m3ActionBtn(Iconsax.clock, theme.colorScheme.secondary, () => _mark(controller, attendanceController, carousel, 'late'), theme),
          const SizedBox(width: 24),
          _m3ActionBtn(Iconsax.tick_circle, theme.colorScheme.primary, () => _mark(controller, attendanceController, carousel, 'present'), theme),
        ],
      ),
    );
  }

  Widget _m3ActionBtn(IconData icon, Color color, VoidCallback onTap, ThemeData theme) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 32),
      style: IconButton.styleFrom(padding: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
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
