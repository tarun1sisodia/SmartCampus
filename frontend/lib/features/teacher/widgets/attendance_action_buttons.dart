import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';

class AttendanceActionButtons extends StatelessWidget {
  final Function(String) onMarkAttendance;

  const AttendanceActionButtons({super.key, required this.onMarkAttendance});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(context, 'ABSENT', Iconsax.close_circle, const Color(0xFFEF4444), () => onMarkAttendance('absent')),
        _buildActionButton(context, 'LATE', Iconsax.timer_1, const Color(0xFFF59E0B), () => onMarkAttendance('late')),
        _buildActionButton(context, 'EXCUSED', Iconsax.note_1, const Color(0xFF3B82F6), () => onMarkAttendance('excused')),
        _buildActionButton(context, 'PRESENT', Iconsax.tick_circle, const Color(0xFF10B981), () => onMarkAttendance('present')),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            onDoubleTap: onPressed,
            borderRadius: BorderRadius.circular(2),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color, width: 2.0),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 1.0,
            color: color,
          ),
        ),
      ],
    );
  }
}
