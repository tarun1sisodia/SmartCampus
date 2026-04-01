import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/models/class_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import '../../mark_attendance/mark_attendance_screen.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';

class AttendanceFluent extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceFluent({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.fluentLayered, isDark: isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        label: const Text('Start Session', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                _buildFluentHeader(tokens),
                const SizedBox(height: 32),
                const Text("Session Explorer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                ...controller.attendanceSessions.map((session) {
                  return _buildFluentSessionCard(context, session, tokens);
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFluentHeader(PatternTokens tokens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: TColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Iconsax.calendar, color: TColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(classModel.subjectName ?? 'Subject', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("${classModel.courseName} - ${classModel.semester}${classModel.section != null ? ' (${classModel.section})' : ''}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatDetail(controller.students.length.toString(), "REGISTRATIONS"),
              const SizedBox(width: 40),
              _buildStatDetail(controller.attendanceSessions.length.toString(), "ENTRIES"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetail(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildFluentSessionCard(BuildContext context, dynamic session, PatternTokens tokens) {
    final date = DateFormat('dd MMM yyyy').format(session.date);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: const Icon(Iconsax.activity, color: TColors.primary, size: 20),
          title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Session duration: ${session.startTime ?? '00:00'} - ${session.endTime ?? 'Ongoing'}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          trailing: const Icon(Iconsax.arrow_right_3, size: 16),
          onTap: () {
            controller.currentSessionId.value = session.id;
            Get.to(() => MarkAttendanceScreen());
          },
        ),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    controller.sessionDate.value = DateTime.now();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Initialize Transaction", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              title: const Text("Select Session Date"),
              subtitle: Obx(() => Text(DateFormat('dd MMMM yyyy').format(controller.sessionDate.value))),
              trailing: const Icon(Iconsax.calendar),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 30)));
                if (date != null) controller.sessionDate.value = date;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.createAttendanceSession(),
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("Confirm Start"),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
