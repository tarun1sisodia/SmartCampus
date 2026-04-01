import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, DateTimeRange, showDateRangePicker;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_reports_controller.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';

class AttendanceReportsCupertino extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsCupertino({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.cupertinoPro);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('REPORTS', style: TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.w800)),
            backgroundColor: const Color(0xFFF2F2F7).withValues(alpha: 0.8),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(Iconsax.export, size: 22),
              onPressed: () => controller.exportAttendanceReport(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildCupertinoFilters(),
          ),
          Obx(() {
            if (controller.isLoading.value && controller.sessions.isEmpty) {
              return const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator()));
            }

            return SliverList(
              delegate: SliverChildListDelegate([
                _buildAnalyticsSummary(),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('STUDENT RECORDS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF6E6E73), letterSpacing: 0.5)),
                ),
                const SizedBox(height: 8),
                _buildStudentList(),
                _buildLoadMoreButton(),
                const SizedBox(height: 64),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCupertinoFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: _buildIosDropdown()),
          const SizedBox(width: 12),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF007AFF),
            borderRadius: BorderRadius.circular(10),
            onPressed: () => _pickDateRange(),
            child: const Icon(CupertinoIcons.calendar, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildIosDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3E8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          dropdownColor: Colors.white,
          icon: const Icon(CupertinoIcons.chevron_down, size: 14, color: Color(0xFF8E8E93)),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black),
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

  Widget _buildAnalyticsSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('AVG_SCORE', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF8E8E93))),
                   Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 44, color: Color(0xFF007AFF), height: 1.1),
                  )),
                ],
              ),
              const Icon(CupertinoIcons.graph_circle, size: 48, color: Color(0xFF007AFF)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildIosMetric('PRES', controller.presentCount.toString(), const Color(0xFF34C759)),
               _buildIosMetric('ABS', controller.absentCount.toString(), const Color(0xFFFF3B30)),
               _buildIosMetric('LATE', controller.lateCount.toString(), const Color(0xFFFF9500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIosMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black)),
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: color)),
      ],
    );
  }

  Widget _buildStudentList() {
    final students = controller.displayStudents;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 64, color: Color(0xFFF2F2F7)),
        itemBuilder: (context, index) {
          final student = students[index];
          final stats = controller.getStudentStats(student.id);
          if (stats == null) return const SizedBox.shrink();
          return _buildIosRow(student, stats);
        },
      ),
    );
  }

  Widget _buildIosRow(dynamic student, Map<String, dynamic> stats) {
    final percentage = stats['attendancePercentage'] ?? 0.0;
    return _ListTile(
      onTap: () => controller.navigateToStudentDetail(student),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(student.name.toString().substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800))),
      ),
      title: Text(student.name.toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text('ID: ${student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF8E8E93))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.w700, 
              color: percentage >= 75 ? const Color(0xFF007AFF) : const Color(0xFFFF3B30)
            ),
          ),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.chevron_right, size: 14, color: Color(0xFFC7C7CC)),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
     return Obx(() {
      if (!controller.hasMoreStudentsInReport.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: CupertinoButton(
          onPressed: controller.loadMoreReportStudents,
          child: const Text('DISCOVER MORE', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      );
    });
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

class _ListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  const _ListTile({
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: contentPadding,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 16)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[const SizedBox(height: 2), subtitle!],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
