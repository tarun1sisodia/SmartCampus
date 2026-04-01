import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../controllers/session_details_controller.dart';

class SessionDetailsGlassmorphism extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsGlassmorphism({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.glassmorphism);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dynamic Mesh Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withValues(alpha: 0.05)),
            ),
          ),
          
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (controller.session.value == null) {
               return const Center(child: Text('VOID_DATAFRAME_ERROR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)));
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildGlassHeader(tokens),
                const SizedBox(height: 24),
                _buildGlassStatsHUD(tokens),
                const SizedBox(height: 24),
                _buildGlassActionRow(tokens),
                const SizedBox(height: 32),
                const Text('TERMINAL_ROSTER_STREAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                _buildGlassStudentManifest(tokens),
                const SizedBox(height: 64),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGlassHeader(PatternTokens tokens) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text((classDetails['subjectName'] ?? 'UNKNOWN_UNIT').toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
              if (isActive)
                 Container(
                   padding: const EdgeInsets.all(6),
                   decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0xFF10B981), blurRadius: 10)]),
                 ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${classDetails['courseName']} | SESSION_NODE ${classDetails['semester']}'.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w800, fontSize: 10)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildGlassIconInfo(Iconsax.calendar_1, controller.formatDate(session.date).toUpperCase()),
               _buildGlassIconInfo(Iconsax.clock, '${session.startTime} - ${session.endTime}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconInfo(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 8),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
      ],
    );
  }

  Widget _buildGlassStatsHUD(PatternTokens tokens) {
    final stats = controller.attendanceStats.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGlassStatItem('TOTAL', stats.total, Colors.white),
              _buildGlassStatItem('PRESENT', stats.present, const Color(0xFF10B981)),
              _buildGlassStatItem('ABSENT', stats.absent, const Color(0xFFEC4899)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
             height: 6,
             width: double.infinity,
             decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
             child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: stats.presentPercentage / 100,
                child: Container(decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(4))),
             ),
          ),
          const SizedBox(height: 8),
          Text('SYNC_HEALTH: ${stats.presentPercentage.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildGlassStatItem(String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 24)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w800, fontSize: 8, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildGlassActionRow(PatternTokens tokens) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: isActive ? controller.generateQRCode : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
              child: const Center(child: Text('GENERATE_QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: controller.exportAttendanceData,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: const Center(child: Text('EXPORT_SYNC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStudentManifest(PatternTokens tokens) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24)),
        child: Center(child: Text('VOID_RECORDS_INDEXED', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w900, fontSize: 11))),
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
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: ListTile(
             contentPadding: const EdgeInsets.all(16),
             leading: CircleAvatar(
               backgroundColor: record.isPresent ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
               child: Icon(record.isPresent ? Iconsax.verify : Iconsax.close_circle, color: record.isPresent ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.3), size: 20),
             ),
             title: Text(record.studentName.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
             subtitle: Text('NODE_ID: ${record.studentId}'.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w800, fontSize: 9)),
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
