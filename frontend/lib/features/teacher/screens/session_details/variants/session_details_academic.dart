import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../controllers/session_details_controller.dart';

class SessionDetailsAcademic extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsAcademic({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown
    final tokens = PatternTokens.get(UIStyle.academicClassic);

    return Container(
      color: paperColor,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: accentColor));
        }

        if (controller.session.value == null) {
          return Center(child: Text('CURRICULAR_LOG_VOID', style: TextStyle(color: inkColor.withValues(alpha: 0.5), fontFamily: 'Serif')));
        }

        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            _buildScholarHeader(paperColor, inkColor, accentColor),
            const SizedBox(height: 32),
            _buildScholarStats(paperColor, inkColor, accentColor),
            const SizedBox(height: 32),
            _buildScholarActions(paperColor, inkColor, accentColor),
            const SizedBox(height: 48),
            Center(child: Text('Academic Register Manifest', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Serif', color: inkColor, letterSpacing: 0.5))),
            const SizedBox(height: 16),
            _buildScholarRoster(paperColor, inkColor, accentColor),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildScholarHeader(Color paper, Color ink, Color accent) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: accent.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.02), blurRadius: 20)]),
      child: Column(
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: accent), borderRadius: BorderRadius.circular(20)),
              child: Text('LIVE SESSION', style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 8, fontFamily: 'Serif')),
            ),
          const SizedBox(height: 16),
          Text(classDetails['subjectName'] ?? 'Academic Unit', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: ink, fontFamily: 'Serif', letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('${classDetails['courseName']} | Semester ${classDetails['semester']}'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: ink.withValues(alpha: 0.5), fontFamily: 'Serif', letterSpacing: 1)),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
               _buildScholarMeta(Iconsax.calendar_1, controller.formatDate(session.date), ink),
               _buildScholarMeta(Iconsax.clock, '${session.startTime} - ${session.endTime}', ink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScholarMeta(IconData icon, String val, Color ink) {
    return Row(
      children: [
        Icon(icon, color: ink.withValues(alpha: 0.4), size: 14),
        const SizedBox(width: 8),
        Text(val, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: ink, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarStats(Color paper, Color ink, Color accent) {
    final stats = controller.attendanceStats.value;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: accent.withValues(alpha: 0.1))),
      child: Column(
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _buildScholarStatNode('TOTAL', stats.total, ink),
               _buildScholarStatNode('PRESENT', stats.present, accent),
               _buildScholarStatNode('ABSENT', stats.absent, ink.withValues(alpha: 0.4)),
             ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(height: 1, width: double.infinity, color: ink.withValues(alpha: 0.05)),
              Container(height: 1, width: Get.width * (stats.presentPercentage / 300), color: accent),
            ],
          ),
          const SizedBox(height: 8),
          Text('Fulfillment Rate: ${stats.presentPercentage.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: ink.withValues(alpha: 0.5), fontFamily: 'Serif', fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildScholarStatNode(String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: color, fontFamily: 'Serif')),
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9, color: Colors.black38, fontFamily: 'Serif')),
      ],
    );
  }

  Widget _buildScholarActions(Color paper, Color ink, Color accent) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: isActive ? controller.generateQRCode : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: ink, border: Border.all(color: ink)),
              child: const Center(child: Text('GENERATE_QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, fontFamily: 'Serif'))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: controller.exportAttendanceData,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink)),
              child: Center(child: Text('EXPORT_LEDGER', style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 10, fontFamily: 'Serif'))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScholarRoster(Color paper, Color ink, Color accent) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return Center(child: Text('LOG_VOID', style: TextStyle(color: ink.withValues(alpha: 0.3), fontFamily: 'Serif')));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.1)))),
          child: ListTile(
             contentPadding: const EdgeInsets.all(16),
             leading: CircleAvatar(
                backgroundColor: paper,
                child: Icon(record.isPresent ? Iconsax.verify : Iconsax.close_circle, color: record.isPresent ? accent : ink.withValues(alpha: 0.2), size: 20),
             ),
             title: Text(record.studentName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ink, fontFamily: 'Serif')),
             subtitle: Text('ID: ${record.studentId}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: ink.withValues(alpha: 0.4), fontFamily: 'Serif')),
             trailing: controller.isSessionActive() 
                ? Switch(
                    value: record.isPresent, 
                    onChanged: (v) => controller.toggleAttendance(record.id, v),
                    activeThumbColor: accent,
                  )
                : null,
          ),
        );
      },
    );
  }
}
