import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/attendance_reports_controller.dart';

class AttendanceReportsBrutalist extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsBrutalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildBrutalControls(yellow),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sessions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildBrutalSummary(orange),
                  const SizedBox(height: 32),
                  const Text(
                    'DATA_STREAM_01',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -1, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  _buildBrutalList(blue),
                  const SizedBox(height: 64),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalControls(Color yellow) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildBrutalDropdown(yellow)),
          const SizedBox(width: 12),
          _buildBrutalDateAction(),
        ],
      ),
    );
  }

  Widget _buildBrutalDropdown(Color yellow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: yellow,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          dropdownColor: yellow,
          icon: const Icon(Iconsax.arrow_down_1, size: 16, color: Colors.black),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName}'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
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

  Widget _buildBrutalDateAction() {
    return InkWell(
      onTap: () => _pickDateRange(),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
        ),
        child: const Center(child: Icon(Iconsax.calendar_1, color: Colors.black, size: 20)),
      ),
    );
  }

  Widget _buildBrutalSummary(Color orange) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('PERCENTAGE_LOAD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black)),
                   Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 44, color: Colors.black, height: 1),
                  )),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: orange, border: Border.all(color: Colors.black, width: 3)),
                child: const Center(child: Icon(Iconsax.status_up, size: 32, color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 3, color: Colors.black),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildBrutalMetric('PRES', controller.presentCount.toString(), const Color(0xFF10B981)),
               _buildBrutalMetric('ABS', controller.absentCount.toString(), const Color(0xFFEF4444)),
               _buildBrutalMetric('LATE', controller.lateCount.toString(), const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(color: color, border: Border.all(color: Colors.black, width: 1.5)),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.black, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildBrutalList(Color blue) {
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
        final activeColor = percentage >= 75 ? blue : const Color(0xFFEF4444);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
          ),
          child: ListTile(
            onTap: () => controller.navigateToStudentDetail(student),
            title: Text(student.name.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.5)),
            subtitle: Text('ID_${student.rollNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: activeColor, border: Border.all(color: Colors.black, width: 2)),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
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
