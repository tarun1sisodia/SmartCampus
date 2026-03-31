import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/calendar_controller.dart';
import '../../../../models/attendance_session_model.dart';

class CalendarCyberpunk extends StatelessWidget {
  final CalendarController controller;

  const CalendarCyberpunk({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const neonCyan = Color(0xFF00F5FF);
    const neonMagenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildHUDBackground(neonCyan),
          Column(
            children: [
              _buildLiveMonitor(neonCyan, neonMagenta),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: neonCyan));
                  }

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHUDCalendar(neonCyan, neonMagenta),
                      const SizedBox(height: 32),
                      Text(
                        'SECTOR_SCHEDULE_ACTIVE',
                        style: TextStyle(color: neonCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, shadows: [Shadow(color: neonCyan, blurRadius: 10)]),
                      ),
                      const SizedBox(height: 16),
                      _buildCyberSessionList(neonCyan, neonMagenta),
                      const SizedBox(height: 64),
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

  Widget _buildHUDBackground(Color cyan) {
    return Positioned.fill(
      child: CustomPaint(
        painter: HUDPainter(color: cyan.withOpacity(0.04)),
      ),
    );
  }

  Widget _buildLiveMonitor(Color cyan, Color magenta) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: cyan, width: 2),
          boxShadow: [BoxShadow(color: cyan.withOpacity(0.2), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: magenta, shape: BoxShape.rectangle)),
            const SizedBox(width: 12),
            Text(
              'UPLINK_LIVE: $activeCount'.toUpperCase(),
              style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
            ),
            const Spacer(),
            Icon(Iconsax.radar, color: magenta, size: 16),
          ],
        ),
      );
    });
  }

  Widget _buildHUDCalendar(Color cyan, Color magenta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: cyan.withOpacity(0.5), width: 1.5),
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
           markerDecoration: BoxDecoration(color: magenta, shape: BoxShape.rectangle),
           todayDecoration: BoxDecoration(color: cyan.withOpacity(0.1), border: Border.all(color: cyan, width: 1)),
           todayTextStyle: TextStyle(color: cyan, fontWeight: FontWeight.w900),
           selectedDecoration: BoxDecoration(color: cyan, shape: BoxShape.rectangle),
           selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
           defaultTextStyle: TextStyle(color: cyan.withOpacity(0.7), fontWeight: FontWeight.w800, fontFamily: 'Courier'),
           weekendTextStyle: TextStyle(color: magenta.withOpacity(0.7), fontWeight: FontWeight.w800, fontFamily: 'Courier'),
           outsideTextStyle: TextStyle(color: cyan.withOpacity(0.2)),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Courier', shadows: [Shadow(color: cyan, blurRadius: 5)]),
          formatButtonTextStyle: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 10, fontFamily: 'Courier'),
          formatButtonDecoration: BoxDecoration(border: Border.all(color: cyan, width: 1)),
          leftChevronIcon: Icon(Iconsax.arrow_left_2, size: 20, color: cyan),
          rightChevronIcon: Icon(Iconsax.arrow_right_3, size: 20, color: cyan),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: cyan.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 12),
          weekendStyle: TextStyle(color: magenta.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCyberSessionList(Color cyan, Color magenta) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(border: Border.all(color: cyan.withOpacity(0.2))),
        child: Center(child: Text('NULL_SECTOR_DATA', style: TextStyle(color: cyan.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _buildCyberSessionRow(sessions[index], cyan, magenta),
    );
  }

  Widget _buildCyberSessionRow(AttendanceSessionModel session, Color cyan, Color magenta) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);
    final activeColor = isActive ? magenta : (isMySession ? cyan : cyan.withOpacity(0.4));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: activeColor),
        boxShadow: isActive ? [BoxShadow(color: magenta.withOpacity(0.3), blurRadius: 10)] : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          (session.subjectName ?? 'SESSION').toUpperCase(),
          style: TextStyle(color: activeColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${session.courseName} | SEM ${session.semester}'.toUpperCase(),
              style: TextStyle(color: activeColor.withOpacity(0.6), fontWeight: FontWeight.w800, fontSize: 10, fontFamily: 'Courier'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                 Icon(Iconsax.clock, size: 14, color: activeColor),
                 const SizedBox(width: 8),
                 Text(
                   '${session.startTime} - ${session.endTime}'.toUpperCase(),
                   style: TextStyle(color: activeColor, fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Courier'),
                 ),
              ],
            ),
          ],
        ),
        trailing: Container(
           width: 44,
           height: 44,
           decoration: BoxDecoration(border: Border.all(color: activeColor.withOpacity(0.5))),
           child: Center(child: Icon(isMySession ? Iconsax.command : Iconsax.user_octagon, size: 20, color: activeColor)),
        ),
      ),
    );
  }
}

class HUDPainter extends CustomPainter {
  final Color color;
  HUDPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const double step = 40.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Corner brackets
    final bracketPaint = Paint()..color = color.withOpacity(0.2)..strokeWidth = 4;
    canvas.drawLine(Offset(0, 50), const Offset(0, 0), bracketPaint);
    canvas.drawLine(const Offset(0, 0), Offset(50, 0), bracketPaint);
    
    canvas.drawLine(Offset(size.width, 50), Offset(size.width, 0), bracketPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - 50, 0), bracketPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
