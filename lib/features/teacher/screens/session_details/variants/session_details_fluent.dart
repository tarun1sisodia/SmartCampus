import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/session_details_controller.dart';
import '../../../common/utils/constants/sized.dart';

class SessionDetailsFluent extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsFluent({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);

    return Container(
      color: fluentBg,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)));
        }

        if (controller.session.value == null) {
          return const Center(child: Text('LOG_FILE_STREAM_ERROR', style: TextStyle(color: Color(0xFF8A8886))));
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildFluentHeader(),
            const SizedBox(height: 24),
            _buildFluentStatsHUD(),
            const SizedBox(height: 24),
            _buildFluentActionButtons(),
            const SizedBox(height: 32),
            const Text('Academic Attendance Record', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF201F1E))),
            const SizedBox(height: 16),
            _buildFluentRoster(),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildFluentHeader() {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black.withValues(alpha: 0.05)), borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Expanded(child: Text(classDetails['subjectName'] ?? 'Unit Module', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF201F1E)))),
               if (isActive)
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF0078D4), borderRadius: BorderRadius.circular(4)),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 9)),
                 ),
             ],
          ),
          const SizedBox(height: 8),
          Text('${classDetails['courseName']} | Semester ${classDetails['semester']}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withValues(alpha: 0.4))),
          const SizedBox(height: 24),
          Row(
            children: [
               _buildFluentMeta(Iconsax.calendar_1, controller.formatDate(session.date)),
               const SizedBox(width: 24),
               _buildFluentMeta(Iconsax.clock, '${session.startTime} - ${session.endTime}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFluentMeta(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0078D4), size: 14),
        const SizedBox(width: 8),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF201F1E))),
      ],
    );
  }

  Widget _buildFluentStatsHUD() {
    final stats = controller.attendanceStats.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black.withValues(alpha: 0.05)), borderRadius: BorderRadius.circular(4)),
      child: Column(
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _buildFluentStatNode('TOTAL', stats.total, const Color(0xFF201F1E)),
               _buildFluentStatNode('PRESENT', stats.present, const Color(0xFF0078D4)),
               _buildFluentStatNode('ABSENT', stats.absent, Colors.black38),
             ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
             value: stats.presentPercentage / 100,
             backgroundColor: const Color(0xFFF3F3F3),
             color: const Color(0xFF0078D4),
             minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildFluentStatNode(String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: color)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Colors.black38)),
      ],
    );
  }

  Widget _buildFluentActionButtons() {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: isActive ? controller.generateQRCode : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFF0078D4), borderRadius: BorderRadius.circular(4)),
              child: const Center(child: Text('Generate QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: controller.exportAttendanceData,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(4)),
              child: const Center(child: Text('Export Ledger', style: TextStyle(color: Color(0xFF201F1E), fontWeight: FontWeight.w800, fontSize: 11))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFluentRoster() {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return Center(child: Text('No records stream found', style: TextStyle(color: Colors.black.withValues(alpha: 0.3))));
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black.withValues(alpha: 0.05)), borderRadius: BorderRadius.circular(4)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: records.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
        itemBuilder: (context, index) {
          final record = records[index];
          return ListTile(
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
             leading: CircleAvatar(
                backgroundColor: record.isPresent ? const Color(0xFF0078D4).withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                child: Icon(record.isPresent ? Iconsax.verify : Iconsax.close_circle, color: record.isPresent ? const Color(0xFF0078D4) : Colors.black38, size: 20),
             ),
             title: Text(record.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF201F1E))),
             subtitle: Text('NodeID: ${record.studentId}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black.withValues(alpha: 0.4))),
             trailing: controller.isSessionActive() 
                ? Switch(
                    value: record.isPresent, 
                    onChanged: (v) => controller.toggleAttendance(record.id, v),
                    activeThumbColor: const Color(0xFF0078D4),
                  )
                : null,
          ),
        )
      },
    );
  }
}
