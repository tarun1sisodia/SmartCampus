import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../controllers/attendance_reports_controller.dart';

class AttendanceReportsScreen extends StatelessWidget {
  final reportsController = Get.put(AttendanceReportsController());

  AttendanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Text(
          'ATTENDANCE REPORTS',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        actions: [
          IconButton(
            onPressed: () => reportsController.loadAttendanceData(),
            icon: const Icon(Iconsax.refresh, color: TColors.slate900),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => reportsController.exportAttendanceReport(),
            icon: const Icon(Iconsax.export, color: TColors.executiveNavy),
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Obx(() {
        if (reportsController.isLoading.value) {
          return _buildLoadingShimmer(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await reportsController.loadAttendanceData();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Selection and Summary Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildClassSelectionCard(context),
                      const SizedBox(height: 16),
                      _buildDateRangeCard(context),
                      const SizedBox(height: 32),
                      if (reportsController.sessions.isNotEmpty)
                        _buildAttendanceSummary(context),
                    ],
                  ),
                ),
              ),

              // 2. Student list header
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'STUDENT ATTENDANCE',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: TColors.slate600),
                      ),
                      const SizedBox(height: 16),
                      _buildTableHeader(context),
                    ],
                  ),
                ),
              ),

              // 3. Virtualized Student List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: Obx(() {
                  final filteredStudents = reportsController.displayStudents;
                  
                  if (filteredStudents.isEmpty) {
                    return SliverToBoxAdapter(child: _buildEmptyState(context));
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final student = filteredStudents[index];
                        final stats = reportsController.getStudentStats(student.id);
                        if (stats == null) return const SizedBox.shrink();

                        return _buildStudentRow(context, student, stats);
                      },
                      childCount: filteredStudents.length,
                    ),
                  );
                }),
              ),

              // 4. Load More Button
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Obx(() {
                    if (!reportsController.hasMoreStudentsInReport.value) return const SizedBox.shrink();
                    return Center(
                      child: reportsController.isLoadingMoreReport.value
                          ? const CircularProgressIndicator()
                          : OutlinedButton(
                              onPressed: reportsController.loadMoreReportStudents,
                              child: const Text('LOAD MORE STUDENTS'),
                            ),
                    );
                  }),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildClassSelectionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SELECT CLASS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          if (reportsController.classes.isEmpty)
            const Center(child: Text('NO CLASSES AVAILABLE'))
          else
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              isExpanded: true,
              icon: const Icon(Iconsax.arrow_down_1, color: TColors.executiveNavy),
              value: reportsController.selectedClassId.value,
              items: reportsController.classes.map((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem.id,
                  child: Text(
                    '${classItem.subjectName} - ${classItem.courseName} (${classItem.semester})'.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  reportsController.selectedClassId.value = value;
                  reportsController.loadAttendanceData();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DATE RANGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDatePickerField(
                  context: context,
                  label: 'START DATE',
                  value: reportsController.startDate.value,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: reportsController.startDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      reportsController.startDate.value = pickedDate;
                      reportsController.loadAttendanceData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePickerField(
                  context: context,
                  label: 'END DATE',
                  value: reportsController.endDate.value,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: reportsController.endDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      reportsController.endDate.value = pickedDate;
                      reportsController.loadAttendanceData();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({required BuildContext context, required String label, required DateTime value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.slate50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: TColors.slate300, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: TColors.slate600, fontWeight: FontWeight.w900, fontSize: 9)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('MMM d, yyyy').format(value).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                const Icon(Iconsax.calendar, size: 16, color: TColors.executiveNavy),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUMMARY OVERVIEW',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: TColors.slate600),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: TColors.executiveNavy, width: 2.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AVG ATTENDANCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: TColors.slate600)),
                      const SizedBox(height: 4),
                      Text(
                        '${reportsController.averageAttendance.value.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1.0, color: TColors.executiveNavy),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: TColors.blue100, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Iconsax.status_up, color: TColors.executiveNavy, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1.5),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('SESSIONS', reportsController.sessions.length.toString(), Iconsax.calendar_1, TColors.executiveNavy),
                  _buildSummaryItem('PRESENT', reportsController.presentCount.toString(), Iconsax.tick_circle, const Color(0xFF10B981)),
                  _buildSummaryItem('ABSENT', reportsController.absentCount.toString(), Iconsax.close_circle, const Color(0xFFEF4444)),
                  _buildSummaryItem('LATE', reportsController.lateCount.toString(), Iconsax.clock, const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => reportsController.updateSearchQuery(value),
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                hintText: 'SEARCH BY ROLL, NAME...',
                prefixIcon: Icon(Iconsax.search_normal),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: TColors.executiveNavy,
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('STUDENT NAME', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5))),
                _buildHeaderCell('P', 1),
                _buildHeaderCell('A', 1),
                _buildHeaderCell('L', 1),
                _buildHeaderCell('%', 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label, 
        textAlign: TextAlign.center, 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)
      ),
    );
  }

  Widget _buildStudentRow(BuildContext context, dynamic student, Map<String, dynamic> stats) {
    final pCount = stats['presentCount'] ?? 0;
    final aCount = stats['absentCount'] ?? 0;
    final lCount = stats['lateCount'] ?? 0;
    final percentage = stats['attendancePercentage'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: const BoxDecoration(
        color: TColors.white,
        border: Border(
          left: BorderSide(color: TColors.slate400, width: 1.5),
          right: BorderSide(color: TColors.slate400, width: 1.5),
          bottom: BorderSide(color: TColors.slate200, width: 1.0),
        ),
      ),
      child: InkWell(
        onTap: () => reportsController.navigateToStudentDetail(student),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: TColors.slate900), overflow: TextOverflow.ellipsis),
                  Text('ROLL: ${student.rollNumber}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: TColors.slate600)),
                ],
              ),
            ),
            _buildDataCell(pCount.toString(), 1, const Color(0xFF10B981)),
            _buildDataCell(aCount.toString(), 1, const Color(0xFFEF4444)),
            _buildDataCell(lCount.toString(), 1, const Color(0xFFF59E0B)),
            _buildDataCell(
              '${percentage.toStringAsFixed(0)}%', 
              1, 
              percentage >= 75 ? TColors.executiveNavy : const Color(0xFFEF4444),
              isBold: true
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String value, int flex, Color color, {bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        value, 
        textAlign: TextAlign.center, 
        style: TextStyle(
          color: color, 
          fontWeight: isBold ? FontWeight.w900 : FontWeight.w800, 
          fontSize: 12
        )
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: const Center(
        child: Text(
          'NO STUDENTS FOUND', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: TColors.slate400)
        )
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: TColors.slate600, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) => _buildShimmerBlock()),
      ),
    );
  }

  Widget _buildShimmerBlock() {
    return Shimmer.fromColors(
      baseColor: TColors.slate200,
      highlightColor: TColors.white,
      child: Container(
        height: 100, 
        width: double.infinity, 
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
