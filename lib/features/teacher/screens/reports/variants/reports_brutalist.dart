import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/attendance_reports_controller.dart';

class ReportsBrutalist extends StatelessWidget {
  const ReportsBrutalist({super.key});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    final controller = Get.find<AttendanceReportsController>();

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildBrutalHeader('ANALYTICS_&_METRICS', yellow),
          _buildBrutalNode(
            context,
            title: 'Attendance Summary',
            desc: 'Global trend analysis',
            icon: Iconsax.chart_21,
            color: yellow,
            onTap: () => Get.toNamed('/attendance-reports'),
          ),
          _buildBrutalNode(
            context,
            title: 'Student Performance',
            desc: 'Metric logs and node data',
            icon: Iconsax.user_octagon,
            color: orange,
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildBrutalHeader('DATA_EXPORT_VECTORS', blue),
          _buildBrutalNode(
            context,
            title: 'Generate PDF Log',
            desc: 'Official document export',
            icon: Iconsax.document_1,
            color: orange,
            onTap: () {},
          ),
          _buildBrutalNode(
            context,
            title: 'Excel Spreadsheet',
            desc: 'Raw analytics data dump',
            icon: Iconsax.document_cloud,
            color: blue,
            onTap: () => controller.exportAttendanceReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      child: Row(
        children: [
          Container(width: 8, height: 24, color: Colors.black),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildBrutalNode(BuildContext context, {required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [BoxShadow(color: color, offset: const Offset(8, 8))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, border: Border.all(color: Colors.black, width: 2)), child: Icon(icon, color: Colors.black, size: 24)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black, letterSpacing: 1)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Colors.black, size: 18),
          ],
        ),
      ),
    );
  }
}
