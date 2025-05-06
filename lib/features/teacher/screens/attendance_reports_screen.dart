import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../controllers/attendance_reports_controller.dart';

class AttendanceReportsScreen extends StatelessWidget {
  final reportsController = Get.put(AttendanceReportsController());

  AttendanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer for Class selection card
                Shimmer.fromColors(
                 baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                  highlightColor: dark ? TColors.yellow : TColors.primary,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(TSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 120,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          Container(
                            height: 40,
                            width: double.infinity,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Shimmer for Date range card
                Shimmer.fromColors(
                 baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                  highlightColor: dark ? TColors.yellow : TColors.primary,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(TSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 120,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 40,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Shimmer for Attendance summary
                Shimmer.fromColors(
baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                  highlightColor: dark ? TColors.yellow : TColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 180,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusMd),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(TSizes.md),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 80,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(
                                          height: TSizes.spaceBtwItems),
                                      Container(
                                        height: 20,
                                        width: 80,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              const Divider(),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: 20,
                                    width: 60,
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    height: 20,
                                    width: 60,
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    height: 20,
                                    width: 60,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Shimmer for Student attendance table
                Shimmer.fromColors(
                  baseColor: dark ? TColors.darkerGrey : Colors.grey.shade300,
                  highlightColor: dark ? TColors.yellow : TColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 180,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusMd),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              width: double.infinity,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: TSizes.sm,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: TSizes.sm),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          height: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            //print('Refreshing dashboard data');
            await reportsController.loadAttendanceData();
          },
          color: dark ? TColors.yellow : TColors.primary,
          backgroundColor: dark ? TColors.darkerGrey : Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class selection
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Class',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        if (reportsController.classes.isEmpty)
                          Center(
                            child: Text(
                              'No classes available',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TSizes.inputFieldRadius,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TSizes.md,
                                vertical: TSizes.md,
                              ),
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
                                  style: TextStyle(fontSize: 14),
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
                ),

                const SizedBox(height: TSizes.spaceBtwItems),

                // Date range selection
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date Range',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        reportsController.startDate.value,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) {
                                    reportsController.startDate.value =
                                        pickedDate;
                                    reportsController.loadAttendanceData();
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Start Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        TSizes.inputFieldRadius,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: TSizes.md,
                                      vertical: TSizes.sm,
                                    ),
                                    suffixIcon: const Icon(Iconsax.calendar),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'MMM d, yyyy',
                                    ).format(reportsController.startDate.value),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        reportsController.endDate.value,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) {
                                    reportsController.endDate.value =
                                        pickedDate;
                                    reportsController.loadAttendanceData();
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'End Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        TSizes.inputFieldRadius,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: TSizes.md,
                                      vertical: TSizes.sm,
                                    ),
                                    suffixIcon: const Icon(Iconsax.calendar),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'MMM d, yyyy',
                                    ).format(reportsController.endDate.value),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                // Attendance summary
                if (reportsController.sessions.isNotEmpty) ...[
                  Text(
                    'Attendance Summary',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
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
                                percent:
                                    reportsController.averageAttendance.value /
                                        100,
                                center: Text(
                                  '${reportsController.averageAttendance.value.toStringAsFixed(1)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                footer: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Average Attendance',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor:
                                    dark ? TColors.yellow : TColors.primary,
                                backgroundColor: dark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              Column(
                                children: [
                                  _buildSummaryItem(
                                    context,
                                    'Sessions',
                                    reportsController.sessions.length
                                        .toString(),
                                    Iconsax.calendar_1,
                                    dark ? TColors.yellow : TColors.primary,
                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),
                                  _buildSummaryItem(
                                    context,
                                    'Students',
                                    reportsController.students.length
                                        .toString(),
                                    Iconsax.people,
                                    dark ? TColors.yellow : TColors.primary,
                                  ),
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
                              _buildSummaryItem(
                                context,
                                'Present',
                                reportsController.presentCount.toString(),
                                Iconsax.tick_circle,
                                Colors.green,
                              ),
                              _buildSummaryItem(
                                context,
                                'Absent',
                                reportsController.absentCount.toString(),
                                Iconsax.close_circle,
                                Colors.red,
                              ),
                              _buildSummaryItem(
                                context,
                                'Late',
                                reportsController.lateCount.toString(),
                                Iconsax.clock,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Student attendance table
                  Text(
                    'Student Attendance',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                    ),
                    child: Column(
                      children: [
                        // Search field
                        TextField(
                          onChanged: (value) =>
                              reportsController.searchQuery.value = value,
                          decoration: InputDecoration(
                            hintText:
                                'Search students by their Roll,Name,Branch...etc',
                            prefixIcon: const Icon(Iconsax.search_normal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                TSizes.inputFieldRadius,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: TSizes.md,
                              vertical: TSizes.sm,
                            ),
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Table header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: TSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: dark
                                ? const Color.fromARGB(255, 67, 115, 226)
                                : const Color.fromARGB(255, 28, 219, 229),
                            borderRadius: BorderRadius.circular(
                              TSizes.borderRadiusSm,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: TSizes.sm),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Student\'s name',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'P',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'A',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'L',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table rows
                        Obx(() {
                          final filteredStudents =
                              reportsController.students.where((student) {
                            return student.name.toLowerCase().contains(
                                  reportsController.searchQuery.value
                                      .toLowerCase(),
                                );
                          }).toList();

                          if (filteredStudents.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(
                                TSizes.defaultSpace,
                              ),
                              child: Center(
                                child: Text(
                                  'No students found',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredStudents.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              final stats =
                                  reportsController.studentStats[student.id];

                              if (stats == null) return const SizedBox.shrink();

                              final presentCount = stats['presentCount'] as int;
                              final absentCount = stats['absentCount'] as int;
                              final lateCount = stats['lateCount'] as int;
                              final attendancePercentage =
                                  stats['attendancePercentage'] as double;

                              return InkWell(
                                onTap: () => reportsController
                                    .navigateToStudentDetail(student),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: TSizes.sm,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: TSizes.sm),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              'Roll: ${student.rollNumber}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          presentCount.toString(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          absentCount.toString(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          lateCount.toString(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getAttendanceColor(
                                              attendancePercentage,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${attendancePercentage.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ] else if (!reportsController.isLoading.value) ...[
                  // No data message
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(TSizes.defaultSpace),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.calendar_1,
                            size: 64,
                            color: dark ? TColors.yellow : TColors.primary,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),
                          Text(
                            'No Attendance Data',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          Text(
                            'Select a class and date range to view attendance reports',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 75) {
      return Colors.blue;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
