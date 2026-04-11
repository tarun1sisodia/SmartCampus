import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../controllers/session_details_controller.dart';

class SessionDetailsNeumorphism extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsNeumorphism({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE2E8F0);
    final tokens = PatternTokens.get(UIStyle.neumorphism);

    return Container(
      color: bgColor,
      child: Obx(() {
        if (controller.isLoading.value) {
           return const Center(child: CircularProgressIndicator(color: Color(0xFF94A3B8)));
        }

        if (controller.session.value == null) {
           return const Center(child: Text('LOG_NODE_NULL', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))));
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTactileHeader(bgColor),
            const SizedBox(height: 32),
            _buildTactileStats(bgColor),
            const SizedBox(height: 32),
            _buildTactileActionRow(bgColor),
            const SizedBox(height: 48),
            const Text('ROSTER_MANIFEST_DEPTH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: Color(0xFF1E293B))),
            const SizedBox(height: 24),
            _buildTactileRoster(bgColor),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildTactileHeader(Color bgColor) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
          BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.4), offset: const Offset(8, 8), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text((classDetails['subjectName'] ?? 'NULL_UNIT').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1E293B))),
              if (isActive)
                 Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0xFF10B981), blurRadius: 10)]),
                 ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${classDetails['courseName']} | SEM_${classDetails['semester']}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildTactilePill(Iconsax.calendar_1, controller.formatDate(session.date).toUpperCase(), bgColor),
              const SizedBox(width: 12),
              _buildTactilePill(Iconsax.clock, '${session.startTime} - ${session.endTime}', bgColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTactilePill(IconData icon, String val, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4, inset: true),
          BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.5), offset: const Offset(2, 2), blurRadius: 4, inset: true),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildTactileStats(Color bgColor) {
    final stats = controller.attendanceStats.value;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
          BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.4), offset: const Offset(8, 8), blurRadius: 16),
        ],
      ),
      child: Column(
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _buildStatNode('MANIFEST', stats.total, const Color(0xFF1E293B)),
               _buildStatNode('PRESENT', stats.present, const Color(0xFF10B981)),
               _buildStatNode('ABSENT', stats.absent, const Color(0xFFEF4444)),
             ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
                BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.5), offset: const Offset(2, 2), blurRadius: 4, inset: true),
              ],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stats.presentPercentage / 100,
              child: Container(decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatNode(String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: color)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildTactileActionRow(Color bgColor) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(child: _buildTactileActionBtn('QR_SYNC', Iconsax.scan, bgColor, isActive ? controller.generateQRCode : null)),
        const SizedBox(width: 16),
        Expanded(child: _buildTactileActionBtn('LEDGER_EXPORT', Iconsax.document_download, bgColor, controller.exportAttendanceData)),
      ],
    );
  }

  Widget _buildTactileActionBtn(String label, IconData icon, Color bgColor, VoidCallback? onTap) {
    return InkWell(
       onTap: onTap,
       child: Container(
         padding: const EdgeInsets.symmetric(vertical: 16),
         decoration: BoxDecoration(
           color: bgColor,
           borderRadius: BorderRadius.circular(16),
           boxShadow: [
             const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
             BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.5), offset: const Offset(4, 4), blurRadius: 8),
           ],
         ),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(icon, color: const Color(0xFF1E293B), size: 16),
             const SizedBox(width: 8),
             Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1E293B))),
           ],
         ),
       ),
    );
  }

  Widget _buildTactileRoster(Color bgColor) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return const Center(child: Text('LOG_STREAM_EMPTY', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), fontSize: 11)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
              BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.4), offset: const Offset(6, 6), blurRadius: 12),
            ],
          ),
          child: ListTile(
             contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
             leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                   color: bgColor,
                   shape: BoxShape.circle,
                   boxShadow: [
                      BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
                      BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.5), offset: const Offset(2, 2), blurRadius: 4, inset: true),
                   ],
                ),
                child: Center(child: Icon(record.isPresent ? Iconsax.verify : Iconsax.close_circle, color: record.isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 20)),
             ),
             title: Text(record.studentName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B))),
             subtitle: Text('ID: ${record.studentId}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B))),
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
