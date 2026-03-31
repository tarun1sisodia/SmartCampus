import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShape, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, Badge, CircleAxis, CircleAvatar, TextSelectionTheme, TextSelectionThemeData, TextFormField, InputDecoration, InputBorder, OutlineInputBorder, FileImage, Chip;
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../controllers/carousel_attendance_controller.dart';
import '../widgets/session_timer_widget.dart';

class CarouselCupertino extends StatelessWidget {
  const CarouselCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CarouselAttendanceController>();
    final attendanceController = controller.attendanceController;
    final CarouselSliderController carouselController = CarouselSliderController();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Attendance Carousel'),
        backgroundColor: Color(0xFFF2F2F7),
        border: null,
      ),
      child: Obx(() {
        if (attendanceController.isLoading.value) return const Center(child: CupertinoActivityIndicator());
        if (attendanceController.students.isEmpty) return _buildEmptyState();

        return Column(
          children: [
            const SizedBox(height: 16),
            _buildIosTimer(controller),
            const SizedBox(height: 16),
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
                  return _buildIosStudentCard(student, attendanceController);
                },
              ),
            ),
            _buildNavIos(controller, attendanceController.students.length),
            _buildActionIos(controller, attendanceController, carouselController),
            const SizedBox(height: 64),
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
          Icon(CupertinoIcons.person_3_fill, size: 64, color: Color(0xFF8E8E93)),
          SizedBox(height: 16),
          Text('No Students Found', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 17)),
        ],
      ),
    );
  }

  Widget _buildIosTimer(CarouselAttendanceController controller) {
    return Obx(() {
      if (!controller.isTimerRunning.value) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: SessionTimerWidget(remainingTime: controller.remainingTime.value, isSessionActive: true, isCountdownMode: true),
      );
    });
  }

  Widget _buildIosStudentCard(dynamic student, dynamic attendanceController) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 60, backgroundColor: const Color(0xFF007AFF).withOpacity(0.1), child: const Icon(CupertinoIcons.person_fill, size: 56, color: Color(0xFF007AFF))),
          const SizedBox(height: 24),
          Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF000000), letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Obx(() {
            final status = attendanceController.getStudentStatus(student.id);
            return Text(status.toUpperCase(), style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5));
          }),
        ],
      ),
    );
  }

  Widget _buildNavIos(CarouselAttendanceController controller, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Obx(() => Text('${controller.currentIndex.value + 1} of $total', style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 13))),
    );
  }

  Widget _buildActionIos(CarouselAttendanceController controller, dynamic attendanceController, CarouselSliderController carousel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _iosActionBtn(CupertinoIcons.xmark_circle_fill, const Color(0xFFFF3B30), () => _mark(controller, attendanceController, carousel, 'absent')),
        const SizedBox(width: 40),
        _iosActionBtn(CupertinoIcons.clock_fill, const Color(0xFFFF9500), () => _mark(controller, attendanceController, carousel, 'late')),
        const SizedBox(width: 40),
        _iosActionBtn(CupertinoIcons.checkmark_circle_fill, const Color(0xFF34C759), () => _mark(controller, attendanceController, carousel, 'present')),
      ],
    );
  }

  Widget _iosActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Icon(icon, color: color, size: 54),
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
