import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/models/student_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/widgets/student_avatar.dart';
import 'package:smart_campus/common/utils/helpers/snackbar_helper.dart';

class MarkAttendanceBrutalist extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceBrutalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.brutalistBold, isDark: isDark);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'RECORDING_SHEET',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1.0, color: Colors.black),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: const Icon(Iconsax.refresh, color: Colors.black, size: 32)),
        ],
      ),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'FILE_LOCKED', title: 'CLOSED');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              icon: const Icon(Iconsax.save_2, size: 28),
              label: const Text('SUBMIT_DATA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Colors.black, width: 4)),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: Colors.black));
        if (controller.students.isEmpty) return const Center(child: Text("NO_STUDENT_DATA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)));

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
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : OutlinedButton(
                          onPressed: controller.loadMoreStudents, 
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black, width: 2), foregroundColor: Colors.black, shape: const RoundedRectangleBorder()),
                          child: const Text("FETCH_MORE", style: TextStyle(fontWeight: FontWeight.w900))),
                  ),
                );
              }
              final student = controller.students[index];
              return _buildBrutalistStudentRow(context, student, isSessionRunning);
            },
          ),
        );
      }),
    );
  }

  Widget _buildBrutalistStudentRow(BuildContext context, StudentModel student, bool isSessionRunning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                  child: StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 50, isDarkMode: false),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name.toUpperCase() ?? 'NAME_MISSING', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, height: 1.0)),
                      const SizedBox(height: 4),
                      Text("ID_${student.rollNumber ?? "?"}", style: const TextStyle(fontWeight: FontWeight.w900, backgroundColor: Colors.black, color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildBrutalistToggle('present', 'PRESENT', student, isSessionRunning, Colors.greenAccent),
                const SizedBox(width: 8),
                _buildBrutalistToggle('absent', 'ABSENT', student, isSessionRunning, Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrutalistToggle(String value, String label, StudentModel student, bool isSessionRunning, Color activeColor) {
    final isSelected = student.attendanceStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: isSessionRunning ? () => controller.updateStudentStatus(student.id, value) : null,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 12)),
        ),
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 6)),
        title: const Text("SUBMIT_REPORT?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        content: const Text("ATTENDANCE DATA WILL BE WRITTEN TO DATABASE.", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("STAY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(onPressed: () { Get.back(); controller.submitAttendance(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: const RoundedRectangleBorder()), child: const Text("SEND")),
        ],
      ),
    );
  }
}
