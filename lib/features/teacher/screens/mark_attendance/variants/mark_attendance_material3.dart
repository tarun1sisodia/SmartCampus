import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/models/student_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/widgets/student_avatar.dart';
import 'package:smart_campus/common/utils/helpers/snackbar_helper.dart';

class MarkAttendanceMaterial3 extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceMaterial3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.material3, isDark: isDark);
    final colorScheme = Theme.of(context).colorScheme;

    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Mark Attendance',
          style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: -0.5, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: const Icon(Iconsax.refresh)),
        ],
      ),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'This session is closed', title: 'Session Closed');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              icon: const Icon(Iconsax.tick_circle),
              label: const Text('Submit Attendance'),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.students.isEmpty) return const Center(child: Text("No students available"));

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForSession(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: controller.students.length + (controller.hasMoreStudents.value ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              if (index >= controller.students.length) {
                return Center(child: Padding(padding: const EdgeInsets.all(24.0),
                  child: controller.isLoadingMoreStudents.value 
                    ? const CircularProgressIndicator() 
                    : OutlinedButton(onPressed: controller.loadMoreStudents, child: const Text("Load More")),
                ));
              }
              final student = controller.students[index];
              return _buildM3StudentItem(context, student, isSessionRunning, colorScheme);
            },
          ),
        );
      }),
    );
  }

  Widget _buildM3StudentItem(BuildContext context, StudentModel student, bool isSessionRunning, ColorScheme colorScheme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: colorScheme.brightness == Brightness.dark),
      title: Text(student.name ?? "Student", style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("ID: ${student.rollNumber ?? 'N/A'}", style: TextStyle(color: colorScheme.outline, fontSize: 13)),
      trailing: _buildM3StatusMenu(context, student, isSessionRunning, colorScheme),
    );
  }

  Widget _buildM3StatusMenu(BuildContext context, StudentModel student, bool isSessionRunning, ColorScheme colorScheme) {
    return ChoiceChip(
      label: Text((student.attendanceStatus ?? 'absent').toUpperCase()),
      selected: true,
      onSelected: isSessionRunning ? (val) => _showStatusPicker(context, student) : null,
      selectedColor: _getStatusSecondaryColor(student.attendanceStatus, colorScheme),
      labelStyle: TextStyle(color: _getStatusMainColor(student.attendanceStatus, colorScheme), fontWeight: FontWeight.bold, fontSize: 11),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showStatusPicker(BuildContext context, StudentModel student) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildStatusOption(context, 'present', 'PRESENT', Iconsax.tick_circle, Colors.green, student),
            _buildStatusOption(context, 'absent', 'ABSENT', Iconsax.close_circle, Colors.red, student),
            _buildStatusOption(context, 'late', 'LATE', Iconsax.clock, Colors.orange, student),
            _buildStatusOption(context, 'excused', 'EXCUSED', Iconsax.document_text, Colors.blue, student),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(BuildContext context, String value, String label, IconData icon, Color color, StudentModel student) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        controller.updateStudentStatus(student.id, value);
        Get.back();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Color _getStatusMainColor(String? status, ColorScheme colorScheme) {
    switch (status) {
      case 'present': return Colors.green;
      case 'absent': return Colors.red;
      case 'late': return Colors.orange;
      case 'excused': return Colors.blue;
      default: return colorScheme.primary;
    }
  }

  Color _getStatusSecondaryColor(String? status, ColorScheme colorScheme) {
    switch (status) {
      case 'present': return Colors.green.withValues(alpha: 0.1);
      case 'absent': return Colors.red.withValues(alpha: 0.1);
      case 'late': return Colors.orange.withValues(alpha: 0.1);
      case 'excused': return Colors.blue.withValues(alpha: 0.1);
      default: return colorScheme.secondaryContainer;
    }
  }

  void _showSubmitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Submit Records?"),
        content: const Text("This action will sync current attendance to the cloud database."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          FilledButton(onPressed: () { Navigator.pop(context); controller.submitAttendance(); }, child: const Text("SUBMIT")),
        ],
      ),
    );
  }
}
