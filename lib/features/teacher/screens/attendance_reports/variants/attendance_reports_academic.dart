import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_reports_controller.dart';

class AttendanceReportsAcademic extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsAcademic({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown

    return Container(
      color: paperColor,
      child: Column(
        children: [
          _buildAcademicControls(accentColor, inkColor),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: accentColor));
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildFormalSummary(accentColor, inkColor),
                  const SizedBox(height: 32),
                  Text(
                    'DEPARTMENTAL_REGISTRY',
                    style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0, color: inkColor),
                  ),
                  const SizedBox(height: 16),
                  _buildAcademicList(accentColor, inkColor),
                  const SizedBox(height: 64),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicControls(Color accent, Color ink) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAD6),
        border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.3), width: 1.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildScribeDropdown(ink)),
          const SizedBox(width: 12),
          _buildClassicDateBtn(accent),
        ],
      ),
    );
  }

  Widget _buildScribeDropdown(Color ink) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: ink.withValues(alpha: 0.2), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          dropdownColor: const Color(0xFFF0EAD6),
          icon: Icon(Iconsax.arrow_down_1, size: 16, color: ink),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName}'.toUpperCase(),
              style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w700, fontSize: 11, color: ink),
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

  Widget _buildClassicDateBtn(Color accent) {
    return InkWell(
      onTap: () => _pickDateRange(),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(Iconsax.calendar_1, color: accent, size: 20)),
      ),
    );
  }

  Widget _buildFormalSummary(Color accent, Color ink) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: accent.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AGGREGATE_PERCENTAGE', style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w800, fontSize: 10, color: ink.withValues(alpha: 0.5))),
                  Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w900, fontSize: 48, color: accent, height: 1),
                  )),
                ],
              ),
              Icon(Iconsax.judge, size: 48, color: accent.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildAcademicMetric('PRESENT', controller.presentCount.toString(), const Color(0xFF10B981)),
               _buildAcademicMetric('ABSENT', controller.absentCount.toString(), const Color(0xFFEF4444)),
               _buildAcademicMetric('LATE', controller.lateCount.toString(), const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Serif', color: Colors.black)),
        Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: color, fontFamily: 'Serif', letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildAcademicList(Color accent, Color ink) {
    final students = controller.displayStudents;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final stats = controller.getStudentStats(student.id);
        if (stats == null) return const SizedBox.shrink();
        final percentage = stats['attendancePercentage'] ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: ink.withValues(alpha: 0.05), width: 1)),
          ),
          child: ListTile(
            onTap: () => controller.navigateToStudentDetail(student),
            title: Text(student.name.toString().toUpperCase(), style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w900, fontSize: 13, color: ink)),
            subtitle: Text('ID_SYS: ${student.rollNumber}', style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w600, fontSize: 10, color: ink.withValues(alpha: 0.5))),
            trailing: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontFamily: 'Serif',
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: percentage >= 75 ? accent : const Color(0xFFEF4444)
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickDateRange() async {
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
