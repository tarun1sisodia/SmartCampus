import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/attendance_reports_controller.dart';

class AttendanceReportsGlassmorphism extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsGlassmorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.glassmorphism);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dynamic Mesh Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          
          Column(
            children: [
              _buildModernHeader(tokens),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.sessions.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      _buildSummaryAnalytics(tokens),
                      const SizedBox(height: 32),
                      const Text(
                        'REGISTRY OVERVIEW',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _buildStudentList(tokens),
                      const SizedBox(height: 48),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15), width: 1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
               Expanded(flex: 2, child: _buildGlassDropdown(tokens)),
               const SizedBox(width: 12),
               _buildDateTrigger(tokens),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDropdown(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          dropdownColor: const Color(0xFF6366F1).withOpacity(0.9),
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.white, size: 16),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName}'.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
            ),
          )).toList(),
          onChanged: (v) {
            if (v != null) {
              controller.selectedClassId.value = v;
              controller.loadAttendanceData();
            }
          },
        ),
      )),
    );
  }

  Widget _buildDateTrigger(Map<String, dynamic> tokens) {
    return InkWell(
      onTap: () => _showDateRangePicker(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Center(child: Icon(Iconsax.calendar_1, color: Colors.white, size: 20)),
      ),
    );
  }

  Widget _buildSummaryAnalytics(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('AVERAGE QUOTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
                   Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 44, height: 1),
                  )),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                child: const Center(child: Icon(Iconsax.chart_2, size: 32, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildGlassMetric('PRES', controller.presentCount.toString(), const Color(0xFF10B981)),
               _buildGlassMetric('ABS', controller.absentCount.toString(), const Color(0xFFEF4444)),
               _buildGlassMetric('LATE', controller.lateCount.toString(), const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildStudentList(Map<String, dynamic> tokens) {
    final filteredStudents = controller.displayStudents;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final stats = controller.getStudentStats(student.id);
        if (stats == null) return const SizedBox.shrink();
        return _buildGlassRow(student, stats, tokens);
      },
    );
  }

  Widget _buildGlassRow(dynamic student, Map<String, dynamic> stats, Map<String, dynamic> tokens) {
    final percentage = stats['attendancePercentage'] ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () => controller.navigateToStudentDetail(student),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.1),
          child: Text(student.name.toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        ),
        title: Text(student.name.toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
        subtitle: Text('ID: ${student.rollNumber}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w700, fontSize: 10)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: percentage >= 75 ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFEF4444).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: percentage >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444), width: 1),
          ),
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final context = Get.context!;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: controller.startDate.value, end: controller.endDate.value),
    );
    if (picked != null) {
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;
      controller.loadAttendanceData();
    }
  }
}
