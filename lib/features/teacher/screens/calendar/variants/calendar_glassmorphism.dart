import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/calendar_controller.dart';
import '../../../../models/attendance_session_model.dart';

class CalendarGlassmorphism extends StatelessWidget {
  final CalendarController controller;

  const CalendarGlassmorphism({super.key, required this.controller});

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
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.white.withOpacity(0.02)),
            ),
          ),
          
          Column(
            children: [
              _buildLiveMonitor(tokens),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      _buildGlassCalendar(tokens),
                      const SizedBox(height: 32),
                      const Text(
                        'TIMELINE_OVERVIEW',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _buildSessionList(tokens),
                      const SizedBox(height: 48),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMonitor(Map<String, dynamic> tokens) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(
              'LIVE_NODES_ACTIVE: $activeCount'.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGlassCalendar(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
        calendarStyle: CalendarStyle(
          markerDecoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          selectedDecoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900),
          defaultTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          weekendTextStyle: const TextStyle(color: Color(0xFFFF9494), fontWeight: FontWeight.w700),
          outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
          formatButtonTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
          formatButtonDecoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          leftChevronIcon: const Icon(Iconsax.arrow_left_2, size: 20, color: Colors.white),
          rightChevronIcon: const Icon(Iconsax.arrow_right_3, size: 20, color: Colors.white),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
          weekendStyle: TextStyle(color: Color(0xFFFF9494), fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildSessionList(Map<String, dynamic> tokens) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text('NO DATA STREAM INGESTED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _buildGlassSessionRow(sessions[index], tokens),
    );
  }

  Widget _buildGlassSessionRow(AttendanceSessionModel session, Map<String, dynamic> tokens) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? const Color(0xFF10B981) : Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          (session.subjectName ?? 'SESSION').toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${session.courseName} | SEM ${session.semester}'.toUpperCase(),
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w700, fontSize: 10),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Iconsax.clock, size: 14, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '${session.startTime} - ${session.endTime}'.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
           width: 44,
           height: 44,
           decoration: BoxDecoration(shape: BoxShape.circle, color: isMySession ? const Color(0xFF6366F1).withOpacity(0.2) : Colors.white.withOpacity(0.05)),
           child: Center(child: Icon(isMySession ? Iconsax.verify : Iconsax.user_octagon, size: 20, color: isMySession ? const Color(0xFF818CF8) : Colors.white.withOpacity(0.4))),
        ),
      ),
    );
  }
}
