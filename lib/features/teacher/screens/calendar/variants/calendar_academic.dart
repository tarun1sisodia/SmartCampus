import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/calendar_controller.dart';
import '../../../../models/attendance_session_model.dart';

class CalendarAcademic extends StatelessWidget {
  final CalendarController controller;

  const CalendarAcademic({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown
    final tokens = PatternTokens.get(UIStyle.academicClassic);

    return Container(
      color: paperColor,
      child: Column(
        children: [
          _buildAcademicHeader(accentColor, inkColor),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: accentColor));
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildClassicCalendar(accentColor, inkColor),
                  const SizedBox(height: 32),
                  Text(
                    'CURRICULAR_ENGAGEMENTS',
                    style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: inkColor),
                  ),
                  const SizedBox(height: 16),
                  _buildAcademicSessionList(accentColor, inkColor),
                  const SizedBox(height: 64),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicHeader(Color accent, Color ink) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EAD6),
          border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.3), width: 1)),
        ),
        child: Row(
          children: [
             Icon(Iconsax.radar, color: accent, size: 16),
             const SizedBox(width: 12),
             Text(
               '$activeCount ACTIVE_SESSIONS_RECORDED'.toUpperCase(),
               style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1),
             ),
          ],
        ),
      );
    });
  }

  Widget _buildClassicCalendar(Color accent, Color ink) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: accent.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.05), blurRadius: 10)],
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
           markerDecoration: BoxDecoration(color: accent, shape: BoxShape.circle),
           todayDecoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
           todayTextStyle: TextStyle(color: accent, fontWeight: FontWeight.w900, fontFamily: 'Serif'),
           selectedDecoration: BoxDecoration(color: accent, shape: BoxShape.circle),
           selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Serif'),
           defaultTextStyle: TextStyle(fontWeight: FontWeight.w700, color: ink, fontFamily: 'Serif'),
           weekendTextStyle: TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontFamily: 'Serif'),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'Serif', color: ink),
          formatButtonTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, fontFamily: 'Serif', color: accent),
          formatButtonDecoration: BoxDecoration(border: Border.all(color: accent.withValues(alpha: 0.3))),
          leftChevronIcon: Icon(Iconsax.arrow_left_2, size: 20, color: ink),
          rightChevronIcon: Icon(Iconsax.arrow_right_3, size: 20, color: ink),
        ),
      ),
    );
  }

  Widget _buildAcademicSessionList(Color accent, Color ink) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Text('NO_LECTURES_SCHEDULED', style: TextStyle(color: ink.withValues(alpha: 0.5), fontWeight: FontWeight.w700, fontSize: 11, fontFamily: 'Serif', letterSpacing: 1)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _buildAcademicRow(sessions[index], accent, ink),
    );
  }

  Widget _buildAcademicRow(AttendanceSessionModel session, Color accent, Color ink) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: ink.withValues(alpha: 0.05), width: 1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        title: Text(
          (session.subjectName ?? 'SESSION').toUpperCase(),
          style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w900, fontSize: 14, color: ink),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const SizedBox(height: 8),
             Text(
               '${session.courseName} | SEM ${session.semester}'.toUpperCase(),
               style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w700, fontSize: 10, color: ink.withValues(alpha: 0.6)),
             ),
             const SizedBox(height: 12),
             Row(
               children: [
                  const Icon(Iconsax.clock, size: 14, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    '${session.startTime} - ${session.endTime}'.toUpperCase(),
                    style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w800, fontSize: 11, color: ink),
                  ),
               ],
             ),
          ],
        ),
        trailing: Container(
           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
           decoration: BoxDecoration(border: Border.all(color: accent.withValues(alpha: 0.3))),
           child: Icon(isMySession ? Iconsax.teacher : Iconsax.user_octagon, size: 20, color: accent),
        ),
      ),
    );
  }
}
