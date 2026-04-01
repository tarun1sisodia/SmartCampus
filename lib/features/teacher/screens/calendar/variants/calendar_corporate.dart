import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_campus/common/ui_patterns/pattern_tokens.dart';
import 'package:smart_campus/common/ui_patterns/ui_style.dart';
import 'package:smart_campus/features/teacher/controllers/calendar_controller.dart';
import 'package:smart_campus/models/attendance_session_model.dart';

class CalendarCorporate extends StatelessWidget {
  final CalendarController controller;

  const CalendarCorporate({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.industrialCorporate);

    return Column(
      children: [
        _buildActiveHeader(tokens),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
            }

            return Column(
              children: [
                _buildCorporateCalendar(tokens),
                const Divider(height: 2, color: Color(0xFF0F172A), thickness: 1),
                Expanded(child: _buildSessionListing(tokens)),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActiveHeader(PatternTokens tokens) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          border: Border(bottom: BorderSide(color: Colors.white, width: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.sensors, color: Colors.green, size: 16),
            const SizedBox(width: 12),
            Text(
              'LIVE_CHANNELS_OPEN: $activeCount'.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCorporateCalendar(PatternTokens tokens) {
    return Container(
      color: Colors.white,
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
          markerDecoration: BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.rectangle),
          todayDecoration: BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.rectangle),
          todayTextStyle: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900),
          selectedDecoration: BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.rectangle),
          selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          defaultTextStyle: TextStyle(fontWeight: FontWeight.w700),
          weekendTextStyle: TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
          formatButtonTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
          formatButtonDecoration: BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Color(0xFF0F172A), width: 1.5))),
          leftChevronIcon: Icon(Iconsax.arrow_left_2, size: 20, color: Color(0xFF0F172A)),
          rightChevronIcon: Icon(Iconsax.arrow_right_3, size: 20, color: Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildSessionListing(PatternTokens tokens) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return const Center(
        child: Text('NO SCHEDULED RECORDS', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), fontSize: 12)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _buildCorporateSessionCard(sessions[index], tokens),
    );
  }

  Widget _buildCorporateSessionCard(AttendanceSessionModel session, PatternTokens tokens) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isActive ? Colors.green : (isMySession ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)), 
          width: isActive ? 3 : 1.5
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        title: Text(
          (session.subjectName ?? 'SESSION').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5, color: Color(0xFF0F172A)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${session.courseName} | SEM ${session.semester} | SEC ${session.section}'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Iconsax.clock, size: 14, color: Color(0xFF0F172A)),
                const SizedBox(width: 8),
                Text(
                  '${session.startTime} - ${session.endTime}'.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ],
        ),
        trailing: isMySession 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border.all(color: Colors.white)),
                child: const Text('MY_UNIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9)),
              )
            : const Icon(Iconsax.arrow_right_3, size: 16),
      ),
    );
  }
}
