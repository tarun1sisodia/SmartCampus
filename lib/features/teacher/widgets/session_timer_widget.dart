import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    this.isSessionActive = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.md,
        vertical: TSizes.xs,
      ),
      decoration: BoxDecoration(
        color: isSessionActive 
            ? (dark ? TColors.yellow.withOpacity(0.2) : TColors.deepPurple.withOpacity(0.2))
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: isSessionActive 
              ? (dark ? TColors.yellow : TColors.deepPurple)
              : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.timer_1,
            size: 16,
            color: isSessionActive 
                ? (dark ? TColors.yellow : TColors.deepPurple)
                : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            remainingTime,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSessionActive 
                  ? (dark ? TColors.yellow : TColors.deepPurple)
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
