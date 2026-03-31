import "dart:ui";
import 'dart:ui';
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

class AttendanceGlassmorphism extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceGlassmorphism({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.glassmorphism, isDark: isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          classModel.subjectName?.toUpperCase() ?? 'ATTENDANCE',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadAttendanceSessions(classModel.id),
            icon: const Icon(Iconsax.refresh, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: TColors.deepOceanCyan,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.calendar_add, size: 24),
        label: const Text('SESSION+', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white24)),
      ),
      body: Stack(
        children: [
          // Mesh backgrounds
          Positioned(
            top: 50,
            right: -50,
            child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: TColors.deepOceanCyan.withValues(alpha: 0.3))),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: TColors.executiveNavy.withValues(alpha: 0.2))),
          ),
          
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadAttendanceSessions(classModel.id),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildGlassHeader(tokens),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("SESSIONS_PROTOCOLS", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 10)),
                    ),
                    const SizedBox(height: 20),
                    ...controller.attendanceSessions.map((session) {
                      return _buildGlassSessionCard(context, session, tokens);
                    }),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, required PatternTokens tokens}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: tokens.backdropBlur ?? 15, sigmaY: tokens.backdropBlur ?? 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tokens.backgroundColor,
            borderRadius: BorderRadius.circular(tokens.borderRadius),
            border: tokens.border,
            gradient: tokens.gradient,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassHeader(PatternTokens tokens) {
    return _buildGlassCard(
      tokens: tokens,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classModel.subjectName?.toUpperCase() ?? 'SUBJECT', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(classModel.courseName ?? 'Course', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Iconsax.radar, color: TColors.deepOceanCyan, size: 32),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn("STUDENTS", controller.students.length.toString()),
              _buildStatColumn("SESSIONS", controller.attendanceSessions.length.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildGlassSessionCard(BuildContext context, dynamic session, PatternTokens tokens) {
    final date = DateFormat('dd MMM yyyy').format(session.date).toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildGlassCard(
        tokens: tokens,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
            alignment: Alignment.center,
            child: Text(DateFormat('dd').format(session.date), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          title: Text(date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text("${session.startTime ?? '00:00'} — ${session.endTime ?? 'ONGOING'}", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
          trailing: const Icon(Iconsax.arrow_right_3, color: Colors.white),
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
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white24)),
          title: const Text("INITIALIZE SESSION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("DATE", style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                subtitle: Obx(() => Text(DateFormat('dd MMMM yyyy').format(controller.sessionDate.value).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                leading: const Icon(Iconsax.calendar, color: TColors.deepOceanCyan),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 30)));
                  if (date != null) controller.sessionDate.value = date;
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
            ElevatedButton(onPressed: () => controller.createAttendanceSession(), style: ElevatedButton.styleFrom(backgroundColor: TColors.deepOceanCyan), child: const Text("CONFIRM")),
          ],
        ),
      ),
    );
  }
}
