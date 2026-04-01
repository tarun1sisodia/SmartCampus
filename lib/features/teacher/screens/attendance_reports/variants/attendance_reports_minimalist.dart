import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_reports_controller.dart';

class AttendanceReportsMinimalist extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsMinimalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.softMinimalist);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _buildFilterBar(tokens),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF64748B)));
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  _buildSummaryAnalytics(tokens),
                  const SizedBox(height: 32),
                  const Text(
                    'Attendance Registry',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  _buildStudentList(tokens),
                  Obx(() {
                    if (!controller.hasMoreStudentsInReport.value) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: TextButton(
                        onPressed: controller.loadMoreReportStudents,
                        child: const Text('Load More Records', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(PatternTokens tokens) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(child: _buildMinimalDropdown(tokens)),
          const SizedBox(width: 12),
          _buildDateFab(tokens),
        ],
      ),
    );
  }

  Widget _buildMinimalDropdown(PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          icon: const Icon(Iconsax.arrow_down_1, size: 18),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
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

  Widget _buildDateFab(PatternTokens tokens) {
    return IconButton.filled(
      onPressed: () => _pickDateRange(),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFEFF6FF),
        foregroundColor: const Color(0xFF3B82F6),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Iconsax.calendar_1, size: 20),
    );
  }

  Widget _buildSummaryAnalytics(PatternTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24)],
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('Average Score', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF64748B))),
                   Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 36, color: Color(0xFF1E293B)),
                  )),
                ],
              ),
              const Icon(Iconsax.chart_2, size: 40, color: Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildMetricItem('Present', controller.presentCount.toString(), const Color(0xFF10B981)),
               _buildMetricItem('Absent', controller.absentCount.toString(), const Color(0xFFEF4444)),
               _buildMetricItem('Late', controller.lateCount.toString(), const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B))),
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: color)),
      ],
    );
  }

  Widget _buildStudentList(PatternTokens tokens) {
    final filteredStudents = controller.displayStudents;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 24)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredStudents.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final student = filteredStudents[index];
          final stats = controller.getStudentStats(student.id);
          if (stats == null) return const SizedBox.shrink();
          return _buildMinimalRow(student, stats, tokens);
        },
      ),
    );
  }

  Widget _buildMinimalRow(dynamic student, Map<String, dynamic> stats, PatternTokens tokens) {
    final percentage = stats['attendancePercentage'] ?? 0.0;
    return ListTile(
      onTap: () => controller.navigateToStudentDetail(student),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        student.name.toString(),
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        'Roll #${student.rollNumber}',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: Color(0xFF64748B)),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: percentage >= 75 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            fontSize: 12, 
            color: percentage >= 75 ? const Color(0xFF059669) : const Color(0xFFDC2626)
          ),
        ),
      ),
    );
  }

  void _pickDateRange() async {
    final context = Get.context!;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: controller.startDate.value, end: controller.endDate.value),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF3B82F6), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;
      controller.loadAttendanceData();
    }
  }
}
