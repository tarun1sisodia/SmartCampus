import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/models/student_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/common/widgets/student_avatar.dart';

class MarkAttendanceNeumorphic extends StatelessWidget {
  final AttendanceController controller;

  const MarkAttendanceNeumorphic({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.neumorphism, isDark: isDark);
    final bgColor = isDark ? const Color(0xFF292D32) : const Color(0xFFE0E0E0);
    
    final isSessionRunning = controller.currentSessionId.value.isNotEmpty &&
        controller.isSessionRunning(controller.currentSessionId.value);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mark Presence',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white70 : Colors.black54, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(onPressed: () => controller.loadStudentsForSession(), icon: Icon(Iconsax.refresh, color: isDark ? Colors.white30 : Colors.black26)),
        ],
      ),
      floatingActionButton: Obx(() => controller.isStudentsLoaded.value
          ? _buildNeumorphicFAB(context, isSessionRunning, isDark, bgColor)
          : const SizedBox.shrink()),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.students.isEmpty) return const Center(child: Text("Empty records"));

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentsForSession(),
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: controller.students.length + (controller.hasMoreStudents.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.students.length) {
                return Center(child: Padding(padding: const EdgeInsets.all(24.0),
                  child: controller.isLoadingMoreStudents.value 
                    ? const CircularProgressIndicator() 
                    : TextButton(onPressed: controller.loadMoreStudents, child: const Text("Pull more data")),
                ));
              }
              final student = controller.students[index];
              return _buildNeumorphicStudentCard(context, student, isSessionRunning, isDark, bgColor);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNeumorphicFAB(BuildContext context, bool isSessionRunning, bool isDark, Color bgColor) {
    final shadowColor = isDark ? Colors.black : Colors.black.withValues(alpha: 0.1);
    final lightColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(offset: const Offset(5, 5), blurRadius: 15, color: shadowColor),
          BoxShadow(offset: const Offset(-5, -5), blurRadius: 15, color: lightColor),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          if (!isSessionRunning) return;
          _showSubmitConfirmation(context);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        icon: Icon(Iconsax.tick_square, color: isDark ? Colors.white70 : Colors.black87),
        label: Text('SUBMIT', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNeumorphicStudentCard(BuildContext context, StudentModel student, bool isSessionRunning, bool isDark, Color bgColor) {
    final shadowColor = isDark ? Colors.black : Colors.black.withValues(alpha: 0.2);
    final lightColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(offset: const Offset(10, 10), blurRadius: 20, color: shadowColor),
          BoxShadow(offset: const Offset(-10, -10), blurRadius: 20, color: lightColor),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              StudentAvatar(imageUrl: student.imageUrl, name: student.name, size: 48, isDarkMode: isDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name ?? "Student", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white70 : Colors.black87)),
                    Text("Roll: ${student.rollNumber ?? "?"}", style: TextStyle(color: isDark ? Colors.white30 : Colors.black26, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNeumorphicStatusButton('present', 'PRESENT', student, isSessionRunning, isDark, bgColor, Colors.green),
              _buildNeumorphicStatusButton('absent', 'ABSENT', student, isSessionRunning, isDark, bgColor, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeumorphicStatusButton(String value, String label, StudentModel student, bool isSessionRunning, bool isDark, Color bgColor, Color themeColor) {
    final isSelected = student.attendanceStatus == value;
    final shadowColor = isDark ? Colors.black : Colors.black.withValues(alpha: 0.2);
    final lightColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;

    return GestureDetector(
      onTap: isSessionRunning ? () => controller.updateStudentStatus(student.id, value) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected 
            ? [
                BoxShadow(offset: const Offset(4, 4), blurRadius: 5, color: shadowColor, inset: true),
                BoxShadow(offset: const Offset(-4, -4), blurRadius: 5, color: lightColor, inset: true),
              ]
            : [
                BoxShadow(offset: const Offset(4, 4), blurRadius: 5, color: shadowColor),
                BoxShadow(offset: const Offset(-4, -4), blurRadius: 5, color: lightColor),
              ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? themeColor : (isDark ? Colors.white30 : Colors.black26),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  void _showSubmitConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFFE0E0E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm sync"),
        content: const Text("This finalized current session data."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { Get.back(); controller.submitAttendance(); }, child: const Text("Submit")),
        ],
      ),
    );
  }
}
