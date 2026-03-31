import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/models/student_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/widgets/student_avatar.dart';
import 'package:smart_campus/common/utils/helpers/snackbar_helper.dart';

class MarkAttendanceCyberpunk extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceCyberpunk({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.cyberpunkNeon, isDark: isDark);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'UNIT_STATUS_REPORT',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: TColors.deepOceanCyan, letterSpacing: 2, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: const Icon(Iconsax.radar, color: TColors.deepOceanCyan)),
        ],
      ),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'SYS_RECORDS_LOCKED', title: 'CLOSED');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              backgroundColor: Colors.black,
              foregroundColor: TColors.deepOceanCyan,
              icon: const Icon(Iconsax.send_1, size: 20),
              label: const Text('EXECUTE_SYNC', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              elevation: 0,
              shape: const RoundedRectangleBorder(side: BorderSide(color: TColors.deepOceanCyan, width: 2)),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: TColors.deepOceanCyan));
        if (controller.students.isEmpty) return const Center(child: Text("EMPTY_LOG_FILE", style: TextStyle(color: TColors.deepOceanCyan, fontWeight: FontWeight.bold)));

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForSession(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(">> MANIFEST_LISTING", style: TextStyle(color: TColors.deepOceanCyan, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2.0)),
                const SizedBox(height: 16),
                ...controller.students.map((student) {
                  return _buildCyberpunkStudentContainer(context, student, isSessionRunning, tokens);
                }),
                if (controller.hasMoreStudents.value) 
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: controller.isLoadingMoreStudents.value 
                        ? const CircularProgressIndicator(color: TColors.deepOceanCyan) 
                        : OutlinedButton(
                            onPressed: controller.loadMoreStudents, 
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: TColors.deepOceanCyan)),
                            child: const Text("FETCH_NEXT_ARRAY", style: TextStyle(color: TColors.deepOceanCyan, fontWeight: FontWeight.w900))),
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCyberpunkStudentContainer(BuildContext context, StudentModel student, bool isSessionRunning, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: TColors.deepOceanCyan.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: TColors.deepOceanCyan.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: -2),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(border: Border.all(color: TColors.deepOceanCyan, width: 1)),
            child: StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 36, isDarkMode: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name.toUpperCase() ?? 'IDENT_NULL', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.5)),
                Text("SERIAL: ${student.rollNumber ?? "?"}", style: TextStyle(color: TColors.deepOceanCyan.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildCyberpunkStatusGroup(student, isSessionRunning),
        ],
      ),
    );
  }

  Widget _buildCyberpunkStatusGroup(StudentModel student, bool isSessionRunning) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMiniToggle('present', 'P', student, isSessionRunning, Colors.greenAccent),
        const SizedBox(width: 4),
        _buildMiniToggle('absent', 'A', student, isSessionRunning, Colors.redAccent),
        const SizedBox(width: 4),
        _buildMiniToggle('late', 'L', student, isSessionRunning, Colors.yellowAccent),
      ],
    );
  }

  Widget _buildMiniToggle(String value, String label, StudentModel student, bool isSessionRunning, Color activeColor) {
    final isSelected = student.attendanceStatus == value;
    return InkWell(
      onTap: isSessionRunning ? () => controller.updateStudentStatus(student.id, value) : null,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? activeColor : TColors.deepOceanCyan.withValues(alpha: 0.2)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? activeColor : TColors.deepOceanCyan.withValues(alpha: 0.4), fontWeight: FontWeight.w900, fontSize: 10)),
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(side: BorderSide(color: TColors.deepOceanCyan, width: 2)),
        title: const Text("PROCEDURE_INIT", style: TextStyle(color: TColors.deepOceanCyan, fontWeight: FontWeight.w900)),
        content: const Text("COMMIT CURRENT DATA BUFFER TO CENTRAL RECORDS?", style: TextStyle(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("ABORT", style: TextStyle(color: Colors.white38))),
          ElevatedButton(onPressed: () { Get.back(); controller.submitAttendance(); }, style: ElevatedButton.styleFrom(backgroundColor: TColors.deepOceanCyan), child: const Text("PROCEED")),
        ],
      ),
    );
  }
}
