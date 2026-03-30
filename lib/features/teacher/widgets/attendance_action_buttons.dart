import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/sized.dart';

class AttendanceActionButtons extends StatelessWidget {
  final Function(String) onMarkAttendance;

  const AttendanceActionButtons({super.key, required this.onMarkAttendance});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(context, 'Absent', Iconsax.close_circle, Colors.red, () => onMarkAttendance('absent')),
        _buildActionButton(context, 'Late', Iconsax.timer_1, Colors.orange, () => onMarkAttendance('late')),
        _buildActionButton(context, 'Excused', Iconsax.note_1, Colors.blue, () => onMarkAttendance('excused')),
        _buildActionButton(context, 'Present', Iconsax.tick_circle, Colors.green, () => onMarkAttendance('present')),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
            child: Ink(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
