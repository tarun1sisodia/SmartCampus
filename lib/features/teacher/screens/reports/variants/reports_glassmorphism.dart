import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/attendance_reports_controller.dart';

class ReportsGlassmorphism extends StatelessWidget {
  const ReportsGlassmorphism({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceReportsController>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            _buildGlassHeader('ANALYTICS & INSIGHTS'),
            _buildGlassNode(
              context,
              title: 'Attendance Summary',
              desc: 'Global trends and overview',
              icon: Iconsax.chart_21,
              onTap: () => Get.toNamed('/attendance-reports'),
            ),
            _buildGlassNode(
              context,
              title: 'Student Performance',
              desc: 'Metric analysis and logs',
              icon: Iconsax.user_octagon,
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildGlassHeader('DATA EXPORT'),
            _buildGlassNode(
              context,
              title: 'Export PDF Report',
              desc: 'Official digital records',
              icon: Iconsax.document_1,
              onTap: () {},
            ),
            _buildGlassNode(
              context,
              title: 'Excel Spreadsheet',
              desc: 'Raw data for processing',
              icon: Iconsax.document_cloud,
              onTap: () => controller.exportAttendanceReport(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
    );
  }

  Widget _buildGlassNode(BuildContext context, {required String title, required String desc, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.white70, size: 24)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text(desc, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.white54, letterSpacing: 0)),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, color: Colors.white30, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
