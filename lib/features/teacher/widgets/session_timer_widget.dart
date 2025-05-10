import 'package:flutter/material.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/helpers/helper_function.dart';

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
    final dark = THelperFunction.isDarkMode(context);

    // Choose icon based on mode
    final icon = isCountdownMode
        ? (isSessionActive ? Icons.timer : Icons.timer_off)
        : Icons.hourglass_top;

    // Choose color based on mode and status
    final color = isCountdownMode
        ? (isSessionActive
            ? (dark ? TColors.yellow : TColors.primary)
            : Colors.red)
        : (dark ? Colors.blue : Colors.blue);

    // Choose label based on mode
    final label = isCountdownMode
        ? (isSessionActive ? 'Time Remaining:' : 'Session Status:')
        : 'Session Duration:';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: dark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          remainingTime,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

