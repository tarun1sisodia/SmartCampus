import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/models/student_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/widgets/student_avatar.dart';
import 'package:smart_campus/common/utils/helpers/snackbar_helper.dart';

class MarkAttendanceAcademic extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceAcademic({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.academicClassic, isDark: isDark);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFDFCF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Student Ledger',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'serif', color: isDark ? Colors.white70 : Colors.brown[800]),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: Icon(Iconsax.refresh, color: isDark ? Colors.white24 : Colors.brown[300])),
        ],
      ),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? FloatingActionButton(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'The ledger is currently sealed.', title: 'Sealed');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              backgroundColor: Colors.brown[700],
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Iconsax.document_upload),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: Colors.brown));
        if (controller.students.isEmpty) return const Center(child: Text("—— RECORDS EMPTY ——", style: TextStyle(fontFamily: 'serif', color: Colors.grey)));

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForSession(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            itemCount: controller.students.length + (controller.hasMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.students.length) {
                return Center(child: Padding(padding: const EdgeInsets.all(24.0),
                  child: controller.isLoadingMoreStudents.value 
                    ? const CircularProgressIndicator(color: Colors.brown) 
                    : TextButton(onPressed: controller.loadMoreStudents, child: const Text("FETCH_REMAINDER", style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown))),
                ));
              }
              final student = controller.students[index];
              return _buildAcademicStudentRow(context, student, isSessionRunning, isDark);
            },
          ),
        );
      }),
    );
  }

  Widget _buildAcademicStudentRow(BuildContext context, StudentModel student, bool isSessionRunning, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.brown.withValues(alpha: 0.15))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Column(
              children: [
                StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 40, isDarkMode: isDark),
                const SizedBox(height: 4),
                Text(student.rollNumber ?? "?", style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.brown[300])),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                student.name ?? 'Unidentified',
                style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            _buildAcademicStatusIcon(student, isSessionRunning, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicStatusIcon(StudentModel student, bool isSessionRunning, bool isDark) {
    return PopupMenuButton<String>(
      onSelected: isSessionRunning ? (val) => controller.updateStudentStatus(student.id, val) : null,
      initialValue: student.attendanceStatus,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'present', child: Text('Present')),
        const PopupMenuItem(value: 'absent', child: Text('Absent')),
        const PopupMenuItem(value: 'late', child: Text('Late')),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: _getStatusColor(student.attendanceStatus).withValues(alpha: 0.3)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getStatusIcon(student.attendanceStatus),
          size: 18,
          color: _getStatusColor(student.attendanceStatus),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'present': return Iconsax.tick_circle;
      case 'absent': return Iconsax.close_circle;
      case 'late': return Iconsax.clock;
      default: return Iconsax.forbidden_2;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'present': return Colors.green[700]!;
      case 'absent': return Colors.red[700]!;
      case 'late': return Colors.orange[700]!;
      default: return Colors.brown[300]!;
    }
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFFFDFCF0),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text("Submit Ledger Records", style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
        content: const Text("This action will record the current attendance session to the permanent archive.", style: TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(onPressed: () { Get.back(); controller.submitAttendance(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700], shape: const RoundedRectangleBorder()), child: const Text("SUBMIT")),
        ],
      ),
    );
  }
}
