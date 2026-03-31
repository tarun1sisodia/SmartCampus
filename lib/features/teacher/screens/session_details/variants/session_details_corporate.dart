import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/session_details_controller.dart';
import '../../../common/utils/constants/colors.dart';

class SessionDetailsCorporate extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsCorporate({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.industrialCorporate);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
      }

      if (controller.session.value == null) {
        return const Center(child: Text('VOID_SESSION_ERROR', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red)));
      }

      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildCorporateHeader(tokens),
          const SizedBox(height: 24),
          _buildAnalyticsHUD(tokens),
          const SizedBox(height: 24),
          _buildActionPanel(tokens),
          const SizedBox(height: 32),
          const Text('ROSTER_MANIFEST_SECURE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          _buildStudentManifest(tokens),
          const SizedBox(height: 64),
        ],
      );
    });
  }

  Widget _buildCorporateHeader(Map<String, dynamic> tokens) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border.all(color: Colors.white, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text((classDetails['subjectName'] ?? 'UNIT_NAME').toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  color: const Color(0xFF10B981),
                  child: const Text('LIVE_NODE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHUDInfo('COURSE', (classDetails['courseName'] ?? 'N/A').toUpperCase()),
          _buildHUDInfo('SECTION', '${classDetails['section'] ?? 'N/A'}'),
          _buildHUDInfo('PERIOD', '${session.startTime} - ${session.endTime}'),
          _buildHUDInfo('DATE', controller.formatDate(session.date).toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildHUDInfo(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 9)),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsHUD(Map<String, dynamic> tokens) {
    final stats = controller.attendanceStats.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
      child: Column(
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _buildHUDStat('TOTAL', stats.total, const Color(0xFF0F172A)),
               _buildHUDStat('PRESENT', stats.present, const Color(0xFF10B981)),
               _buildHUDStat('ABSENT', stats.absent, Colors.red),
             ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(height: 4, width: double.infinity, color: const Color(0xFFF1F5F9)),
              Container(height: 4, width: Get.width * (stats.presentPercentage / 100), color: const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 8),
          Text('COMPLIANCE_RATE: ${stats.presentPercentage.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildHUDStat(String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: color)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildActionPanel(Map<String, dynamic> tokens) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(child: _buildHUDActionBtn('GEN_UPLINK_QR', Iconsax.scan, const Color(0xFF0F172A), isActive ? controller.generateQRCode : null)),
        const SizedBox(width: 8),
        Expanded(child: _buildHUDActionBtn('DATA_EXPORT', Iconsax.document_download, const Color(0xFFF1F5F9), controller.exportAttendanceData, isDark: false)),
      ],
    );
  }

  Widget _buildHUDActionBtn(String label, IconData icon, Color color, VoidCallback? onTap, {bool isDark = true}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : const Color(0xFF0F172A), width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.white : const Color(0xFF0F172A), size: 14),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentManifest(Map<String, dynamic> tokens) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0))),
        child: const Center(child: Text('NO_NODES_IDENTIFIED', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), fontSize: 11))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ListTile(
             contentPadding: const EdgeInsets.all(16),
             leading: Container(
               width: 44,
               height: 44,
               decoration: BoxDecoration(color: record.isPresent ? const Color(0xFF10B981).withOpacity(0.1) : Colors.red.withOpacity(0.1), border: Border.all(color: record.isPresent ? const Color(0xFF10B981) : Colors.red)),
               child: Center(child: Icon(record.isPresent ? Iconsax.verify : Iconsax.close_circle, color: record.isPresent ? const Color(0xFF10B981) : Colors.red, size: 20)),
             ),
             title: Text(record.studentName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
             subtitle: Text('ID: ${record.studentId}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF94A3B8))),
             trailing: controller.isSessionActive() 
                ? Switch(
                    value: record.isPresent, 
                    onChanged: (v) => controller.toggleAttendance(record.id, v),
                    activeThumbColor: const Color(0xFF10B981),
                    activeTrackColor: const Color(0xFF10B981).withOpacity(0.2),
                  )
                : null,
          ),
        );
      },
    );
  }
}
