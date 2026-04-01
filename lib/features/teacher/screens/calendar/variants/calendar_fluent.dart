import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/calendar_controller.dart';
import '../../../../models/attendance_session_model.dart';

class CalendarFluent extends StatelessWidget {
  final CalendarController controller;

  const CalendarFluent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);

    return Container(
      color: fluentBg,
      child: Column(
        children: [
          _buildActiveHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF0078D4)));
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildAcrylicCalendar(),
                  const SizedBox(height: 32),
                  const Text('Active_Schedule_Stream', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF201F1E))),
                  const SizedBox(height: 16),
                  _buildFluentSessionList(),
                  const SizedBox(height: 64),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveHeader() {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF0078D4), size: 16),
            const SizedBox(width: 12),
            Text(
              '$activeCount ACTIVE_SESSIONS_RECORDED'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF201F1E)),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAcrylicCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
           markerDecoration: BoxDecoration(color: Color(0xFF0078D4), shape: BoxShape.rectangle),
           todayDecoration: BoxDecoration(color: Color(0xFFF3F3F3), borderRadius: BorderRadius.all(Radius.circular(4))),
           todayTextStyle: TextStyle(color: Color(0xFF0078D4), fontWeight: FontWeight.w800),
           selectedDecoration: BoxDecoration(color: Color(0xFF0078D4), borderRadius: BorderRadius.all(Radius.circular(4))),
           selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
           defaultTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
           weekendTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFD83B01)),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black),
          formatButtonTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF0078D4)),
          formatButtonDecoration: BoxDecoration(color: Color(0xFFF3F3F3), borderRadius: BorderRadius.all(Radius.circular(4))),
          leftChevronIcon: Icon(Iconsax.arrow_left_2, size: 20, color: Colors.black),
          rightChevronIcon: Icon(Iconsax.arrow_right_3, size: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFluentSessionList() {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Text('NO_SESSIONS_INDEXED', style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontWeight: FontWeight.w700, fontSize: 11)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sessions.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
        itemBuilder: (context, index) => _buildFluentRow(sessions[index]),
      ),
    );
  }

  Widget _buildFluentRow(AttendanceSessionModel session) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return ListTile(
      contentPadding: const EdgeInsets.all(20),
      title: Text(
        (session.subjectName ?? 'SESSION').toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF201F1E)),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const SizedBox(height: 6),
           Text(
             '${session.courseName} | SEM ${session.semester}'.toUpperCase(),
             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.black.withValues(alpha: 0.5)),
           ),
           const SizedBox(height: 12),
           Row(
              children: [
                 const Icon(Iconsax.clock, size: 14, color: Color(0xFF0078D4)),
                 const SizedBox(width: 8),
                 Text(
                   '${session.startTime} - ${session.endTime}'.toUpperCase(),
                   style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF0078D4)),
                 ),
              ],
           ),
        ],
      ),
      trailing: Container(
         padding: const EdgeInsets.all(8),
         decoration: BoxDecoration(border: Border.all(color: Colors.black.withValues(alpha: 0.1))),
         child: Icon(isMySession ? Iconsax.verify : Iconsax.user_octagon, size: 20, color: isMySession ? const Color(0xFF0078D4) : Colors.black.withValues(alpha: 0.4)),
      ),
    );
  }
}
