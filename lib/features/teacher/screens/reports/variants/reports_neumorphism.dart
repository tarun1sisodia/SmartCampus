import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/attendance_reports_controller.dart';

class ReportsNeumorphism extends StatelessWidget {
  const ReportsNeumorphism({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);
    final controller = Get.find<AttendanceReportsController>();

    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildNeuHeader('ANALYTICS & INSIGHTS'),
          _buildNeuNode(
            context,
            title: 'Attendance Summary',
            desc: 'Trends and overview',
            icon: Iconsax.chart_21,
            onTap: () => Get.toNamed('/attendance-reports'),
            bgColor: bgColor,
          ),
          _buildNeuNode(
            context,
            title: 'Student Performance',
            desc: 'Metric analysis',
            icon: Iconsax.user_octagon,
            onTap: () {},
            bgColor: bgColor,
          ),
          const SizedBox(height: 32),
          _buildNeuHeader('DATA EXPORT'),
          _buildNeuNode(
            context,
            title: 'Generate PDF',
            desc: 'Digital records',
            icon: Iconsax.document_1,
            onTap: () {},
            bgColor: bgColor,
          ),
          _buildNeuNode(
            context,
            title: 'Export Excel',
            desc: 'Raw spreadsheet',
            icon: Iconsax.document_cloud,
            onTap: () => controller.exportAttendanceReport(),
            bgColor: bgColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNeuHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4D565F), fontSize: 13, letterSpacing: 1.5)),
    );
  }

  Widget _buildNeuNode(BuildContext context, {required String title, required String desc, required IconData icon, required VoidCallback onTap, required Color bgColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
            BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(10, 10), blurRadius: 20),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
                  BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
                ],
              ),
              child: Icon(icon, color: const Color(0xFFA3B1C6), size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF4D565F), letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Color(0xFFA3B1C6), size: 18),
          ],
        ),
      ),
    );
  }
}
