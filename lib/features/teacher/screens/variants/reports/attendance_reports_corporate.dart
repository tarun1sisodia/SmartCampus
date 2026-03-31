import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../controllers/attendance_reports_controller.dart';

class AttendanceReportsCorporate extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsCorporate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.industrialCorporate);

    return Column(
      children: [
        _buildControlHeader(tokens),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.sessions.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         _buildSummaryDashboard(tokens),
                         const SizedBox(height: 32),
                         const Text(
                          'DETAILED STUDENT ROSTER',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2.0, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        _buildTableHeader(tokens),
                      ],
                    ),
                  ),
                ),
                Obx(() {
                  final filteredStudents = controller.displayStudents;
                  if (filteredStudents.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final student = filteredStudents[index];
                          final stats = controller.getStudentStats(student.id);
                          if (stats == null) return const SizedBox.shrink();
                          return _buildStudentRecordRow(student, stats, tokens);
                        },
                        childCount: filteredStudents.length,
                      ),
                    ),
                  );
                }),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Obx(() {
                      if (!controller.hasMoreStudentsInReport.value) return const SizedBox.shrink();
                      return Center(
                        child: OutlinedButton(
                          onPressed: controller.loadMoreReportStudents,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          child: const Text('RETRIEVE ADDITIONAL DATA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                      );
                    }),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildControlHeader(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 3, child: _buildClassDropdown(tokens)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildDateRangeToggle(tokens)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassDropdown(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          dropdownColor: const Color(0xFF0F172A),
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.white, size: 16),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName} | ${c.courseName}'.toUpperCase(),
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

  Widget _buildDateRangeToggle(Map<String, dynamic> tokens) {
    return InkWell(
      onTap: () => _showDateRangePicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.calendar, color: Colors.white, size: 14),
            const SizedBox(width: 8),
            const Text('TIME_RANGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDashboard(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0F172A), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ANALYTIC_SCORE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B))),
                  Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 44, color: Color(0xFF0F172A), height: 1),
                  )),
                ],
              ),
              const Icon(Iconsax.activity, size: 48, color: Color(0xFF0F172A)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 1.5, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('PRESENT', controller.presentCount.toString(), const Color(0xFF10B981)),
              _buildMetric('ABSENT', controller.absentCount.toString(), const Color(0xFFEF4444)),
              _buildMetric('LATE', controller.lateCount.toString(), const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
        Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: color, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildTableHeader(Map<String, dynamic> tokens) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('IDENTIFIER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))),
          _HeaderCell('P', 1),
          _HeaderCell('A', 1),
          _HeaderCell('L', 1),
          _HeaderCell('%', 1),
        ],
      ),
    );
  }

  Widget _buildStudentRecordRow(dynamic student, Map<String, dynamic> stats, Map<String, dynamic> tokens) {
    final percentage = stats['attendancePercentage'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFE2E8F0)),
          right: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: InkWell(
        onTap: () => controller.navigateToStudentDetail(student),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E293B))),
                  Text('ROLL: ${student.rollNumber}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 9, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            _buildDataPoint(stats['presentCount'].toString(), 1, const Color(0xFF10B981)),
            _buildDataPoint(stats['absentCount'].toString(), 1, const Color(0xFFEF4444)),
            _buildDataPoint(stats['lateCount'].toString(), 1, const Color(0xFFF59E0B)),
            _buildDataPoint(
              '${percentage.toStringAsFixed(0)}%', 
              1, 
              percentage >= 75 ? const Color(0xFF0F172A) : const Color(0xFFEF4444),
              isBold: true
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPoint(String val, int flex, Color color, {bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        val,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.w800, fontSize: 11, color: color),
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

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
      ),
    );
  }
}
