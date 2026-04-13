import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';

class SharpToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SharpToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value 
              ? Theme.of(context).primaryColor 
              : (isDark ? TColors.slate800 : TColors.slate50),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isDark ? TColors.slate700 : TColors.slate400,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? Colors.white : (isDark ? TColors.slate400 : TColors.slate600),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
