import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/calendar_controller.dart';
import '../../../../models/attendance_session_model.dart';
import '../../../../common/utils/constants/sized.dart';

class CalendarMinimalist extends StatelessWidget {
  final CalendarController controller;

  const CalendarMinimalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tokens = PatternTokens.get(UIStyle.softMinimalist);

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _buildLiveStatus(tokens),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  _buildSoftCalendar(tokens),
                  const SizedBox(height: 32),
                  const Text('Today\'s Engagements', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  _buildSessionList(tokens),
                  const SizedBox(height: 48),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatus(Map<String, dynamic> tokens) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.radar, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 12),
            Text(
              '$activeCount Live Sessions Detected',
              style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSoftCalendar(Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24)],
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
          markerDecoration: BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
          todayTextStyle: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w800),
          selectedDecoration: BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
          selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          defaultTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          weekendTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
          formatButtonTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF3B82F6)),
          formatButtonDecoration: BoxDecoration(color: Color(0xFFEFF6FF), borderRadius: BorderRadius.all(Radius.circular(12))),
          leftChevronIcon: Icon(Iconsax.arrow_left_1, size: 20, color: Color(0xFF64748B)),
          rightChevronIcon: Icon(Iconsax.arrow_right_3, size: 20, color: Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildSessionList(Map<String, dynamic> tokens) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Text('No schedule available for this date', style: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _buildMinimalistSessionCard(sessions[index], tokens),
    );
  }

  Widget _buildMinimalistSessionCard(AttendanceSessionModel session, Map<String, dynamic> tokens) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? Border.all(color: const Color(0xFF10B981), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          session.subjectName ?? 'Session',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('${session.courseName} | SEM ${session.semester}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Row(
              children: [
                 const Icon(Iconsax.clock, size: 12, color: Color(0xFF3B82F6)),
                 const SizedBox(width: 6),
                 Text('${session.startTime} - ${session.endTime}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF3B82F6))),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMySession ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isMySession ? Iconsax.verify : Iconsax.user_octagon, 
            size: 18, 
            color: isMySession ? const Color(0xFF3B82F6) : const Color(0xFF64748B)
          ),
        ),
      ),
    );
  }
}
