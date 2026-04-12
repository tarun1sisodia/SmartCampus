import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/student_model.dart';
import '../../../common/utils/constants/api_constants.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/device/device_utility.dart';

class SwipeableStudentCard extends StatelessWidget {
  final StudentModel student;
  final Function(String) onStatusChanged;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const SwipeableStudentCard({
    super.key,
    required this.student,
    required this.onStatusChanged,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = DeviceUtility.isLandscapeOrientation(context);
    final cardHeight = isLandscape ? 240.0 : 360.0;
    final statusColor = _getStatusColor(student.attendanceStatus);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          onStatusChanged('present');
          onSwipeRight();
        } else if (details.primaryVelocity! < 0) {
          onStatusChanged('absent');
          onSwipeLeft();
        }
      },
      child: Container(
        height: cardHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: statusColor, width: 2.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Status (Sharp & High Contrast)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: statusColor,
              child: Text(
                _getStatusText(student.attendanceStatus).toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            // Image Section (No gradients, sharp borders)
            Expanded(
              child: Container(
                color: TColors.slate50,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (student.imageUrl != null && student.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: ApiConstants.optimizeImageUrl(student.imageUrl!, width: 600, height: 600),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: TColors.executiveNavy, strokeWidth: 3)),
                        errorWidget: (context, url, error) => _buildPlaceholder(context),
                      )
                    else
                      _buildPlaceholder(context),
                    
                    // Simple white border at the bottom of image for contrast
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(height: 1.5, color: statusColor),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Info (Bold & High Contrast)
            Container(
              padding: const EdgeInsets.all(20),
              color: TColors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (student.name ?? 'STUDENT NAME').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TColors.slate900, letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ROLL: ${student.rollNumber ?? 'N/A'}'.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: TColors.slate600, letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.user, size: 80, color: TColors.blue100),
          const SizedBox(height: 8),
          Text(
            (student.name ?? '?').substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: TColors.blue100,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'present': return 'PRESENT';
      case 'absent': return 'ABSENT';
      case 'late': return 'LATE';
      case 'excused': return 'EXCUSED';
      default: return 'SWIPE TO MARK';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'present': return const Color(0xFF10B981); // Emerald-500
      case 'absent': return const Color(0xFFEF4444); // Red-500
      case 'late': return const Color(0xFFF59E0B); // Amber-500
      case 'excused': return const Color(0xFF3B82F6); // Blue-500
      default: return TColors.executiveNavy;
    }
  }
}
