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

class AttendanceBrutalist extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceBrutalist({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.brutalistBold, isDark: isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          (classModel.subjectName ?? 'ATTENDANCE').toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1.0, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadAttendanceSessions(classModel.id),
            icon: const Icon(Iconsax.refresh, color: Colors.black, size: 32),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        icon: const Icon(Iconsax.add, size: 32, strokeWidth: 3),
        label: const Text('NEW_SESSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 4),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAttendanceSessions(classModel.id),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrutalistHeader(tokens),
                const SizedBox(height: 32),
                const Text("RECORD_HISTORY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, backgroundColor: Colors.black, color: Colors.white)),
                const SizedBox(height: 16),
                ...controller.attendanceSessions.map((session) {
                  return _buildBrutalistSessionCard(context, session, tokens);
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBrutalistHeader(PatternTokens tokens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(classModel.subjectName?.toUpperCase() ?? 'SUBJECT', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, height: 0.9)),
          const SizedBox(height: 8),
          Text(classModel.courseName?.toUpperCase() ?? 'COURSE', style: const TextStyle(fontWeight: FontWeight.bold, backgroundColor: Colors.black, color: Colors.white)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildBigStat(controller.students.length.toString(), "STDS"),
              const SizedBox(width: 16),
              _buildBigStat(controller.attendanceSessions.length.toString(), "SESS"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildBrutalistSessionCard(BuildContext context, dynamic session, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          controller.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
        title: Text(DateFormat('dd.MM.yyyy').format(session.date), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        subtitle: Text("${session.startTime ?? '00:00'} >> ${session.endTime ?? 'OFFLINE'}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)),
        trailing: const Icon(Iconsax.arrow_right_3, color: Colors.black, size: 32),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    controller.sessionDate.value = DateTime.now();
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 4)),
        title: const Text("CREATE_NEW", style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text("CONFIRM SESSION INITIALIZATION?", style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("ABORT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
          ElevatedButton(onPressed: () => controller.createAttendanceSession(), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: const RoundedRectangleBorder()), child: const Text("EXECUTE")),
        ],
      ),
    );
  }
}
