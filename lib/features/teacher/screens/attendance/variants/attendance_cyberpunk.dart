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

class AttendanceCyberpunk extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceCyberpunk({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.cyberpunkNeon, isDark: isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          (classModel.subjectName ?? 'DATA_LOG').toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TColors.deepOceanCyan, letterSpacing: 2, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadAttendanceSessions(classModel.id),
            icon: const Icon(Iconsax.refresh, color: TColors.deepOceanCyan),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: Colors.black,
        foregroundColor: TColors.deepOceanCyan,
        icon: const Icon(Iconsax.radar, size: 24),
        label: const Text('INIT_SESSION', style: TextStyle(fontWeight: FontWeight.w900)),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: TColors.deepOceanCyan, width: 2),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: TColors.deepOceanCyan));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAttendanceSessions(classModel.id),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCyberpunkHeader(tokens),
                const SizedBox(height: 32),
                const Text(">> FETCHING_SESSIONS...", style: TextStyle(color: TColors.deepOceanCyan, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 2.0)),
                const SizedBox(height: 16),
                ...controller.attendanceSessions.map((session) {
                  return _buildCyberpunkSessionCard(context, session, tokens);
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCyberpunkHeader(PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: const Border(
          left: BorderSide(color: TColors.deepOceanCyan, width: 4),
          bottom: BorderSide(color: TColors.deepOceanCyan, width: 1),
          right: BorderSide(color: TColors.deepOceanCyan, width: 1),
          top: BorderSide(color: TColors.deepOceanCyan, width: 1),
        ),
        boxShadow: [
          BoxShadow(color: TColors.deepOceanCyan.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(classModel.subjectName?.toUpperCase() ?? 'SUBJECT_NULL', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSimpleTag("REG: ${controller.students.length}", TColors.deepOceanCyan),
              const SizedBox(width: 12),
              _buildSimpleTag("LOGS: ${controller.attendanceSessions.length}", Colors.pinkAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildCyberpunkSessionCard(BuildContext context, dynamic session, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border.all(color: TColors.deepOceanCyan.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          controller.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd_MM_yyyy').format(session.date).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
                Text("${session.startTime ?? '00:00'} >> ${session.endTime ?? 'OFFLINE'}", style: TextStyle(color: TColors.deepOceanCyan.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Icon(Iconsax.arrow_right_3, color: TColors.deepOceanCyan.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    controller.sessionDate.value = DateTime.now();
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(side: BorderSide(color: TColors.deepOceanCyan, width: 2)),
        title: const Text("SYS_INIT_PROMPT", style: TextStyle(color: TColors.deepOceanCyan, fontWeight: FontWeight.w900)),
        content: const Text("EXECUTE NEW DATA CAPTURE SESSION?", style: TextStyle(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("ABORT", style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () => controller.createAttendanceSession(), style: ElevatedButton.styleFrom(backgroundColor: TColors.deepOceanCyan), child: const Text("EXECUTE")),
        ],
      ),
    );
  }
}
