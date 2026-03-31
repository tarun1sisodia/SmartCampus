import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    // Use current theme colors for a consistent look
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final errorColor = colorScheme.error;

    // Choose icon based on mode
    final icon = isCountdownMode
        ? (isSessionActive ? Icons.timer : Icons.timer_off)
        : Icons.hourglass_top;

    // Choose color based on status
    final color = isSessionActive ? primaryColor : errorColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          isCountdownMode ? 'Remaining:' : 'Duration:',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          remainingTime,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}
