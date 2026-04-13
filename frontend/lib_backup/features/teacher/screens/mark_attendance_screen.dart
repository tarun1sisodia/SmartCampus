import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/routes/app_routes.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../common/utils/device/device_utility.dart';
import '../../../common/widgets/student_avatar.dart';
import '../controllers/attendance_controller.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';

class MarkAttendanceScreen extends StatelessWidget {
  final attendanceController = Get.find<AttendanceController>();

  MarkAttendanceScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSessionStatus());
  }

  void _checkSessionStatus() {
    if (attendanceController.currentSessionId.value.isNotEmpty &&
        !attendanceController.isSessionRunning(attendanceController.currentSessionId.value)) {
      TSnackBar.showInfo(
        message: 'THIS SESSION IS CURRENTLY CLOSED. DATA CANNOT BE MODIFIED.',
        title: 'SESSION CLOSED',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width <= 500;
    
    final isSessionRunning = attendanceController.currentSessionId.value.isNotEmpty &&
        attendanceController.isSessionRunning(attendanceController.currentSessionId.value);

    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Text(
          'MARK ATTENDANCE', 
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0)
        ),
        actions: [
          IconButton(onPressed: () => attendanceController.loadStudentsForSession(), icon: const Icon(Iconsax.refresh, color: TColors.slate900)),
          IconButton(
            onPressed: () {
              if (!isSessionRunning) {
                TSnackBar.showInfo(message: 'THIS SESSION IS CURRENTLY CLOSED', title: 'SESSION CLOSED');
                return;
              }
              Get.toNamed(AppRoutes.carouselAttendance);
            },
            icon: const Icon(Iconsax.slider_horizontal_1, color: TColors.executiveNavy),
            tooltip: 'Carousel View',
          ),
        ],
      ),
      floatingActionButton: Obx(() => attendanceController.isStudentsLoaded.value
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'CANNOT SUBMIT ATTENDANCE FOR A CLOSED SESSION', title: 'SESSION CLOSED');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              backgroundColor: TColors.executiveNavy,
              foregroundColor: Colors.white,
              icon: const Icon(Iconsax.tick_square, size: 20),
              label: const Text('SUBMIT ATTENDANCE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.white, width: 1.5)),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (attendanceController.isLoading.value) return _buildLoadingState(context);
        if (attendanceController.currentSessionId.value.isEmpty) return _buildEmptyState(context, Iconsax.calendar_1, 'NO SESSION SELECTED', 'PLEASE SELECT AN ATTENDANCE SESSION');
        if (attendanceController.students.isEmpty) return _buildEmptyState(context, Iconsax.people, 'NO STUDENTS FOUND', 'ADD STUDENTS TO THIS CLASS TO TAKE ATTENDANCE');

        return RefreshIndicator(
          onRefresh: () => attendanceController.loadStudentsForSession(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: attendanceController.students.length + (attendanceController.hasMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= attendanceController.students.length) return _buildLoadMoreFooter(context);

              final student = attendanceController.students[index];
              return _buildStudentCard(context, student, isMobile, isSessionRunning);
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: TColors.slate200,
            highlightColor: TColors.blue100,
            child: const Icon(Iconsax.user, size: 80),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: TColors.slate200,
            highlightColor: TColors.blue100,
            child: Container(width: 140, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: TColors.slate300),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TColors.slate900)),
          Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: TColors.slate600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, dynamic student, bool isMobile, bool isSessionRunning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: StudentAvatar(
          imageUrl: student.imageUrl,
          name: student.name,
          size: 48,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
        title: Text(
          (student.name ?? 'STUDENT').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: TColors.slate900, letterSpacing: -0.5),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'ROLL: ${student.rollNumber ?? 'N/A'}'.toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: TColors.slate600, letterSpacing: 0.5)
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: TColors.slate50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: TColors.executiveNavy, width: 1.0),
          ),
          child: DropdownButton<String>(
            value: student.attendanceStatus ?? 'absent',
            isDense: true,
            dropdownColor: TColors.white,
            borderRadius: BorderRadius.circular(4),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: _getStatusColor(student.attendanceStatus)),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: TColors.executiveNavy, size: 20),
            onChanged: isSessionRunning ? (value) => attendanceController.updateStudentStatus(student.id, value!) : null,
            items: const [
              DropdownMenuItem(value: 'present', child: Text('PRESENT')),
              DropdownMenuItem(value: 'absent', child: Text('ABSENT')),
              DropdownMenuItem(value: 'late', child: Text('LATE')),
              DropdownMenuItem(value: 'excused', child: Text('EXCUSED')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: attendanceController.isLoadingMoreStudents.value
            ? const CircularProgressIndicator()
            : OutlinedButton(onPressed: attendanceController.loadMoreStudents, child: const Text('LOAD MORE')),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'present': return const Color(0xFF10B981); // emerald-500
      case 'absent': return const Color(0xFFEF4444); // red-500
      case 'late': return const Color(0xFFF59E0B); // amber-500
      case 'excused': return const Color(0xFF3B82F6); // blue-500
      default: return TColors.executiveNavy;
    }
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: TColors.executiveNavy, width: 2.0)),
        backgroundColor: TColors.white,
        title: const Text('SUBMIT ATTENDANCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: const Text(
          'ARE YOU SURE YOU WANT TO FINALIZE THE ATTENDANCE FOR THIS SESSION? DATA WILL BE SYNCED TO THE CLOUD.',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: TColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: const Text('CANCEL', style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900))
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              attendanceController.submitAttendance();
            },
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
}
