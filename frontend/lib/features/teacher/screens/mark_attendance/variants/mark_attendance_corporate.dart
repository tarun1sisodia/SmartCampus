import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/models/student_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/widgets/student_avatar.dart';
import 'package:smart_campus/common/utils/helpers/snackbar_helper.dart';

class MarkAttendanceCorporate extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceCorporate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.industrialCorporate, isDark: isDark);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MARK ATTENDANCE',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: const Icon(Iconsax.refresh, color: Colors.black)),
        ],
      ),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'SESSION CLOSED', title: 'CLOSED');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              icon: const Icon(Iconsax.tick_square, size: 20),
              label: const Text('SUBMIT DATA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Colors.white, width: 2)),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: Colors.black));
        if (controller.students.isEmpty) return const Center(child: Text("NO DATA AVAILABLE", style: TextStyle(fontWeight: FontWeight.w900)));

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForSession(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: controller.students.length + (controller.hasMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.students.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: controller.isLoadingMoreStudents.value 
                      ? const CircularProgressIndicator() 
                      : TextButton(onPressed: controller.loadMoreStudents, child: const Text("LOAD_MORE_RECORDS", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black))),
                  ),
                );
              }
              final student = controller.students[index];
              return _buildCorporateStudentRow(context, student, isSessionRunning, tokens);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCorporateStudentRow(BuildContext context, StudentModel student, bool isSessionRunning, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 40, isDarkMode: false),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name.toUpperCase() ?? 'STUDENT', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.5)),
                  Text("SERIAL: ${student.rollNumber ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            _buildStatusSelector(student, isSessionRunning),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector(StudentModel student, bool isSessionRunning) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
      child: DropdownButton<String>(
        value: student.attendanceStatus ?? 'absent',
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black, size: 18),
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _getStatusColor(student.attendanceStatus)),
        onChanged: isSessionRunning ? (val) => controller.updateStudentStatus(student.id, val!) : null,
        items: const [
          DropdownMenuItem(value: 'present', child: Text('PRESENT')),
          DropdownMenuItem(value: 'absent', child: Text('ABSENT')),
          DropdownMenuItem(value: 'late', child: Text('LATE')),
          DropdownMenuItem(value: 'excused', child: Text('EXCUSED')),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'present': return const Color(0xFF10B981);
      case 'absent': return const Color(0xFFEF4444);
      case 'late': return const Color(0xFFF59E0B);
      case 'excused': return const Color(0xFF3B82F6);
      default: return Colors.black;
    }
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(width: 4)),
        title: const Text("FINALIZE DATA", style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text("PROCEDURE WILL SYNC ALL RECORDS TO CENTRAL SERVER.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("ABORT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(onPressed: () { Get.back(); controller.submitAttendance(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const RoundedRectangleBorder()), child: const Text("EXECUTE")),
        ],
      ),
    );
  }
}
