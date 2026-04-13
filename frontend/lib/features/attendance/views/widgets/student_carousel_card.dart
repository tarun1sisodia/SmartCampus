import 'package:flutter/material.dart';
import 'package:smart_campus/shared/widgets/network_image_with_placeholder.dart';
import '../../models/attendance_record_model.dart';

class StudentCarouselCard extends StatelessWidget {
  final AttendanceRecordModel student;
  final Function(String status) onStatusSelected;

  const StudentCarouselCard({
    super.key,
    required this.student,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: NetworkImageWithPlaceholder(
                imageUrl: student.photoUrl ?? 'https://via.placeholder.com/300',
                width: double.infinity,
                borderRadius: 20,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              student.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: Center,
            ),
            if (student.rollNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                'Roll No: ${student.rollNumber}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusButton(context, 'absent', 'ABSENT', Colors.red),
                _buildStatusButton(context, 'present', 'PRESENT', Colors.green),
                _buildStatusButton(context, 'late', 'LATE', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, String status, String label, Color color) {
    final isSelected = student.status == status;
    
    return Column(
      children: [
        InkWell(
          onTap: () => onStatusSelected(status),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              _getIconForStatus(status),
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
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
