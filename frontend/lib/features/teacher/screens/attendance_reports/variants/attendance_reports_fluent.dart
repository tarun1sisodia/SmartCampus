import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/attendance_reports_controller.dart';

class AttendanceReportsFluent extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsFluent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);

    return Container(
      color: fluentBg,
      child: Column(
        children: [
          _buildFluentControls(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)));
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildAcrylicSummary(),
                  const SizedBox(height: 32),
                  const Text(
                    'Active_Report_Stream',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF201F1E)),
                  ),
                  const SizedBox(height: 16),
                  _buildFluentList(),
                  const SizedBox(height: 64),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFluentControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildFluentDropdown()),
          const SizedBox(width: 12),
          _buildFluentDateBtn(),
        ],
      ),
    );
  }

  Widget _buildFluentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          dropdownColor: Colors.white,
          icon: Icon(Iconsax.arrow_down_1, size: 16, color: Colors.black.withValues(alpha: 0.6)),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName}'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF201F1E)),
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

  Widget _buildFluentDateBtn() {
    return InkWell(
      onTap: () => _pickDateRange(),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        ),
        child: const Center(child: Icon(Iconsax.calendar_1, color: Color(0xFF484644), size: 18)),
      ),
    );
  }

  Widget _buildAcrylicSummary() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AVG_QUOTA', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.black.withValues(alpha: 0.5))),
                  Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 44, color: Color(0xFF0078D4), height: 1),
                  )),
                ],
              ),
              Icon(Iconsax.chart_2, size: 48, color: const Color(0xFF0078D4).withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildFluentMetric('PRES', controller.presentCount.toString(), const Color(0xFF107C10)),
               _buildFluentMetric('ABS', controller.absentCount.toString(), const Color(0xFFD83B01)),
               _buildFluentMetric('LATE', controller.lateCount.toString(), const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFluentMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF201F1E))),
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: color, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildFluentList() {
    final students = controller.displayStudents;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
        itemBuilder: (context, index) {
          final student = students[index];
          final stats = controller.getStudentStats(student.id);
          if (stats == null) return const SizedBox.shrink();
          final percentage = stats['attendancePercentage'] ?? 0.0;

          return ListTile(
            onTap: () => controller.navigateToStudentDetail(student),
            title: Text(student.name.toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF201F1E))),
            subtitle: Text('ID: ${student.rollNumber}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withValues(alpha: 0.5))),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: percentage >= 75 ? const Color(0xFF0078D4).withValues(alpha: 0.1) : const Color(0xFFD83B01).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700, 
                  fontSize: 12, 
                  color: percentage >= 75 ? const Color(0xFF0078D4) : const Color(0xFFD83B01)
                ),
              ),
            ),
          );
        },
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
