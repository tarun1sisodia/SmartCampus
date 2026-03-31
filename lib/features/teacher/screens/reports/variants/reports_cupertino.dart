import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShape, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, Badge, CircleAxis, CircleAvatar, TextSelectionTheme, TextSelectionThemeData, TextFormField, InputDecoration, InputBorder, OutlineInputBorder, FileImage, Chip;
import 'package:iconsax/iconsax.dart';
import '../controllers/attendance_reports_controller.dart';

class ReportsCupertino extends StatelessWidget {
  const ReportsCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceReportsController>();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          _buildIosHeader('ANALYTICS & INSIGHTS'),
          CupertinoListSection.insetGrouped(
            backgroundColor: const Color(0xFFF2F2F7),
            children: [
              _buildIosTile(
                context,
                title: 'Attendance Summary',
                subtitle: 'Trends and global overview',
                icon: CupertinoIcons.chart_bar_fill,
                color: const Color(0xFF007AFF),
                onTap: () => Get.toNamed('/attendance_reports'),
              ),
              _buildIosTile(
                context,
                title: 'Student Performance',
                subtitle: 'Individual records analysis',
                icon: CupertinoIcons.person_2_fill,
                color: const Color(0xFF34C759),
                onTap: () {},
              ),
            ],
          ),
          _buildIosHeader('DATA EXPORT'),
          CupertinoListSection.insetGrouped(
            backgroundColor: const Color(0xFFF2F2F7),
            children: [
              _buildIosTile(
                context,
                title: 'Export PDF Report',
                subtitle: 'Official digital document',
                icon: CupertinoIcons.doc_fill,
                color: const Color(0xFFFF3B30),
                onTap: () {},
              ),
              _buildIosTile(
                context,
                title: 'Excel Spreadsheet',
                subtitle: 'Detailed raw analytics',
                icon: CupertinoIcons.table_fill,
                color: const Color(0xFF5856D6),
                onTap: () => controller.exportAttendanceReport(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIosHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8, top: 16),
      child: Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.normal, letterSpacing: -0.2)),
    );
  }

  Widget _buildIosTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return CupertinoListTile.notched(
      leading: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, letterSpacing: -0.4)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}
