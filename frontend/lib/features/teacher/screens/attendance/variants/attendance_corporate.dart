import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/common/utils/constants/colors.dart';
import 'package:smart_campus/models/class_model.dart';
import 'package:smart_campus/features/teacher/controllers/attendance_controller.dart';
import 'package:smart_campus/features/teacher/screens/mark_attendance/mark_attendance_screen.dart';
import 'package:smart_campus/features/teacher/screens/carousel_attendance/carousel_attendance_screen.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';

class AttendanceCorporate extends StatelessWidget {
  final ClassModel classModel;
  final AttendanceController controller;

  const AttendanceCorporate({super.key, required this.classModel, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = PatternTokens.get(UIStyle.industrialCorporate, isDark: isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          (classModel.subjectName ?? 'ATTENDANCE').toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontFamily: tokens.fontFamily),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.loadAttendanceSessions(classModel.id),
            icon: const Icon(Iconsax.refresh, color: TColors.executiveNavy),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: TColors.executiveNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.calendar_add, size: 20),
        label: const Text('NEW SESSION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.borderRadius), side: const BorderSide(color: Colors.white, width: 2)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAttendanceSessions(classModel.id),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildCorporateHeader(tokens)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Text("SESSIONS HISTORY", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 12, color: TColors.slate600)),
                      const Spacer(),
                      _buildBadge("${controller.attendanceSessions.length} TOTAL", TColors.executiveNavy),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              _buildSessionsTable(context, tokens),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)),
    );
  }

  Widget _buildCorporateHeader(PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColors.executiveNavy,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(classModel.courseName?.toUpperCase() ?? 'COURSE', style: const TextStyle(color: TColors.deepOceanCyan, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2.0)),
          const SizedBox(height: 8),
          Text(classModel.subjectName?.toUpperCase() ?? 'SUBJECT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1.0)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildHeaderStat(Iconsax.people, "${controller.students.length} STUDENTS"),
              const SizedBox(width: 24),
              _buildHeaderStat(Iconsax.status, "ACTIVE RECORD"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildSessionsTable(BuildContext context, PatternTokens tokens) {
    if (controller.attendanceSessions.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text("NO SESSIONS RECORDED", style: TextStyle(fontWeight: FontWeight.w900, color: TColors.slate400))));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final session = controller.attendanceSessions[index];
            return _buildCorporateSessionCard(context, session, tokens);
          },
          childCount: controller.attendanceSessions.length,
        ),
      ),
    );
  }

  Widget _buildCorporateSessionCard(BuildContext context, dynamic session, PatternTokens tokens) {
    final date = DateFormat('dd MMM yyyy').format(session.date).toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: TColors.executiveNavy, width: 2),
      ),
      child: InkWell(
        onTap: () {
          controller.currentSessionId.value = session.id;
          Get.to(() => MarkAttendanceScreen());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                  Text("${session.startTime ?? '00:00'} - ${session.endTime ?? 'ONGOING'}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Iconsax.play_circle, color: TColors.deepOceanCyan, size: 32),
                onPressed: () {
                  controller.currentSessionId.value = session.id;
                  Get.to(() => CarouselAttendanceScreen());
                },
              ),
              const Icon(Iconsax.arrow_right_3, color: TColors.executiveNavy),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context) {
    // Re-use logic from controller
    controller.sessionDate.value = DateTime.now();
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(side: BorderSide(color: TColors.executiveNavy, width: 2)),
        title: const Text("NEW SESSION", style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("SELECT DATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              subtitle: Obx(() => Text(DateFormat('dd-MM-yyyy').format(controller.sessionDate.value))),
              trailing: const Icon(Iconsax.calendar),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 30)));
                if (date != null) controller.sessionDate.value = date;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold))),
          ElevatedButton(onPressed: () => controller.createAttendanceSession(), child: const Text("CREATE")),
        ],
      ),
    );
  }
}
