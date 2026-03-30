import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
      appBar: AppBar(
        title: Text(
          'Attendance Reports',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () => reportsController.loadAttendanceData(),
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => reportsController.exportAttendanceReport(),
            icon: const Icon(Iconsax.export),
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
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).cardTheme.color ?? Colors.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Selection and Summary Section
              SliverPadding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Class selection
                      _buildClassSelectionCard(context),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      // Date range selection
                      _buildDateRangeCard(context),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      // Attendance summary (Only if data exists)
                      if (reportsController.sessions.isNotEmpty)
                        _buildAttendanceSummary(context),
                    ],
                  ),
                ),
              ),

              // Student list header and search
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        'Student Attendance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      _buildTableHeader(context),
                    ],
                  ),
                ),
              ),

              // Virtualized Student List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                sliver: Obx(() {
                  final filteredStudents = reportsController.displayStudents;
                  
                  if (filteredStudents.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildEmptyState(context),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final student = filteredStudents[index];
                        final stats = reportsController.getStudentStats(student.id);
                        if (stats == null) return const SizedBox.shrink();

                        final isLast = index == filteredStudents.length - 1;
                        final hasMore = reportsController.hasMoreStudentsInReport.value;

                        return _buildStudentRow(context, student, stats, isLast && !hasMore);
                      },
                      childCount: filteredStudents.length,
                    ),
                  );
                }),
              ),

              // Load More Button
              SliverPadding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                sliver: SliverToBoxAdapter(
                  child: Obx(() {
                    if (!reportsController.hasMoreStudentsInReport.value) return const SizedBox.shrink();
                    return Center(
                      child: reportsController.isLoadingMoreReport.value
                          ? const CircularProgressIndicator()
                          : OutlinedButton(
                              onPressed: reportsController.loadMoreReportStudents,
                              child: const Text('Load More Students'),
                            ),
                    );
                  }),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: TSizes.spaceBtwSections)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildClassSelectionCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Class', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: TSizes.spaceBtwItems),
            if (reportsController.classes.isEmpty)
              const Center(child: Text('No classes available'))
            else
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(TSizes.inputFieldRadius)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.md),
                  isCollapsed: true,
                ),
                isExpanded: true,
                iconSize: 24,
                icon: const Icon(Iconsax.arrow),
                value: reportsController.selectedClassId.value,
                items: reportsController.classes.map((classItem) {
                  return DropdownMenuItem<String>(
                    value: classItem.id,
                    child: Text(
                      '${classItem.subjectName} - ${classItem.courseName} Year ${classItem.semester}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14),
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
      ),
    );
  }

  Widget _buildDateRangeCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date Range', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: TSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(
                  child: InkWell(
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
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(TSizes.inputFieldRadius)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
                        suffixIcon: const Icon(Iconsax.calendar),
                      ),
                      child: Text(DateFormat('MMM d, yyyy').format(reportsController.startDate.value)),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: InkWell(
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
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(TSizes.inputFieldRadius)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
                        suffixIcon: const Icon(Iconsax.calendar),
                      ),
                      child: Text(DateFormat('MMM d, yyyy').format(reportsController.endDate.value)),
                    ),
                  ),
                ),
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
        Text(
          'Attendance Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 10.0,
                      animation: true,
                      animationDuration: 2000,
                      percent: reportsController.averageAttendance.value / 100,
                      center: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: reportsController.averageAttendance.value),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Text(
                            '${value.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      footer: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Average Attendance', style: Theme.of(context).textTheme.bodySmall),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    Column(
                      children: [
                        _buildSummaryItem(context, 'Sessions', reportsController.sessions.length.toString(), Iconsax.calendar_1, Theme.of(context).colorScheme.primary),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildSummaryItem(context, 'Students', reportsController.students.length.toString(), Iconsax.people, Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(context, 'Present', reportsController.presentCount.toString(), Iconsax.tick_circle, Colors.green),
                    _buildSummaryItem(context, 'Absent', reportsController.absentCount.toString(), Iconsax.close_circle, Colors.red),
                    _buildSummaryItem(context, 'Late', reportsController.lateCount.toString(), Iconsax.clock, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusMd)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => reportsController.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search students by Roll, Name...',
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.sm),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Container(
              padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
              ),
              child: Row(
                children: [
                  const SizedBox(width: TSizes.sm),
                  Expanded(flex: 3, child: Text('Student\'s name', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('P', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('A', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('L', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('%', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(BuildContext context, dynamic student, Map<String, dynamic> stats, bool isLast) {
    final pCount = stats['presentCount'] ?? 0;
    final aCount = stats['absentCount'] ?? 0;
    final lCount = stats['lateCount'] ?? 0;
    final percentage = stats['attendancePercentage'] ?? 0.0;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(TSizes.cardRadiusMd)) : BorderRadius.zero,
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: () => reportsController.navigateToStudentDetail(student),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TSizes.md, horizontal: TSizes.md),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        Text(student.rollNumber, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Text(pCount.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.green))),
                  Expanded(flex: 1, child: Text(aCount.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))),
                  Expanded(flex: 1, child: Text(lCount.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.orange))),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: percentage >= 75 ? Theme.of(context).colorScheme.primary : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(TSizes.cardRadiusMd)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Center(child: Text('No students found', style: Theme.of(context).textTheme.bodyMedium)),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: TSizes.xs),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(4, (index) => _buildShimmerCard(context)),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface.withValues(alpha: 0.5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Card(
        margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
        child: Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(TSizes.cardRadiusMd))),
      ),
    );
  }
}
