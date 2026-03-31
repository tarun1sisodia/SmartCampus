import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/attendance_reports_controller.dart';

class ReportsCyberpunk extends StatelessWidget {
  const ReportsCyberpunk({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);
    const yellow = Color(0xFFFFCC00);

    final controller = Get.find<AttendanceReportsController>();

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              _buildCyberHeader('ANALYTICAL_UPLINK', cyan),
              _buildCyberNode(
                context,
                title: 'ATTENDANCE_SUMMARY',
                desc: 'GLOBAL_NETWORK_TRENDS',
                icon: Iconsax.chart_21,
                color: cyan,
                onTap: () => Get.toNamed('/attendance-reports'),
              ),
              _buildCyberNode(
                context,
                title: 'STUDENT_METRICS',
                desc: 'NODE_PERFORMANCE_LOGS',
                icon: Iconsax.user_octagon,
                color: cyan,
                onTap: () {},
              ),
              const SizedBox(height: 32),
              _buildCyberHeader('DATA_EXTRACTION', magenta),
              _buildCyberNode(
                context,
                title: 'GENERATE_PDF_LOG',
                desc: 'ENCRYPTED_DOCUMENT_EXPORT',
                icon: Iconsax.document_1,
                color: magenta,
                onTap: () {},
              ),
              _buildCyberNode(
                context,
                title: 'EXPORT_SPREADSHEET',
                desc: 'RAW_DATABASE_DUMP',
                icon: Iconsax.document_cloud,
                color: magenta,
                onTap: () => controller.exportAttendanceReport(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GridPainter(color: cyan.withOpacity(0.04)),
      ),
    );
  }

  Widget _buildCyberHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      child: Row(
        children: [
          Container(width: 4, height: 14, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13, letterSpacing: 2, fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildCyberNode(BuildContext context, {required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color, letterSpacing: 1, fontFamily: 'Courier')),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: color.withOpacity(0.5), letterSpacing: 2, fontFamily: 'Courier')),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: color.withOpacity(0.3), size: 18),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 30.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
