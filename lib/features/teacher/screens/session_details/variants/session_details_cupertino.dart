import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShape, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, Badge, CircleAvatar, Switch;
import 'package:iconsax/iconsax.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/session_details_controller.dart';
import '../../../common/utils/constants/sized.dart';

class SessionDetailsCupertino extends StatelessWidget {
  final SessionDetailsController controller;
  final Map<String, dynamic> classDetails;

  const SessionDetailsCupertino({super.key, required this.controller, required this.classDetails});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.cupertinoPro);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (controller.session.value == null) {
          return const Center(child: Text('LOG_FILE_NOT_FOUND', style: TextStyle(color: Color(0xFF8E8E93))));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildIosHeader(tokens),
            const SizedBox(height: 24),
            _buildIosStatsContainer(tokens),
            const SizedBox(height: 24),
            _buildIosActions(tokens),
            const SizedBox(height: 32),
            const Padding(
               padding: EdgeInsets.symmetric(horizontal: 16),
               child: Text('Attendee Register', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF8E8E93), letterSpacing: -0.2)),
            ),
            const SizedBox(height: 12),
            _buildIosRoster(tokens),
            const SizedBox(height: 64),
          ],
        );
      }),
    );
  }

  Widget _buildIosHeader(Map<String, dynamic> tokens) {
    final session = controller.session.value!;
    final isActive = controller.isSessionActive();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Expanded(child: Text(classDetails['subjectName'] ?? 'Unit', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.black, letterSpacing: -1))),
               if (isActive)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(color: const Color(0xFF34C759), borderRadius: BorderRadius.circular(20)),
                   child: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 9)),
                 ),
             ],
          ),
          const SizedBox(height: 8),
          Text('${classDetails['courseName']} | Sem ${classDetails['semester']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF8E8E93))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIosIconInfo(CupertinoIcons.calendar, controller.formatDate(session.date)),
              _buildIosIconInfo(CupertinoIcons.clock, '${session.startTime} - ${session.endTime}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIosIconInfo(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF007AFF), size: 14),
        const SizedBox(width: 8),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black)),
      ],
    );
  }

  Widget _buildIosStatsContainer(Map<String, dynamic> tokens) {
    final stats = controller.attendanceStats.value;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIosStatNode('TOTAL', stats.total, Colors.black),
              _buildIosStatNode('PRESENT', stats.present, const Color(0xFF34C759)),
              _buildIosStatNode('ABSENT', stats.absent, const Color(0xFFFF3B30)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
             height: 4,
             width: double.infinity,
             decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(2)),
             child: FractionallySizedBox(
               alignment: Alignment.centerLeft,
               widthFactor: stats.presentPercentage / 100,
               child: Container(decoration: BoxDecoration(color: const Color(0xFF34C759), borderRadius: BorderRadius.circular(2))),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildIosStatNode(String label, int val, Color color) {
    return Column(
      children: [
        Text('$val', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: color, letterSpacing: -1)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF8E8E93))),
      ],
    );
  }

  Widget _buildIosActions(Map<String, dynamic> tokens) {
    final isActive = controller.isSessionActive();
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFF007AFF),
            onPressed: isActive ? controller.generateQRCode : null,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(CupertinoIcons.qrcode, size: 18), SizedBox(width: 8), Text('QR Link', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            onPressed: controller.exportAttendanceData,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(CupertinoIcons.share, color: Color(0xFF007AFF), size: 18), SizedBox(width: 8), Text('Export', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w700, fontSize: 12))]),
          ),
        ),
      ],
    );
  }

  Widget _buildIosRoster(Map<String, dynamic> tokens) {
    final records = controller.attendanceRecords;
    if (records.isEmpty) {
      return const Center(child: Text('LOG_VOID', style: TextStyle(color: Color(0xFF8E8E93))));
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: records.length,
        separatorBuilder: (context, index) => const Divider(indent: 64, height: 1),
        itemBuilder: (context, index) {
          final record = records[index];
          return ListTile(
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
             leading: CircleAvatar(
                backgroundColor: record.isPresent ? const Color(0xFF34C759).withValues(alpha: 0.1) : const Color(0xFFFF3B30).withValues(alpha: 0.1),
                child: Icon(record.isPresent ? CupertinoIcons.check_mark : CupertinoIcons.xmark, color: record.isPresent ? const Color(0xFF34C759) : const Color(0xFFFF3B30), size: 18),
             ),
             title: Text(record.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black)),
             subtitle: Text('ID: ${record.studentId}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF8E8E93))),
             trailing: controller.isSessionActive() 
                ? CupertinoSwitch(value: record.isPresent, onChanged: (v) => controller.toggleAttendance(record.id, v), activeTrackColor: const Color(0xFF34C759))
                : null,
          ),
        )
      },
    );
  }
}
