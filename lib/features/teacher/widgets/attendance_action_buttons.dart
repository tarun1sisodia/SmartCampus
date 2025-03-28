import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/sized.dart';

class AttendanceActionButtons extends StatelessWidget {
  final Function(String) onMarkAttendance;
  
  const AttendanceActionButtons({
    super.key,
    required this.onMarkAttendance,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          'Absent',
          Iconsax.close_circle,
          Colors.red,
          () => onMarkAttendance('absent'),
        ),
        _buildActionButton(
          context,
          'Late',
          Iconsax.timer_1,
          Colors.orange,
          () => onMarkAttendance('late'),
        ),
        _buildActionButton(
          context,
          'Excused',
          Iconsax.note_1,
          Colors.blue,
          () => onMarkAttendance('excused'),
        ),
        _buildActionButton(
          context,
          'Present',
          Iconsax.tick_circle,
          Colors.green,
          () => onMarkAttendance('present'),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color),
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
