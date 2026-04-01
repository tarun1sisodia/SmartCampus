import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/calendar_controller.dart';
import '../../../../models/attendance_session_model.dart';

class CalendarBrutalist extends StatelessWidget {
  final CalendarController controller;

  const CalendarBrutalist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildBrutalLive(orange),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildBrutalTable(yellow),
                  const SizedBox(height: 32),
                  const Text(
                    'DAILY_ENGAGEMENTS_01',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -1, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  _buildBrutalSessionList(blue),
                  const SizedBox(height: 64),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBrutalLive(Color orange) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: orange,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.black, size: 20),
            const SizedBox(width: 12),
            Text(
              'LIVE: $activeCount'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBrutalTable(Color yellow) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
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
           markerDecoration: const BoxDecoration(color: Colors.black, shape: BoxShape.rectangle),
           todayDecoration: BoxDecoration(color: yellow, border: Border.all(color: Colors.black, width: 2)),
           todayTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
           selectedDecoration: const BoxDecoration(color: Colors.black, shape: BoxShape.rectangle),
           selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
           defaultTextStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
           weekendTextStyle: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFEF4444)),
        ),
        headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -1),
          formatButtonTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
          formatButtonDecoration: BoxDecoration(border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 2))),
          leftChevronIcon: Icon(Iconsax.arrow_left_2, size: 20, color: Colors.black),
          rightChevronIcon: Icon(Iconsax.arrow_right_3, size: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildBrutalSessionList(Color blue) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 3), color: const Color(0xFFF1F5F9)),
        child: const Center(child: Text('EMPTY_SET_00', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _buildBrutalCard(sessions[index], blue),
    );
  }

  Widget _buildBrutalCard(AttendanceSessionModel session, Color blue) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        title: Text(
          (session.subjectName ?? 'SESSION').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${session.courseName} | SEM ${session.semester}'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                 const Icon(Iconsax.timer_1, size: 14, color: Colors.black),
                 const SizedBox(width: 8),
                 Text(
                   '${session.startTime} - ${session.endTime}'.toUpperCase(),
                   style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                 ),
              ],
            ),
          ],
        ),
        trailing: Container(
           padding: const EdgeInsets.all(8),
           decoration: BoxDecoration(color: isMySession ? blue : Colors.white, border: Border.all(color: Colors.black, width: 2)),
           child: Icon(isMySession ? Iconsax.verify : Iconsax.user_octagon, size: 20, color: Colors.black),
        ),
      ),
    );
  }
}
