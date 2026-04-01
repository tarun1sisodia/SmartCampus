import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/attendance_reports_controller.dart';

class ReportsCorporate extends StatelessWidget {
  const ReportsCorporate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceReportsController>();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader('ANALYTICS_&_INSIGHTS'),
          _buildReportNode(
            context,
            title: 'ATTENDANCE_SUMMARY',
            desc: 'GLOBAL_OVERVIEW_OF_INSTITUTIONAL_TRENDS',
            icon: Iconsax.chart_2,
            color: const Color(0xFF0F172A),
            onTap: () => Get.toNamed('/attendance-reports'),
          ),
          _buildReportNode(
            context,
            title: 'STUDENT_PERFORMANCE',
            desc: 'INDIVIDUAL_METRIC_ANALYSIS_AND_LOGS',
            icon: Iconsax.user_octagon,
            color: const Color(0xFF0F172A),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildHeader('DATA_EXPORT_VECTOR'),
          _buildReportNode(
            context,
            title: 'EXPORT_PDF_DOCUMENT',
            desc: 'SYSTEM_GENERATED_OFFICIAL_RECORDS',
            icon: Iconsax.document_1,
            color: const Color(0xFFE11D48),
            onTap: () {},
          ),
          _buildReportNode(
            context,
            title: 'EXPORT_EXCEL_SPREADSHEET',
            desc: 'RAW_DATA_FOR_EXTERNAL_PROCESSING',
            icon: Iconsax.document_text,
            color: const Color(0xFF2563EB),
            onTap: () => controller.exportAttendanceReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 13, letterSpacing: 1.5)),
    );
  }

  Widget _buildReportNode(BuildContext context, {required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 2), boxShadow: const [BoxShadow(color: Color(0xFFE2E8F0), offset: Offset(6, 6))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.05), border: Border.all(color: color.withValues(alpha: 0.1))), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A), letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF64748B), letterSpacing: 1)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Color(0xFF0F172A), size: 18),
          ],
        ),
      ),
    );
  }
}
