import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui_patterns/pattern_tokens.dart';
import '../../ui_patterns/ui_style_controller.dart';
import '../../utils/constants/colors.dart';

class TStyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;
  final double? width;

  const TStyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      final tokens = PatternTokens.get(style, isDark: context.isDarkMode);

      // Simple implementation for now, will refine based on patterns
      return Container(
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: isPrimary ? TColors.executiveNavy : TColors.white,
          borderRadius: BorderRadius.circular(tokens.borderRadius),
          boxShadow: isPrimary ? tokens.shadows : [],
          border: isPrimary ? null : tokens.border,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: isPrimary ? TColors.white : TColors.executiveNavy, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text.toUpperCase(),
                style: TextStyle(
                  color: isPrimary ? TColors.white : TColors.executiveNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
