import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/attendance_reports_controller.dart';

class AttendanceReportsNeumorphism extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsNeumorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.neumorphism);
    const bgColor = Color(0xFFE2E8F0);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          _buildTactileFilters(bgColor),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF94A3B8)));
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  _buildSummaryCard(bgColor),
                  const SizedBox(height: 32),
                  const Text(
                    'DATA_ROSTER',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 16),
                  _buildStudentList(bgColor),
                  const SizedBox(height: 48),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTactileFilters(Color bgColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(child: _buildNeumorphicDropdown(bgColor)),
          const SizedBox(width: 16),
          _buildDateButton(bgColor),
        ],
      ),
    );
  }

  Widget _buildNeumorphicDropdown(Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(5, 5), blurRadius: 10),
        ],
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          icon: const Icon(Iconsax.arrow_down_1, size: 16, color: Color(0xFF475569)),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName}'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF1E293B)),
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

  Widget _buildDateButton(Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(3, 3), blurRadius: 6),
        ],
      ),
      child: IconButton(
        onPressed: () => _pickDateRange(),
        icon: const Icon(Iconsax.calendar_1, size: 20, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _buildSummaryCard(Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.4), offset: const Offset(10, 10), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('PERCENTAGE_SCORE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B))),
                   Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 44, color: Color(0xFF1E293B), height: 1),
                  )),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
                    BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(5, 5), blurRadius: 10),
                  ],
                ),
                child: const Center(child: Icon(Iconsax.activity, size: 32, color: Color(0xFF475569))),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildTactileMetric('PRES', controller.presentCount.toString(), const Color(0xFF10B981), bgColor),
               _buildTactileMetric('ABS', controller.absentCount.toString(), const Color(0xFFEF4444), bgColor),
               _buildTactileMetric('LATE', controller.lateCount.toString(), const Color(0xFFF59E0B), bgColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTactileMetric(String label, String value, Color color, Color bgColor) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1E293B))),
        Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: color, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildStudentList(Color bgColor) {
    final students = controller.displayStudents;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final stats = controller.getStudentStats(student.id);
        if (stats == null) return const SizedBox.shrink();
        return _buildTactileRow(student, stats, bgColor);
      },
    );
  }

  Widget _buildTactileRow(dynamic student, Map<String, dynamic> stats, Color bgColor) {
    final percentage = stats['attendancePercentage'] ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.4), offset: const Offset(2, 2), blurRadius: 5),
        ],
      ),
      child: ListTile(
        onTap: () => controller.navigateToStudentDetail(student),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          student.name.toString().toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B)),
        ),
        subtitle: Text(
          'ID_${student.rollNumber}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
               BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
               BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4, inset: true),
            ],
          ),
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: percentage >= 75 ? const Color(0xFF0F172A) : const Color(0xFFEF4444)
            ),
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
    );
    if (picked != null) {
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;
      controller.loadAttendanceData();
    }
  }
}
