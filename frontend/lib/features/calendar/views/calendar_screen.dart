import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../app/dependency_injection.dart';
import '../bloc/calendar_bloc.dart';
import '../models/calendar_session_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CalendarBloc>()..add(LoadMonth(_focusedDay)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        body: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            if (state is CalendarLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CalendarError) {
              return Center(child: Text('Failed to load month: ${state.message}'));
            }
            if (state is! CalendarLoaded) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: TableCalendar<CalendarSessionModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    _selectedDay != null && isSameDay(_selectedDay, day),
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return state.sessionsByDay[key] ?? <CalendarSessionModel>[];
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  context.read<CalendarBloc>().add(LoadMonth(focusedDay));
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  final dayKey = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                  final sessions = state.sessionsByDay[dayKey] ?? <CalendarSessionModel>[];
                  _showDaySessions(context, dayKey, sessions);
                },
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDaySessions(
    BuildContext context,
    DateTime day,
    List<CalendarSessionModel> sessions,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        if (sessions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No sessions on ${DateFormat('EEE, MMM d').format(day)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, index) {
            final session = sessions[index];
            final start = DateFormat('hh:mm a').format(session.startTime);
            final end = session.endTime == null
                ? null
                : DateFormat('hh:mm a').format(session.endTime!);
            return ListTile(
              title: Text(session.subjectName),
              subtitle: Text(
                'Section ${session.section} • ${end == null ? start : '$start - $end'}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/session/${session.id}');
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: sessions.length,
        );
      },
    );
  }
}
