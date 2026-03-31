import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/attendance_reports_controller.dart';

class ReportsFluent extends StatelessWidget {
  const ReportsFluent({super.key});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    const accentColor = Color(0xFF0078D4);
    final controller = Get.find<AttendanceReportsController>();

    return Container(
      color: fluentBg,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFluentHeader('Analytics & Insights'),
          _buildFluentNode(
            context,
            title: 'Attendance Summary',
            desc: 'Global trends and overview',
            icon: Iconsax.chart_21,
            color: accentColor,
            onTap: () => Get.toNamed('/attendance-reports'),
          ),
          _buildFluentNode(
            context,
            title: 'Student Performance',
            desc: 'Metric analysis and logs',
            icon: Iconsax.user_octagon,
            color: const Color(0xFF498205),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildFluentHeader('Data Export'),
          _buildFluentNode(
            context,
            title: 'Generate PDF Report',
            desc: 'Official digital records',
            icon: Iconsax.document_1,
            color: const Color(0xFFD83B01),
            onTap: () {},
          ),
          _buildFluentNode(
            context,
            title: 'Excel Spreadsheet',
            desc: 'Raw data for processing',
            icon: Iconsax.document_cloud,
            color: const Color(0xFF107C10),
            onTap: () => controller.exportAttendanceReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildFluentHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF201F1E), fontSize: 13, letterSpacing: -0.2)),
    );
  }

  Widget _buildFluentNode(BuildContext context, {required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(4)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF201F1E), letterSpacing: -0.2)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Color(0xFF605E5C), letterSpacing: 0)),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: Colors.black.withOpacity(0.1), size: 18),
          ],
        ),
      ),
    );
  }
}
