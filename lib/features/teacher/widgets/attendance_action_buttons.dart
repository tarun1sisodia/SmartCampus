import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AttendanceActionButtons extends StatelessWidget {
  final Function(String) onMarkAttendance;

  const AttendanceActionButtons({super.key, required this.onMarkAttendance});

  @override
  Widget build(BuildContext context) {
    //print('Building AttendanceActionButtons');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          'Absent',
          Iconsax.close_circle,
          Colors.red,
          () {
            //print('Marking attendance as absent');
            onMarkAttendance('absent');
          },
        ),
        _buildActionButton(
          context,
          'Late',
          Iconsax.timer_1,
          Colors.orange,
          () {
            //print('Marking attendance as late');
            onMarkAttendance('late');
          },
        ),
        _buildActionButton(
          context,
          'Excused',
          Iconsax.note_1,
          Colors.blue,
          () {
            //print('Marking attendance as excused');
            onMarkAttendance('excused');
          },
        ),
        _buildActionButton(
          context,
          'Present',
          Iconsax.tick_circle,
          Colors.green,
          () {
            //print('Marking attendance as present');
            onMarkAttendance('present');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    //print('Building action button for $label');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color),
          style: IconButton.styleFrom(
            backgroundColor: color.withAlpha(26),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
