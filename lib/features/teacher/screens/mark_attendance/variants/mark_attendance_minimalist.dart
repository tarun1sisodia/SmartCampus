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

class MarkAttendanceMinimalist extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceMinimalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.softMinimalist, isDark: isDark);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Attendance Marking',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: const Icon(Iconsax.refresh_2, color: TColors.primary)),
        ],
      ),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'This session is closed', title: 'Closed');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Iconsax.tick_circle, size: 24),
              label: const Text('SUBMIT NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.students.isEmpty) return const Center(child: Text("No students found in this session"));

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForSession(),
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: controller.students.length + (controller.hasMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.students.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: controller.isLoadingMoreStudents.value 
                      ? const CircularProgressIndicator() 
                      : OutlinedButton(onPressed: controller.loadMoreStudents, child: const Text("Load More Students")),
                  ),
                );
              }
              final student = controller.students[index];
              return _buildMinimalistStudentCard(context, student, isSessionRunning, tokens);
            },
          ),
        );
      }),
    );
  }

  Widget _buildMinimalistStudentCard(BuildContext context, StudentModel student, bool isSessionRunning, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 50, isDarkMode: false),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name ?? "Student", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Roll: ${student.rollNumber ?? 'N/A'}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip('present', 'PRESENT', student, isSessionRunning, Colors.green),
                _buildStatusChip('absent', 'ABSENT', student, isSessionRunning, Colors.red),
                _buildStatusChip('late', 'LATE', student, isSessionRunning, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, StudentModel student, bool isSessionRunning, Color color) {
    final isSelected = student.attendanceStatus == value;
    return InkWell(
      onTap: isSessionRunning ? () => controller.updateStudentStatus(student.id, value) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Submit Attendance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Are you sure? This will finalize all student records for today.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () { Get.back(); controller.submitAttendance(); },
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Confirm & Submit"),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
