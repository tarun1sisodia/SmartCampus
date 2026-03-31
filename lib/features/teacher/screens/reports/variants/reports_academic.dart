import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/attendance_reports_controller.dart';

class ReportsAcademic extends StatelessWidget {
  const ReportsAcademic({super.key});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513);

    final controller = Get.find<AttendanceReportsController>();

    return Container(
      color: paperColor,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildScholarHeader('ANALYTICAL_FOLIO', inkColor),
          _buildScholarNode(
            context,
            title: 'Attendance Summary',
            desc: 'Global trends and scholarly overview',
            icon: Iconsax.chart_21,
            color: inkColor,
            onTap: () => Get.toNamed('/attendance-reports'),
          ),
          _buildScholarNode(
            context,
            title: 'Student Performance',
            desc: 'Individual records and metrics catalogue',
            icon: Iconsax.user_octagon,
            color: inkColor,
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildScholarHeader('OFFICIALExports', accentColor),
          _buildScholarNode(
            context,
            title: 'Generate PDF Ledger',
            desc: 'Formal digital record export',
            icon: Iconsax.document_1,
            color: inkColor,
            onTap: () {},
          ),
          _buildScholarNode(
            context,
            title: 'Excel Spreadsheet',
            desc: 'Raw analytical data for processing',
            icon: Iconsax.document_cloud,
            color: inkColor,
            onTap: () => controller.exportAttendanceReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      child: Row(
        children: [
          Container(width: 2, height: 20, color: color),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Serif')),
        ],
      ),
    );
  }

  Widget _buildScholarNode(BuildContext context, {required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: color.withOpacity(0.4), size: 24)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color, letterSpacing: 0, fontFamily: 'Serif')),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: color.withOpacity(0.4), letterSpacing: 0.5, fontFamily: 'Serif')),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: color.withOpacity(0.2), size: 18),
          ],
        ),
      ),
    );
  }
}
