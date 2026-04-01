import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/session_details_controller.dart';
import '../../../common/utils/constants/sized.dart';

class SessionDetailsCyberpunk extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsCyberpunk({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const neonCyan = Color(0xFF00F5FF);
    const neonMagenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildHUDGrid(neonCyan),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: neonCyan));
            }

            if (controller.session.value == null) {
              return Center(child: Text('VOID_BUFFER_ERROR', style: TextStyle(color: neonCyan.withValues(alpha: 0.5), fontWeight: FontWeight.w900)));
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildCyberHeader(neonCyan),
                const SizedBox(height: 24),
                _buildCyberStatsGrid(neonCyan, neonMagenta),
                const SizedBox(height: 24),
                _buildCyberActionCluster(neonCyan, neonMagenta),
                const SizedBox(height: 32),
                const Text('TERMINAL_ROSTER_STREAM', style: TextStyle(color: Color(0xFF00F5FF), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Courier')),
                const SizedBox(height: 16),
                _buildCyberRoster(neonCyan, neonMagenta),
                const SizedBox(height: 64),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHUDGrid(Color cyan) {
    return Positioned.fill(
      child: CustomPaint(
        painter: CyberGridPainter(color: cyan.withValues(alpha: 0.04)),
      ),
    );
  }

  Widget _buildCyberHeader(Color cyan) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan, width: 2), boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.2), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Expanded(child: Text((classDetails['subjectName'] ?? 'NULL_UNIT').toUpperCase(), style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1, fontFamily: 'Courier', shadows: [Shadow(color: cyan, blurRadius: 10)]))),
               if (isActive)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                   decoration: BoxDecoration(border: Border.all(color: cyan), color: cyan.withValues(alpha: 0.1)),
                   child: Text('LIVE', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 10)),
                 ),
             ],
          ),
          const SizedBox(height: 8),
          Text('${classDetails['courseName']} | NODE ${classDetails['semester']}'.toUpperCase(), style: TextStyle(color: cyan.withValues(alpha: 0.5), fontWeight: FontWeight.w800, fontSize: 10, fontFamily: 'Courier')),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildCyberMeta(Iconsax.calendar_1, controller.formatDate(session.date).toUpperCase(), cyan),
               _buildCyberMeta(Iconsax.clock, '${session.startTime} - ${session.endTime}', cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCyberMeta(IconData icon, String val, Color cyan) {
    return Row(
      children: [
        Icon(icon, color: cyan, size: 14),
        const SizedBox(width: 8),
        Text(val, style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Courier')),
      ],
    );
  }

  Widget _buildCyberStatsGrid(Color cyan, Color magenta) {
    final stats = controller.attendanceStats.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan.withValues(alpha: 0.3))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCyberStatNode('ROSTER', stats.total, cyan),
              _buildCyberStatNode('PRESENT', stats.present, cyan),
              _buildCyberStatNode('ABSENT', stats.absent, magenta),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: stats.presentPercentage / 100,
            backgroundColor: cyan.withValues(alpha: 0.05),
            color: cyan,
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCyberStatNode(String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 24, shadows: [Shadow(color: color, blurRadius: 5)])),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 9, fontFamily: 'Courier')),
      ],
    );
  }

  Widget _buildCyberActionCluster(Color cyan, Color magenta) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: isActive ? controller.generateQRCode : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: cyan, width: 1.5), color: cyan.withValues(alpha: 0.05)),
              child: Center(child: Text('GENERATION_QR', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: controller.exportAttendanceData,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: magenta, width: 1.5), color: magenta.withValues(alpha: 0.05)),
              child: Center(child: Text('DATA_EXPORT', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCyberRoster(Color cyan, Color magenta) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return Center(child: Text('VOID_BUFFER', style: TextStyle(color: cyan.withValues(alpha: 0.3), fontWeight: FontWeight.w900)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: record.isPresent ? cyan : magenta.withValues(alpha: 0.3))),
          child: ListTile(
             contentPadding: const EdgeInsets.all(16),
             leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(border: Border.all(color: record.isPresent ? cyan : magenta), color: record.isPresent ? cyan.withValues(alpha: 0.1) : magenta.withValues(alpha: 0.1)),
                child: Center(child: Icon(record.isPresent ? Iconsax.verify : Iconsax.close_circle, color: record.isPresent ? cyan : magenta, size: 20)),
             ),
             title: Text(record.studentName.toUpperCase(), style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5, fontFamily: 'Courier')),
             subtitle: Text('ID_NODE: ${record.studentId}'.toUpperCase(), style: TextStyle(color: cyan.withValues(alpha: 0.4), fontWeight: FontWeight.w800, fontSize: 9, fontFamily: 'Courier')),
             trailing: controller.isSessionActive() 
                ? Switch(
                    value: record.isPresent, 
                    onChanged: (v) => controller.toggleAttendance(record.id, v),
                    activeThumbColor: cyan,
                  )
                : null,
          ),
        );
      },
    );
  }
}

class CyberGridPainter extends CustomPainter {
  final Color color;
  CyberGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.0;
    const double step = 40.0;
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
