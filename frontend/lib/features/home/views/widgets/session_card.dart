import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/session_model.dart';
import '../../../../common/utils/constants/colors.dart';

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
    final startTime = DateFormat('hh:mm a').format(session.startTime).toUpperCase();
    final endTime = session.endTime == null
        ? null
        : DateFormat('hh:mm a').format(session.endTime!).toUpperCase();
    final timeLabel = endTime == null ? startTime : '$startTime - $endTime';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 1.5),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: TColors.blue100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: TColors.executiveNavy, width: 1.5),
          ),
          child: const Icon(Icons.class_outlined, color: TColors.executiveNavy, size: 24),
        ),
        title: Text(
          session.subjectName.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: TColors.slate900, letterSpacing: -0.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: TColors.slate600),
                const SizedBox(width: 8),
                Text(timeLabel, style: const TextStyle(color: TColors.slate600, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5)),
                const SizedBox(width: 16),
                const Icon(Icons.people_outline, size: 14, color: TColors.slate600),
                const SizedBox(width: 8),
                Text('${session.totalStudents} STUDENTS', style: const TextStyle(color: TColors.slate600, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'SECTION ${session.section}'.toUpperCase(),
              style: const TextStyle(
                color: TColors.slate500,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: TColors.slate900),
      ),
    );
  }
}
