import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/models/student_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/widgets/student_avatar.dart';

class MarkAttendanceGlassmorphism extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceGlassmorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.glassmorphism, isDark: isDark);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Stack(
      children: [
        // Background Mesh Gradients
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(shape: BoxShape.circle, color: TColors.deepOceanCyan.withValues(alpha: 0.3)),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent.withValues(alpha: 0.2)),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'STUDENT_MANIFEST',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 1.5, fontFamily: tokens.fontFamily),
            ),
            actions: [
              IconButton(onPressed: () => controller.loadStudentsForSession(), icon: const Icon(Iconsax.refresh, color: Colors.white)),
            ],
          ),
          floatingActionButton: Obx(() => controller.isStudentsLoaded.value
              ? _buildGlassFAB(context, isSessionRunning)
              : const SizedBox.shrink()),
          body: Obx(() {
            if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: Colors.white));
            if (controller.students.isEmpty) return const Center(child: Text("MANIFEST_EMPTY", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)));

            return RefreshIndicator(
              onRefresh: () => controller.loadStudentsForSession(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: controller.students.length + (controller.hasMoreStudents.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.students.length) {
                    return Center(child: Padding(padding: const EdgeInsets.all(24.0),
                      child: controller.isLoadingMoreStudents.value 
                      ? const CircularProgressIndicator() 
                      : TextButton(onPressed: controller.loadMoreStudents, child: const Text("FETCH_REMAINDER", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                    ));
                  }
                  final student = controller.students[index];
                  return _buildGlassStudentCard(context, student, isSessionRunning, tokens);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGlassFAB(BuildContext context, bool isSessionRunning) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              if (!isSessionRunning) return;
              _showSubmitConfirmation(context);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Iconsax.radar, color: Colors.white),
            label: const Text('TRANSMIT_LOGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStudentCard(BuildContext context, StudentModel student, bool isSessionRunning, PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 44, isDarkMode: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name.toUpperCase() ?? 'CODENAME_NULL', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                          Text("ID: ${student.rollNumber ?? "?"}", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildGlassStatusButton('present', 'P', student, isSessionRunning, TColors.deepOceanCyan),
                    _buildGlassStatusButton('absent', 'A', student, isSessionRunning, Colors.pinkAccent),
                    _buildGlassStatusButton('late', 'L', student, isSessionRunning, Colors.orangeAccent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatusButton(String value, String label, StudentModel student, bool isSessionRunning, Color activeColor) {
    final isSelected = student.attendanceStatus == value;
    return InkWell(
      onTap: isSessionRunning ? () => controller.updateStudentStatus(student.id, value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withValues(alpha: 0.3), blurRadius: 10)] : [],
        ),
        child: Text(label, style: TextStyle(color: isSelected ? activeColor : Colors.white70, fontWeight: FontWeight.w900)),
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white24)),
          title: const Text("FINALIZE_MANIFEST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          content: const Text("RECORDS WILL BE ENCRYPTED AND SENT TO CLOUD.", style: TextStyle(color: Colors.white70, fontSize: 12)),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text("STAY", style: TextStyle(color: Colors.white38))),
            ElevatedButton(onPressed: () { Get.back(); controller.submitAttendance(); }, style: ElevatedButton.styleFrom(backgroundColor: TColors.deepOceanCyan), child: const Text("TRANSMIT")),
          ],
        ),
      ),
    );
  }
}
