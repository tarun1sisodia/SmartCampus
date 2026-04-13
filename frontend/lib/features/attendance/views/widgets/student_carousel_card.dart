import 'package:flutter/material.dart';
import 'package:smart_campus/shared/widgets/network_image_with_placeholder.dart';
import '../../models/attendance_record_model.dart';
import '../../../../common/utils/constants/colors.dart';

class StudentCarouselCard extends StatelessWidget {
  final AttendanceRecordModel student;
  final Function(String status) onStatusSelected;
  final VoidCallback? onStudentTap;

  const StudentCarouselCard({
    super.key,
    required this.student,
    required this.onStatusSelected,
    this.onStudentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TColors.slate400, width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: TColors.executiveNavy, width: 2.0),
                ),
                child: NetworkImageWithPlaceholder(
                  imageUrl: student.photoUrl ?? 'https://via.placeholder.com/300',
                  width: double.infinity,
                  borderRadius: 4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onStudentTap,
              child: Text(
                student.name.toUpperCase(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: TColors.slate900, letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
            ),
            if (student.rollNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                'ROLL NO: ${student.rollNumber}'.toUpperCase(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: TColors.slate600, letterSpacing: 0.5),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusButton(context, 'absent', 'ABSENT', const Color(0xFFF43F5E), const Color(0xFFFFF1F2)),
                _buildStatusButton(context, 'present', 'PRESENT', const Color(0xFF10B981), const Color(0xFFECFDF5)),
                _buildStatusButton(context, 'late', 'LATE', const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, String status, String label, Color color, Color bgColor) {
    final isSelected = student.status == status;
    
    return Column(
      children: [
        InkWell(
          onTap: () => onStatusSelected(status),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? color : bgColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 2.5),
            ),
            child: Icon(
              _getIconForStatus(status),
              color: isSelected ? Colors.white : color,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'present': return Icons.check;
      case 'absent': return Icons.close;
      case 'late': return Icons.access_time;
      default: return Icons.help_outline;
    }
  }
}
