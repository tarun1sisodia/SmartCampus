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

class AttendanceAcademic extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceAcademic({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.academicClassic, isDark: isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          classModel.subjectName ?? 'Class Ledger',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Georgia', color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadAttendanceSessions(classModel.id),
            icon: Icon(Iconsax.refresh, color: isDark ? Colors.white54 : Colors.brown),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Iconsax.edit_2),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.brown));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAttendanceSessions(classModel.id),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAcademicLedgerHeader(tokens, isDark),
                const SizedBox(height: 48),
                const Center(
                  child: Text("—— SESSION RECORDS ——", style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2.0, color: Colors.grey)),
                ),
                const SizedBox(height: 32),
                ...controller.attendanceSessions.map((session) {
                  return _buildAcademicSessionEntry(context, session, tokens, isDark);
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAcademicLedgerHeader(PatternTokens tokens, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        border: Border.all(color: Colors.brown.withValues(alpha: 0.3)),
        boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text(classModel.subjectName?.toUpperCase() ?? 'SUBJECT', textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'serif', letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Text(classModel.courseName ?? 'Course', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          const SizedBox(height: 32),
          const Divider(thickness: 1, color: Colors.brown),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSimpleAcademicStat(controller.students.length.toString(), "ENROLLED"),
              _buildSimpleAcademicStat(controller.attendanceSessions.length.toString(), "SESSIONS"),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1, color: Colors.brown),
        ],
      ),
    );
  }

  Widget _buildSimpleAcademicStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.brown)),
      ],
    );
  }

  Widget _buildAcademicSessionEntry(BuildContext context, dynamic session, PatternTokens tokens, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.brown.withValues(alpha: 0.2))),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        onTap: () {
          controller.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
        leading: Icon(Iconsax.book, color: Colors.brown[300], size: 20),
        title: Text(DateFormat('EEEE, MMMM d, yyyy').format(session.date), style: const TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("Registered at ${session.startTime ?? '00:00'}", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
        trailing: const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.brown),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    controller.sessionDate.value = DateTime.now();
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text("INITIALIZE LEDGER ENTRY", style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
        content: const Text("Would you like to open a new attendance record for today's session?", style: TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(onPressed: () => controller.createAttendanceSession(), style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700], shape: const RoundedRectangleBorder()), child: const Text("CREATE")),
        ],
      ),
    );
  }
}
