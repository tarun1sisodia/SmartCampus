import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../. ./../../common/ui_patterns/ui_style.dart';
import '../../../controllers/attendance_reports_controller.dart';

class AttendanceReportsCyberpunk extends StatelessWidget {
  final AttendanceReportsController controller;

  const AttendanceReportsCyberpunk({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const neonCyan = Color(0xFF00F5FF);
    const neonMagenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridBackground(neonCyan),
          Column(
            children: [
               _buildHUDHeader(neonCyan, neonMagenta),
               Expanded(
                 child: Obx(() {
                   if (controller.isLoading.value && controller.sessions.isEmpty) {
                     return const Center(child: CircularProgressIndicator(color: neonCyan));
                   }

                   return ListView(
                     padding: const EdgeInsets.all(20),
                     children: [
                       _buildAnalyticHUD(neonCyan, neonMagenta),
                       const SizedBox(height: 32),
                       Text(
                         'DATA_NODES_ACTIVE',
                         style: TextStyle(color: neonCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, shadows: [Shadow(color: neonCyan, blurRadius: 10)]),
                       ),
                       const SizedBox(height: 16),
                       _buildCyberList(neonCyan, neonMagenta),
                       const SizedBox(height: 64),
                     ],
                   );
                 }),
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridBackground(Color cyan) {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(color: cyan.withValues(alpha: 0.05)),
      ),
    );
  }

  Widget _buildHUDHeader(Color cyan, Color magenta) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: cyan.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: cyan, width: 2)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildTerminalDropdown(cyan)),
          const SizedBox(width: 12),
          _buildHUDAction(Iconsax.calendar, () => _pickDateRange(), magenta),
        ],
      ),
    );
  }

  Widget _buildTerminalDropdown(Color cyan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: cyan.withValues(alpha: 0.5)), color: Colors.black),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedClassId.value,
          dropdownColor: Colors.black,
          icon: Icon(Iconsax.arrow_down_1, size: 16, color: cyan),
          items: controller.classes.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(
              '${c.subjectName}'.toUpperCase(),
              style: TextStyle(color: cyan, fontWeight: FontWeight.w800, fontSize: 11, fontFamily: 'Courier'),
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

  Widget _buildHUDAction(IconData icon, VoidCallback onTap, Color magenta) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(border: Border.all(color: magenta), color: magenta.withValues(alpha: 0.05)),
        child: Center(child: Icon(icon, color: magenta, size: 20)),
      ),
    );
  }

  Widget _buildAnalyticHUD(Color cyan, Color magenta) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: cyan, width: 2),
        boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.2), blurRadius: 20)],
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BUFFER_PERCENTAGE', style: TextStyle(color: cyan.withValues(alpha: 0.5), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
                  Obx(() => Text(
                    '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                    style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 44, height: 1, shadows: [Shadow(color: cyan, blurRadius: 15)]),
                  )),
                ],
              ),
              Icon(Iconsax.radar, size: 48, color: magenta),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildHUDMetric('PRES', controller.presentCount.toString(), const Color(0xFF10B981)),
               _buildHUDMetric('ABS', controller.absentCount.toString(), const Color(0xFFEF4444)),
               _buildHUDMetric('LATE', controller.lateCount.toString(), const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHUDMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildCyberList(Color cyan, Color magenta) {
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
        final activeColor = percentage >= 75 ? cyan : magenta;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: activeColor.withValues(alpha: 0.5)),
          ),
          child: ListTile(
            onTap: () => controller.navigateToStudentDetail(student),
            title: Text(
              student.name.toString().toUpperCase(),
              style: TextStyle(color: activeColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
            ),
            subtitle: Text(
              'RE_ID_${student.rollNumber}',
              style: TextStyle(color: activeColor.withValues(alpha: 0.5), fontWeight: FontWeight.w800, fontSize: 10),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: activeColor)),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(color: activeColor, fontWeight: FontWeight.w900, fontSize: 12),
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

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
