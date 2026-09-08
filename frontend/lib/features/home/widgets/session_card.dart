import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_campus/features/home/models/session_model.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final startTime = DateFormat('hh:mm a').format(session.startTime).toUpperCase();
    final endTime = session.endTime == null
        ? null
        : DateFormat('hh:mm a').format(session.endTime!).toUpperCase();
    final timeLabel = endTime == null ? startTime : '$startTime - $endTime';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: scheme.outline, width: 1.5),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: scheme.primary, width: 1.5),
          ),
          child: Icon(Icons.class_outlined, color: scheme.primary, size: 24),
        ),
        title: Text(
          session.subjectName.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: scheme.onSurface,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people_outline, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  '${session.totalStudents} STUDENTS',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'SECTION ${session.section}'.toUpperCase(),
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: scheme.onSurface),
      ),
    );
  }
}
