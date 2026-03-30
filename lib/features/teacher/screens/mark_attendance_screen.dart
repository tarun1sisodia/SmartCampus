import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/routes/app_routes.dart';
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
        message: 'This session is currently closed. You can view but not modify attendance.',
        title: 'Session Closed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width <= 500;
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);
    final cardPadding = isMobile ? (isLandscape ? TSizes.xs : TSizes.sm) : (isLandscape ? TSizes.sm : TSizes.md);

    final isSessionRunning = attendanceController.currentSessionId.value.isNotEmpty &&
        attendanceController.isSessionRunning(attendanceController.currentSessionId.value);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance', style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          IconButton(onPressed: () => attendanceController.loadStudentsForSession(), icon: const Icon(Iconsax.refresh), tooltip: 'Refresh'),
          IconButton(
            onPressed: () {
              if (!isSessionRunning) {
                TSnackBar.showInfo(message: 'This session is currently closed', title: 'Session Closed');
                return;
              }
              Get.toNamed(AppRoutes.carouselAttendance);
            },
            icon: const Icon(Iconsax.slider_horizontal_1),
            tooltip: 'Carousel View',
          ),
        ],
      ),
      floatingActionButton: Obx(() => attendanceController.isStudentsLoaded.value
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'Cannot submit attendance for a closed session', title: 'Session Closed');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(Iconsax.tick_square),
              label: const Text('Submit Attendance'),
              elevation: 4,
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (attendanceController.isLoading.value) return _buildLoadingState(context);
        if (attendanceController.currentSessionId.value.isEmpty) return _buildEmptyState(context, Iconsax.calendar_1, 'No Session Selected', 'Please select an attendance session');
        if (attendanceController.students.isEmpty) return _buildEmptyState(context, Iconsax.people, 'No Students Found', 'Add students to this class to take attendance');

        return RefreshIndicator(
          onRefresh: () => attendanceController.loadStudentsForSession(),
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).cardTheme.color,
          child: ListView.builder(
            padding: EdgeInsets.all(isMobile ? TSizes.sm : TSizes.defaultSpace),
            itemCount: attendanceController.students.length + (attendanceController.hasMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= attendanceController.students.length) return _buildLoadMoreFooter(context);

              final student = attendanceController.students[index];
              return _buildStudentCard(context, student, cardPadding, isMobile, isLandscape, isSessionRunning);
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
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            child: const Icon(Iconsax.user, size: 80),
          ),
          const SizedBox(height: TSizes.md),
          Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Container(width: 140, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
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
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: TSizes.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, dynamic student, double padding, bool isMobile, bool isLandscape, bool isSessionRunning) {
    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems / 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: TSizes.xs),
        leading: StudentAvatar(
          imageUrl: student.imageUrl,
          name: student.name,
          size: 44,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
        title: Text(
          student.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: isMobile ? 15 : 17),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Roll: ${student.rollNumber}', style: Theme.of(context).textTheme.labelSmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: DropdownButton<String>(
            value: student.attendanceStatus ?? 'absent',
            isDense: true,
            dropdownColor: Theme.of(context).colorScheme.surface,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: _getStatusColor(student.attendanceStatus, context)),
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onChanged: isSessionRunning ? (value) => attendanceController.updateStudentStatus(student.id, value!) : null,
            items: const [
              DropdownMenuItem(value: 'present', child: Text('Present')),
              DropdownMenuItem(value: 'absent', child: Text('Absent')),
              DropdownMenuItem(value: 'late', child: Text('Late')),
              DropdownMenuItem(value: 'excused', child: Text('Excused')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.md),
      child: Center(
        child: attendanceController.isLoadingMoreStudents.value
            ? const CircularProgressIndicator()
            : OutlinedButton(onPressed: attendanceController.loadMoreStudents, child: const Text('Load More')),
      ),
    );
  }

  Color _getStatusColor(String? status, BuildContext context) {
    switch (status) {
      case 'present': return Colors.green;
      case 'absent': return Colors.red;
      case 'late': return Colors.orange;
      case 'excused': return Colors.blue;
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.defaultDialog(
      title: 'Submit Attendance',
      middleText: 'Are you sure you want to finalize the attendance for this session?',
      textConfirm: 'Submit',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Theme.of(context).colorScheme.primary,
      onConfirm: () {
        Get.back();
        attendanceController.submitAttendance();
      },
    );
  }
}
