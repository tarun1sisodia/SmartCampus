import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';

class SessionTimerWidget extends StatelessWidget {
  final String remainingTime;
  final bool isSessionActive;
  final bool isCountdownMode;

  const SessionTimerWidget({
    super.key,
    required this.remainingTime,
    required this.isSessionActive,
    this.isCountdownMode = true,
  });

  @override
  Widget build(BuildContext context) {
    // Choose status configuration
    final bool isEnded = remainingTime.contains('Ended') || !isSessionActive;
    final Color statusColor = isEnded ? const Color(0xFFE11D48) : TColors.executiveNavy;
    final IconData icon = isCountdownMode ? Iconsax.timer_1 : Iconsax.watch5; //watch5 replace with stopwatch

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: statusColor, size: 20),
        const SizedBox(width: 12),
        Text(
          (isCountdownMode ? 'REMAINING:' : 'DURATION:').toUpperCase(),
          style: const TextStyle(
            color: TColors.slate600,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            remainingTime.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
