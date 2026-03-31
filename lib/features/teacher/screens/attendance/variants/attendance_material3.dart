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

class AttendanceMaterial3 extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceMaterial3({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.material3, isDark: isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          classModel.subjectName ?? 'Attendance',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, fontFamily: tokens.fontFamily),
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
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        icon: const Icon(Iconsax.calendar_add, size: 24),
        label: const Text('Add Session', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAttendanceSessions(classModel.id),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              children: [
                _buildM3Header(context, tokens),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("SESSIONS HISTORY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0, color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 16),
                ...controller.attendanceSessions.map((session) {
                  return _buildM3SessionCard(context, session, tokens);
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildM3Header(BuildContext context, PatternTokens tokens) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.borderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Icon(Iconsax.calendar_tick, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(classModel.subjectName ?? 'Subject', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("${classModel.courseName} - Sem ${classModel.semester}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildM3SessionCard(BuildContext context, dynamic session, PatternTokens tokens) {
    final date = DateFormat('EEE, MMM d, yyyy').format(session.date);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(Iconsax.calendar_edit, color: Theme.of(context).colorScheme.primary),
        title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${session.startTime ?? '00:00'} — ${session.endTime ?? 'ONGOING'}", style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Iconsax.arrow_right_3, size: 18),
        onTap: () {
          controller.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    controller.sessionDate.value = DateTime.now();
    Get.dialog(
      DatePickerDialog(
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ).then((date) {
      if (date != null && date is DateTime) {
        controller.sessionDate.value = date;
        controller.createAttendanceSession();
      }
    });
  }
}
