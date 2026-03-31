import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/attendance_reports_controller.dart';

class AttendanceReportsMaterial3 extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsMaterial3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.material3);
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildM3Header(theme),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sessions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummarySection(theme),
                  const SizedBox(height: 32),
                  Text(
                    'Student Attendance List',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _buildStudentList(theme),
                  const SizedBox(height: 48),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildM3Header(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildM3Dropdown(theme)),
          const SizedBox(width: 8),
          _buildDateChip(theme),
        ],
      ),
    );
  }

  Widget _buildM3Dropdown(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
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
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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

  Widget _buildDateChip(ThemeData theme) {
    return IconButton.filledTonal(
      onPressed: () => _pickDateRange(),
      icon: const Icon(Iconsax.calendar_1, size: 20),
    );
  }

  Widget _buildSummarySection(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Average Attendance', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                     Obx(() => Text(
                      '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                      style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                    )),
                  ],
                ),
                Icon(Iconsax.chart_21, size: 48, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 _buildM3Metric('Present', controller.presentCount.toString(), const Color(0xFF10B981), theme),
                 _buildM3Metric('Absent', controller.absentCount.toString(), const Color(0xFFEF4444), theme),
                 _buildM3Metric('Late', controller.lateCount.toString(), const Color(0xFFF59E0B), theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildM3Metric(String label, String value, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildStudentList(ThemeData theme) {
    final students = controller.displayStudents;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final stats = controller.getStudentStats(student.id);
        if (stats == null) return const SizedBox.shrink();
        return _buildM3Row(student, stats, theme);
      },
    );
  }

  Widget _buildM3Row(dynamic student, Map<String, dynamic> stats, ThemeData theme) {
    final percentage = stats['attendancePercentage'] ?? 0.0;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () => controller.navigateToStudentDetail(student),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(student.name.toString(), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text('Roll: ${student.rollNumber}', style: theme.textTheme.labelSmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: percentage >= 75 ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 12, 
              color: percentage >= 75 ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer
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
