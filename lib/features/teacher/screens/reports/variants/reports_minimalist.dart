import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/attendance_reports_controller.dart';

class ReportsMinimalist extends StatelessWidget {
  const ReportsMinimalist({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceReportsController>();

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        children: [
          _buildMinimalHeader('ANALYTICS'),
          _buildMinimalNode(
            context,
            title: 'Attendance Summary',
            desc: 'Trends and statistics overview',
            icon: Iconsax.chart_21,
            color: Colors.black54,
            onTap: () => Get.toNamed('/attendance-reports'),
          ),
          _buildMinimalNode(
            context,
            title: 'Student Performance',
            desc: 'Individual records and metrics',
            icon: Iconsax.user_octagon,
            color: Colors.black54,
            onTap: () {},
          ),
          const SizedBox(height: 48),
          _buildMinimalHeader('EXPORT DATA'),
          _buildMinimalNode(
            context,
            title: 'Generate PDF Report',
            desc: 'Official document generation',
            icon: Iconsax.document_text1,
            color: Colors.black54,
            onTap: () {},
          ),
          _buildMinimalNode(
            context,
            title: 'Export to Spreadsheet',
            desc: 'Raw data in Excel format',
            icon: Iconsax.document_cloud,
            color: Colors.black54,
            onTap: () => controller.exportAttendanceReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 16),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.black38, fontSize: 11, letterSpacing: 2)),
    );
  }

  Widget _buildMinimalNode(BuildContext context, {required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: Row(
          children: [
            Icon(icon, color: Colors.black12, size: 28),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black38, letterSpacing: 0)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Colors.black12, size: 16),
          ],
        ),
      ),
    );
  }
}
