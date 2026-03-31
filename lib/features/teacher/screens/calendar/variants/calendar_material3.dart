import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../common/ui_patterns/pattern_tokens.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../controllers/calendar_controller.dart';
import '../../../../models/attendance_session_model.dart';

class CalendarMaterial3 extends StatelessWidget {
  final CalendarController controller;

  const CalendarMaterial3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = PatternTokens.get(UIStyle.material3);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildActiveChip(theme),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildM3Calendar(theme),
                  const SizedBox(height: 32),
                  Text('Scheduled Sessions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _buildM3SessionList(theme),
                  const SizedBox(height: 48),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip(ThemeData theme) {
    return Obx(() {
      final activeCount = controller.activeSessionsCount.value;
      if (activeCount == 0) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: ActionChip(
          onPressed: () {},
          avatar: Icon(Icons.bolt, color: theme.colorScheme.primary, size: 16),
          label: Text('$activeCount LIVE_SESSIONS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: theme.colorScheme.primary)),
          backgroundColor: theme.colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
      );
    });
  }

  Widget _buildM3Calendar(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            markerDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
            todayTextStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800),
            selectedDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
            selectedTextStyle: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w900),
            defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
            weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.error),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w800),
            formatButtonTextStyle: theme.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
            formatButtonDecoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
            leftChevronIcon: Icon(Iconsax.arrow_left_2, size: 20, color: theme.colorScheme.primary),
            rightChevronIcon: Icon(Iconsax.arrow_right_3, size: 20, color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildM3SessionList(ThemeData theme) {
    final sessions = controller.getSessionsForDay(controller.selectedDay.value);
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No events scheduled for this day', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _buildM3SessionCard(sessions[index], theme),
    );
  }

  Widget _buildM3SessionCard(AttendanceSessionModel session, ThemeData theme) {
    final isMySession = controller.userClasses.any((cls) => cls.id == session.classId);
    final isActive = controller.isSessionActive(session);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? theme.colorScheme.primary.withOpacity(0.05) : theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: isActive ? BorderSide(color: theme.colorScheme.primary, width: 1.5) : BorderSide.none),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(session.subjectName ?? 'Session', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('${session.courseName} | SEM ${session.semester}', style: theme.textTheme.labelSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                 Icon(Iconsax.clock, size: 14, color: theme.colorScheme.primary),
                 const SizedBox(width: 8),
                 Text('${session.startTime} - ${session.endTime}', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
              ],
            ),
          ],
        ),
        trailing: Container(
           width: 44,
           height: 44,
           decoration: BoxDecoration(shape: BoxShape.circle, color: isMySession ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest),
           child: Center(child: Icon(isMySession ? Iconsax.verify : Iconsax.user_octagon, size: 20, color: isMySession ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant)),
        ),
      ),
    );
  }
}
