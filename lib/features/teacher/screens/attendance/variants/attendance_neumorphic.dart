import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/models/class_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import '../../mark_attendance/mark_attendance_screen.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';

class AttendanceNeumorphic extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceNeumorphic({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.neumorphism, isDark: isDark);
    final bgColor = isDark ? const Color(0xFF1A1C1E) : const Color(0xFFE0E5EC);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          classModel.subjectName?.toUpperCase() ?? 'ATTENDANCE',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white70 : TColors.executiveNavy, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadAttendanceSessions(classModel.id),
            icon: Icon(Iconsax.refresh, color: isDark ? Colors.white70 : TColors.executiveNavy),
          ),
        ],
      ),
      floatingActionButton: _buildNeumorphicButton(
        onPressed: () => _showCreateSessionDialog(context),
        child: const Icon(Iconsax.add, color: TColors.primary),
        tokens: tokens,
        isDark: isDark,
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
              children: [
                _buildNeumorphicHeader(tokens, isDark),
                const SizedBox(height: 48),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Text("SESSIONS HISTORY", style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white54 : Colors.grey, fontSize: 12, letterSpacing: 2.0)),
                  ],
                ),
                const SizedBox(height: 24),
                ...controller.attendanceSessions.map((session) {
                  return _buildNeumorphicSessionCard(context, session, tokens, isDark);
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNeumorphicHeader(PatternTokens tokens, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1C1E) : const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: [
          BoxShadow(offset: const Offset(8, 8), blurRadius: 16, color: isDark ? Colors.black : Colors.black.withValues(alpha: 0.1)),
          BoxShadow(offset: const Offset(-8, -8), blurRadius: 16, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
        ],
      ),
      child: Column(
        children: [
          Text(classModel.subjectName?.toUpperCase() ?? 'SUBJECT', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(classModel.courseName ?? 'Course', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSimpleStat(controller.students.length.toString(), "STUDENTS"),
              _buildSimpleStat(controller.attendanceSessions.length.toString(), "SESSIONS"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildNeumorphicSessionCard(BuildContext context, dynamic session, PatternTokens tokens, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1C1E) : const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        boxShadow: [
          BoxShadow(offset: const Offset(4, 4), blurRadius: 8, color: isDark ? Colors.black : Colors.black.withValues(alpha: 0.1)),
          BoxShadow(offset: const Offset(-4, -4), blurRadius: 8, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        onTap: () {
          controller.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
        title: Text(DateFormat('dd MMM yyyy').format(session.date).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
        subtitle: Text("${session.startTime ?? '00:00'} — ${session.endTime ?? 'ONGOING'}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1C1E) : const Color(0xFFE0E5EC),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(offset: const Offset(2, 2), blurRadius: 4, color: isDark ? Colors.black : Colors.black.withValues(alpha: 0.1)),
              BoxShadow(offset: const Offset(-2, -2), blurRadius: 4, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
            ],
          ),
          child: const Icon(Iconsax.arrow_right_3, size: 16),
        ),
      ),
    );
  }

  Widget _buildNeumorphicButton({required VoidCallback onPressed, required Widget child, required PatternTokens tokens, required bool isDark}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1C1E) : const Color(0xFFE0E5EC),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(offset: const Offset(6, 6), blurRadius: 12, color: isDark ? Colors.black : Colors.black.withValues(alpha: 0.15)),
            BoxShadow(offset: const Offset(-6, -6), blurRadius: 12, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          ],
        ),
        child: child,
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    controller.sessionDate.value = DateTime.now();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFFE0E5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("NEW SESSION", style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Initialize Neumorphic Session", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.createAttendanceSession(),
              style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("CREATE SESSION"),
            ),
          ],
        ),
      ),
    );
  }
}
