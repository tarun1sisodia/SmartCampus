import 'package:flutter/material.dart';
import '../../../../common/utils/constants/colors.dart';
import '../../../../common/utils/constants/sized.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.dark,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final bool dark;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          gradient: dark ? TColors.cardGradient5 : TColors.cardGradient1,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: TSizes.spaceBtwItems),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
