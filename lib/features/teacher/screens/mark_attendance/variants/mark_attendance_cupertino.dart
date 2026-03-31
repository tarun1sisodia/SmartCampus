import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Scaffold, AppBar, IconButton, Colors, Theme, Brightness, RefreshIndicator;
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/models/student_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/widgets/student_avatar.dart';

class MarkAttendanceCupertino extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceCupertino({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.cupertinoPro, isDark: isDark);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: isDark ? CupertinoColors.systemBackground.resolveFrom(context) : CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mark Attendance',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, fontFamily: tokens.fontFamily, color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: const Icon(CupertinoIcons.refresh, color: CupertinoColors.activeBlue)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CupertinoActivityIndicator());
        if (controller.students.isEmpty) return const Center(child: Text("No dataset available"));

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForSession(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= controller.students.length) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: controller.isLoadingMoreStudents.value 
                              ? const CupertinoActivityIndicator() 
                              : CupertinoButton(onPressed: controller.loadMoreStudents, child: const Text("Load More Records")),
                          ),
                        );
                      }
                      
                      final student = controller.students[index];
                      return _buildCupertinoStudentRow(context, student, isSessionRunning, isDark);
                    },
                    childCount: controller.students.length + (controller.hasMoreStudents.value ? 1 : 0),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: isSessionRunning ? () => _showSubmitActionSheet(context) : null,
                  child: const Text('Submit Attendance Records', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            )
          : const SizedBox.shrink()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCupertinoStudentRow(BuildContext context, StudentModel student, bool isSessionRunning, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: CupertinoListTile(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leadingSize: 44,
        leading: StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 44, isDarkMode: isDark),
        title: Text(student.name ?? "Student", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text("ID: ${student.rollNumber ?? "?"}", style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 13)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isSessionRunning ? () => _showStatusPicker(context, student) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (student.attendanceStatus ?? 'absent').toUpperCase(),
                style: TextStyle(color: _getStatusColor(student.attendanceStatus), fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Icon(CupertinoIcons.chevron_right, size: 14, color: CupertinoColors.systemGrey3),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context, StudentModel student) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Update Status'),
        message: Text('Setting status for ${student.name}'),
        actions: [
          CupertinoActionSheetAction(onPressed: () { controller.updateStudentStatus(student.id, 'present'); Get.back(); }, child: const Text('Present', style: TextStyle(color: CupertinoColors.activeGreen))),
          CupertinoActionSheetAction(onPressed: () { controller.updateStudentStatus(student.id, 'absent'); Get.back(); }, child: const Text('Absent', style: TextStyle(color: CupertinoColors.destructiveRed))),
          CupertinoActionSheetAction(onPressed: () { controller.updateStudentStatus(student.id, 'late'); Get.back(); }, child: const Text('Late', style: TextStyle(color: CupertinoColors.activeOrange))),
          CupertinoActionSheetAction(onPressed: () { controller.updateStudentStatus(student.id, 'excused'); Get.back(); }, child: const Text('Excused')),
        ],
        cancelButton: CupertinoActionSheetAction(onPressed: () => Get.back(), child: const Text('Cancel')),
      ),
    );
  }

  void _showSubmitActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Submit Attendance'),
        message: const Text('This will upload all records and close the session.'),
        actions: [
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () { Get.back(); controller.submitAttendance(); },
            child: const Text('Submit Records'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(isDestructiveAction: true, onPressed: () => Get.back(), child: const Text('Cancel')),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'present': return CupertinoColors.activeGreen;
      case 'absent': return CupertinoColors.systemRed;
      case 'late': return CupertinoColors.systemOrange;
      case 'excused': return CupertinoColors.activeBlue;
      default: return CupertinoColors.label;
    }
  }
}
