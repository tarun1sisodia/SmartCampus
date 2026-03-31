import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/models/class_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/features/teacher/screens/mark_attendance_screen.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance_screen.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';

class AttendanceCupertino extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceCupertino({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.cupertinoPro, isDark: isDark);

    return CupertinoPageScaffold(
      backgroundColor: isDark ? CupertinoColors.systemBackground.darkColor : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(classModel.subjectName ?? 'Attendance', style: TextStyle(fontFamily: tokens.fontFamily, fontWeight: FontWeight.bold)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.plus_circle_fill, size: 28),
          onPressed: () => _showCreateSessionDialog(context),
        ),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () => controller.loadAttendanceSessions(classModel.id),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((classModel.courseName ?? 'COURSE').toUpperCase(), style: TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    Text(classModel.subjectName ?? 'Subject', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
                    const SizedBox(height: 24),
                    _buildCupertinoStats(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: CupertinoListSection.insetGrouped(
                header: const Text("SESSIONS HISTORY", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                footer: const Text("All times are in local time zone.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                children: controller.attendanceSessions.map((session) {
                  return _buildCupertinoSessionItem(context, session, tokens);
                }).toList(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      }),
    );
  }

  Widget _buildCupertinoStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(controller.students.length.toString(), "STUDENTS"),
        _buildStatItem(controller.attendanceSessions.length.toString(), "SESSIONS"),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w200)),
        Text(label, style: const TextStyle(fontSize: 10, color: CupertinoColors.secondaryLabel, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildCupertinoSessionItem(BuildContext context, dynamic session, PatternTokens tokens) {
    final date = DateFormat('EEE, MMM d, yyyy').format(session.date);
    return CupertinoListTile(
      leading: const Icon(CupertinoIcons.calendar, color: CupertinoColors.activeBlue),
      title: Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("${session.startTime ?? '00:00'} — ${session.endTime ?? 'ONGOING'}", style: const TextStyle(fontSize: 12)),
      trailing: const CupertinoListTileChevron(),
      onTap: () {
        controller.currentSessionId.value = session.id;
        Get.to(() => MarkAttendanceScreen());
      },
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    controller.sessionDate.value = DateTime.now();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Initialize Session"),
        message: const Text("Select a date to start a new attendance session."),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              controller.createAttendanceSession();
            },
            child: const Text("Confirm Today"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text("Cancel"),
        ),
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CupertinoListTile({super.key, this.leading, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemGroupedBackground, context),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 16)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[const SizedBox(height: 2), subtitle!],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class CupertinoListTileChevron extends StatelessWidget {
  const CupertinoListTileChevron({super.key});
  @override
  Widget build(BuildContext context) {
    return const Icon(CupertinoIcons.chevron_right, size: 14, color: CupertinoColors.systemGrey);
  }
}
