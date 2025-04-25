import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';

class StatsContainer extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsContainer({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    //print('Building StatsContainer widget');
    // Check if we're in dark mode
    final dark = THelperFunction.isDarkMode(context);
    //print('Dark mode: $dark');

    // Determine container and border colors based on theme
    final containerColor = dark ? Theme.of(context).cardColor : Colors.white;
    //print('Container color: $containerColor');

    final borderColor = dark ? Colors.grey.shade800 : Colors.grey.shade300;
    //print('Border color: $borderColor');

    // Determine text color based on theme
    final textColor = dark ? Colors.white : Colors.black87;
    //print('Text color: $textColor');

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black12 : Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with colored background
          Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              border: Border.all(color: color.withAlpha(77), width: 1),
            ),
            child: Icon(icon, color: color),
          ),

          const Spacer(),

          // Value with bold styling
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),

          const SizedBox(height: TSizes.xs),

          // Title with appropriate color
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
          ),
        ],
      ),
    );
  }
}
