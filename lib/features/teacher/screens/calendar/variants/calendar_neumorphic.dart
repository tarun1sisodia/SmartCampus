import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/calendar_controller.dart';
import '../../../../models/attendance_session_model.dart';

class CalendarNeumorphism extends StatelessWidget {
  final CalendarController controller;

  const CalendarNeumorphism({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE2E8F0);
    final tokens = PatternTokens.get(UIStyle.neumorphism);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          _buildLiveStatus(bgColor, tokens),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF94A3B8)));
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  _buildTactileCalendar(bgColor, tokens),
                  const SizedBox(height: 32),
                  const Text('ENGAGEMENT_ROSTER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, color: Color(0xFF475569))),
                  const SizedBox(height: 16),
                  _buildSessionList(bgColor, tokens),
                  const SizedBox(height: 48),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatus(Color bgColor, Map<String, dynamic> tokens) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             const BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
             BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(3, 3), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            const Icon(Iconsax.radar_2, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 12),
            Text(
              'LIVE_DATA_STREAMS: $activeCount'.toUpperCase(),
              style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTactileCalendar(Color bgColor, Map<String, dynamic> tokens) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-10, -10), blurRadius: 20),
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.4), offset: const Offset(10, 10), blurRadius: 20),
        ],
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
           markerDecoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
           todayDecoration: BoxDecoration(
             color: bgColor, 
             shape: BoxShape.circle,
             boxShadow: [
               BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
               BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4, inset: true),
             ]
           ),
           todayTextStyle: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900),
           selectedDecoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
           selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
           defaultTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF475569)),
           weekendTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
          formatButtonTextStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
          formatButtonDecoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
              BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4),
            ],
          ),
          leftChevronIcon: const Icon(Iconsax.arrow_left_2, size: 20, color: Color(0xFF1E293B)),
          rightChevronIcon: const Icon(Iconsax.arrow_right_3, size: 20, color: Color(0xFF1E293B)),
        ),
      ),
    );
  }

  Widget _buildSessionList(Color bgColor, Map<String, dynamic> tokens) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Text('NO_RECORDS_INDEXED', style: TextStyle(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _buildTactileSessionCard(sessions[index], bgColor, tokens),
    );
  }

  Widget _buildTactileSessionCard(AttendanceSessionModel session, Color bgColor, Map<String, dynamic> tokens) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.4), offset: const Offset(5, 5), blurRadius: 10),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        title: Text(
          (session.subjectName ?? 'SESSION').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${session.courseName} | SEM ${session.semester}'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                 const Icon(Iconsax.timer_1, size: 14, color: Color(0xFF1E293B)),
                 const SizedBox(width: 8),
                 Text(
                   '${session.startTime} - ${session.endTime}'.toUpperCase(),
                   style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF1E293B)),
                 ),
              ],
            ),
          ],
        ),
        trailing: Container(
           width: 48,
           height: 48,
           decoration: BoxDecoration(
             color: bgColor,
             shape: BoxShape.circle,
             boxShadow: [
                BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: !isMySession),
                BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4, inset: !isMySession),
             ],
           ),
           child: Center(child: Icon(isMySession ? Iconsax.verify : Iconsax.user_octagon, size: 20, color: isMySession ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8))),
        ),
      ),
    );
  }
}
