import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class SessionTimerWidget extends StatelessWidget {
  final String remainingTime;
  final bool isSessionActive;

  const SessionTimerWidget({
    super.key,
    required this.remainingTime,
    required this.isSessionActive,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSessionActive ? Iconsax.timer_1 : Iconsax.timer_pause,
          color: isSessionActive 
              ? (dark ? TColors.yellow : TColors.deepPurple)
              : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          remainingTime,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSessionActive 
                ? (dark ? TColors.yellow : TColors.deepPurple)
                : Colors.red,
          ),
        ),
      ],
    );
  }
}
