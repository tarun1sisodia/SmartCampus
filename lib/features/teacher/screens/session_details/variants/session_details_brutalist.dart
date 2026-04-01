import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/session_details_controller.dart';
import '../../../common/utils/constants/sized.dart';

class SessionDetailsBrutalist extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsBrutalist({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (controller.session.value == null) {
          return const Center(child: Text('LOG_FILE_INVALID', style: TextStyle(fontWeight: FontWeight.w900)));
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildBrutalHeader(yellow),
            const SizedBox(height: 32),
            _buildBrutalStatsHUD(blue),
            const SizedBox(height: 32),
            _buildBrutalActionBar(orange),
            const SizedBox(height: 48),
            const Text('ATTENDEE_MANIFEST_01', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0, color: Colors.black)),
            const SizedBox(height: 16),
            _buildBrutalStudentRoster(blue, orange),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildBrutalHeader(Color yellow) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: yellow, border: Border.all(color: Colors.black, width: 4), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text((classDetails['subjectName'] ?? 'NULL_UNIT').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.black, letterSpacing: -1))),
              if (isActive)
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black)),
                    child: const Text('LIVE_00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                 ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${classDetails['courseName']} | SEM_${classDetails['semester']}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black)),
          const SizedBox(height: 24),
          Row(
             children: [
               _buildBrutalMeta(Iconsax.calendar_1, controller.formatDate(session.date).toUpperCase()),
               const SizedBox(width: 24),
               _buildBrutalMeta(Iconsax.clock, '${session.startTime} - ${session.endTime}'),
             ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalMeta(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 16),
        const SizedBox(width: 8),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black)),
      ],
    );
  }

  Widget _buildBrutalStatsHUD(Color blue) {
    final stats = controller.attendanceStats.value;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 4), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBrutalStatNode('TOTAL', stats.total, Colors.black),
              _buildBrutalStatNode('PRESENT', stats.present, blue),
              _buildBrutalStatNode('ABSENT', stats.absent, Colors.black),
            ],
          ),
          const SizedBox(height: 24),
          Container(
             height: 12,
             width: double.infinity,
             decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2)),
             child: FractionallySizedBox(
               alignment: Alignment.centerLeft,
               widthFactor: stats.presentPercentage / 100,
               child: Container(decoration: BoxDecoration(color: blue, border: Border(right: BorderSide(color: Colors.black, width: 2)))),
             ),
          ),
          const SizedBox(height: 8),
          Text('SYNC_RATE: ${stats.presentPercentage.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildBrutalStatNode(String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: color)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.black54)),
      ],
    );
  }

  Widget _buildBrutalActionBar(Color orange) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: isActive ? controller.generateQRCode : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
              child: const Center(child: Text('GENERATE_QR_01', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: controller.exportAttendanceData,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: orange, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
              child: const Center(child: Text('EXPORT_MANIFEST', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrutalStudentRoster(Color blue, Color orange) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 3)),
        child: const Center(child: Text('NO_STREAM_DATA', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black38))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
          ),
          child: ListTile(
             contentPadding: const EdgeInsets.all(16),
             leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: record.isPresent ? blue : Colors.white, border: Border.all(color: Colors.black, width: 2)),
                child: Center(child: Icon(record.isPresent ? Iconsax.verify : Iconsax.close_circle, color: Colors.black, size: 24)),
             ),
             title: Text(record.studentName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black)),
             subtitle: Text('ID_NODE: ${record.studentId}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.black54)),
             trailing: controller.isSessionActive() 
                ? Switch(
                    value: record.isPresent, 
                    onChanged: (v) => controller.toggleAttendance(record.id, v),
                    activeThumbColor: blue,
                    activeTrackColor: blue.withValues(alpha: 0.3),
                  )
                : null,
          ),
        );
      },
    );
  }
}
