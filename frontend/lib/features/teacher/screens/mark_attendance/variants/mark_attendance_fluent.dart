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

class MarkAttendanceFluent extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceFluent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.fluentLayered, isDark: isDark);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mark Attendance',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: TColors.executiveNavy, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: const Icon(Iconsax.refresh, color: TColors.primary)),
        ],
      ),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!isSessionRunning) {
                  TSnackBar.showInfo(message: 'Session is currently closed.', title: 'Information');
                  return;
                }
                _showSubmitConfirmation(context);
              },
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Iconsax.tick_circle, size: 24),
              label: const Text('Update records', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.students.isEmpty) return const Center(child: Text("Empty dataset"));

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForSession(),
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: controller.students.length + (controller.hasMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.students.length) {
                return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 32),
                  child: controller.isLoadingMoreStudents.value 
                    ? const CircularProgressIndicator() 
                    : OutlinedButton(onPressed: controller.loadMoreStudents, child: const Text("Fetch more students")),
                ));
              }
              final student = controller.students[index];
              return _buildFluentStudentCard(context, student, isSessionRunning, tokens);
            },
          ),
        );
      }),
    );
  }

  Widget _buildFluentStudentCard(BuildContext context, StudentModel student, bool isSessionRunning, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 44, isDarkMode: false),
          title: Text(student.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text("Registration: ${student.rollNumber ?? "?"}", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          trailing: _buildFluentStatusToggles(student, isSessionRunning),
          onTap: () {}, // For reveal hover effect simulation
        ),
      ),
    );
  }

  Widget _buildFluentStatusToggles(StudentModel student, bool isSessionRunning) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFluentMiniBtn('present', Iconsax.tick_circle, student, isSessionRunning, Colors.green),
        const SizedBox(width: 8),
        _buildFluentMiniBtn('absent', Iconsax.close_circle, student, isSessionRunning, Colors.red),
      ],
    );
  }

  Widget _buildFluentMiniBtn(String value, IconData icon, StudentModel student, bool isSessionRunning, Color activeColor) {
    final isSelected = student.attendanceStatus == value;
    return GestureDetector(
      onTap: isSessionRunning ? () => controller.updateStudentStatus(student.id, value) : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.grey[50],
          border: Border.all(color: isSelected ? activeColor : Colors.grey[200]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 20, color: isSelected ? activeColor : Colors.grey[400]),
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Submit Attendance Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Are you ready to sync these records to the cloud? This action is permanent for today's session.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () { Get.back(); controller.submitAttendance(); },
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                child: const Text("Confirm & Sync"),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
