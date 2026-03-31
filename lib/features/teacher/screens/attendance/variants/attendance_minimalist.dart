import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/models/class_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/features/teacher/screens/mark_attendance_screen.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance_screen.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';

class AttendanceMinimalist extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceMinimalist({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.softMinimalist, isDark: isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          classModel.subjectName ?? 'Attendance',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadAttendanceSessions(classModel.id),
            icon: const Icon(Iconsax.refresh, color: TColors.primary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.add, size: 24),
        label: const Text('Add Session', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.borderRadius)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAttendanceSessions(classModel.id),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMinimalistHeader(tokens),
                const SizedBox(height: 32),
                const Text("Attendance History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                ...controller.attendanceSessions.map((session) {
                  return _buildMinimalistSessionCard(context, session, tokens);
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMinimalistHeader(PatternTokens tokens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: TColors.primary.withValues(alpha: 0.1),
            child: const Icon(Iconsax.calendar_1, color: TColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(classModel.subjectName ?? 'Subject', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("${classModel.courseName} - Sem ${classModel.semester}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(controller.students.length.toString(), "Students"),
              const SizedBox(width: 32),
              _buildStatChip(controller.attendanceSessions.length.toString(), "Sessions"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMinimalistSessionCard(BuildContext context, dynamic session, PatternTokens tokens) {
    final date = DateFormat('MMM d, yyyy').format(session.date);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: tokens.shadows,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: TColors.primary.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(DateFormat('dd').format(session.date), style: const TextStyle(fontWeight: FontWeight.bold, color: TColors.primary, fontSize: 18)),
        ),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${session.startTime ?? '00:00'} - ${session.endTime ?? 'Ongoing'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: TColors.primary),
        onTap: () {
          controller.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    controller.sessionDate.value = DateTime.now();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Create New Session", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              title: const Text("Session Date"),
              subtitle: Obx(() => Text(DateFormat('EEEE, MMM d').format(controller.sessionDate.value))),
              trailing: const Icon(Iconsax.calendar),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 30)));
                if (date != null) controller.sessionDate.value = date;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => controller.createAttendanceSession(),
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text("Create Session"),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
