import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/session_details_controller.dart';
import '../../../common/utils/constants/sized.dart';

class SessionDetailsMinimalist extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsMinimalist({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.softMinimalist);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: TColors.primary));
        }

        if (controller.session.value == null) {
          return const Center(child: Text('Session data not found', style: TextStyle(color: Color(0xFF94A3B8))));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildMinimalistHeader(tokens),
            const SizedBox(height: 24),
            _buildStatsRow(tokens),
            const SizedBox(height: 24),
            _buildActionChips(tokens),
            const SizedBox(height: 32),
            const Text('Student Attendance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            _buildMinimalistRoster(tokens),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildMinimalistHeader(PatternTokens tokens) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(classDetails['subjectName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B))),
              if (isActive)
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                   child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${classDetails['courseName']} | Sem ${classDetails['semester']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Iconsax.calendar_1, size: 14, color: TColors.primary),
              const SizedBox(width: 8),
              Text(controller.formatDate(session.date), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569))),
              const Spacer(),
              Icon(Iconsax.clock, size: 14, color: TColors.primary),
              const SizedBox(width: 8),
              Text('${session.startTime} - ${session.endTime}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(PatternTokens tokens) {
    final stats = controller.attendanceStats.value;
    return Row(
       children: [
         _buildStatBox('Total', stats.total, const Color(0xFF1E293B)),
         const SizedBox(width: 12),
         _buildStatBox('Present', stats.present, const Color(0xFF10B981)),
         const SizedBox(width: 12),
         _buildStatBox('Absent', stats.absent, const Color(0xFFEF4444)),
       ],
    );
  }

  Widget _buildStatBox(String label, int val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Column(
          children: [
            Text('$val', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChips(PatternTokens tokens) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: isActive ? controller.generateQRCode : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: TColors.primary, borderRadius: BorderRadius.circular(12)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Iconsax.scan, color: Colors.white, size: 14), SizedBox(width: 8), Text('QR Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11))]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.exportAttendanceData,
            icon: const Icon(Iconsax.document_download, size: 14),
            label: const Text('Export', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalistRoster(PatternTokens tokens) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text('No student records found', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 12))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: ListTile(
             contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
             leading: CircleAvatar(
               backgroundColor: record.isPresent ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
               child: Icon(record.isPresent ? Iconsax.verify : Iconsax.close_circle, color: record.isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 20),
             ),
             title: Text(record.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
             subtitle: Text('ID: ${record.studentId}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF94A3B8))),
             trailing: controller.isSessionActive() 
                ? Switch(
                    value: record.isPresent, 
                    onChanged: (v) => controller.toggleAttendance(record.id, v),
                    activeThumbColor: const Color(0xFF10B981),
                  )
                : null,
          ),
        );
      },
    );
  }
}
