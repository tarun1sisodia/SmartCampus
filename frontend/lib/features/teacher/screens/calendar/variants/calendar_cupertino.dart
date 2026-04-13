import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Color, FontWeight, TextStyle, BorderRadius, Radius, BoxShape, BoxShadow, BoxDecoration, Widget, EdgeInsets, Column, Row, SizedBox, BuildContext, StatelessWidget, Center, ListView, Icon, CrossAxisAlignment, ListTile;
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../controllers/calendar_controller.dart';
import '../../../../../models/attendance_session_model.dart';

class CalendarCupertino extends StatelessWidget {
  final CalendarController controller;

  const CalendarCupertino({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.cupertinoPro);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('CALENDAR', style: TextStyle(letterSpacing: -0.5, fontWeight: FontWeight.w800)),
            backgroundColor: const Color(0xFFF2F2F7).withValues(alpha: 0.8),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(Iconsax.filter, size: 22),
              onPressed: () => {}, // Filter logic
            ),
          ),
          SliverToBoxAdapter(
            child: _buildLiveBadge(),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator()));
            }

            return SliverList(
              delegate: SliverChildListDelegate([
                _buildIosCalendar(tokens),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('SCHEDULE_STREAM', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF6E6E73), letterSpacing: 0.5)),
                ),
                const SizedBox(height: 8),
                _buildSessionList(tokens),
                const SizedBox(height: 64),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF34C759).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(
              '$activeCount LIVE_SESSIONS_BROADCASTING'.toUpperCase(),
              style: const TextStyle(color: Color(0xFF248A3D), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildIosCalendar(PatternTokens tokens) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        calendarFormat: controller.calendarFormat.value,
        selectedDayPredicate: (day) => isSameDay(controller.selectedDay.value, day),
        onDaySelected: (sel, foc) {
          controller.selectedDay.value = sel;
          controller.focusedDay.value = foc;
        },
        onFormatChanged: (f) => controller.calendarFormat.value = f,
        onPageChanged: (f) => controller.focusedDay.value = f,
        eventLoader: (day) => controller.getSessionsForDay(day),
        calendarStyle: const CalendarStyle(
           markerDecoration: BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
           todayDecoration: BoxDecoration(color: Color(0xFFE5E5EA), shape: BoxShape.circle),
           todayTextStyle: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w800),
           selectedDecoration: BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
           selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
           defaultTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
           weekendTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFF3B30)),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black),
          formatButtonTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF007AFF)),
          formatButtonDecoration: BoxDecoration(color: Color(0xFFF2F2F7), borderRadius: BorderRadius.all(Radius.circular(10))),
          leftChevronIcon: Icon(CupertinoIcons.chevron_left, size: 18, color: Color(0xFF007AFF)),
          rightChevronIcon: Icon(CupertinoIcons.chevron_right, size: 18, color: Color(0xFF007AFF)),
        ),
      ),
    );
  }

  Widget _buildSessionList(PatternTokens tokens) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Text('EMPTY_GRID_INDEX', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.5)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sessions.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 64, color: Color(0xFFF2F2F7)),
        itemBuilder: (context, index) => _buildIosSessionRow(sessions[index], tokens),
      ),
    );
  }

  Widget _buildIosSessionRow(AttendanceSessionModel session, PatternTokens tokens) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF34C759).withValues(alpha: 0.1) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Icon(isMySession ? Iconsax.verify : Iconsax.user_octagon, size: 22, color: isMySession ? const Color(0xFF007AFF) : const Color(0xFF8E8E93))),
      ),
      title: Text(
        (session.subjectName ?? 'SESSION').toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: -0.3),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(
            '${session.courseName} | SEM ${session.semester}'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 8),
          Row(
             children: [
               const Icon(CupertinoIcons.clock, size: 14, color: Color(0xFF007AFF)),
               const SizedBox(width: 6),
               Text(
                 '${session.startTime} - ${session.endTime}'.toUpperCase(),
                 style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF007AFF)),
               ),
             ],
          ),
        ],
      ),
      trailing: const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
    );
  }
}
