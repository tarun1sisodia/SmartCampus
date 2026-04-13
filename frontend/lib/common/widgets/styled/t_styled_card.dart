import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui_patterns/pattern_tokens.dart';
import '../../ui_patterns/ui_style_controller.dart';

class TStyledCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const TStyledCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = UIStyleController.instance;

    return Obx(() {
      final style = uiController.currentStyle.value;
      final tokens = PatternTokens.get(style, isDark: context.isDarkMode);

      Widget cardContainer = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: tokens.backgroundColor,
          borderRadius: BorderRadius.circular(tokens.borderRadius),
          border: tokens.border,
          boxShadow: tokens.shadows,
          gradient: tokens.gradient,
        ),
        child: child,
      );

      // Apply Backdrop Blur if needed (Glassmorphism, Cupertino, Fluent)
      if (tokens.backdropBlur != null) {
        cardContainer = ClipRRect(
          borderRadius: BorderRadius.circular(tokens.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: tokens.backdropBlur!, sigmaY: tokens.backdropBlur!),
            child: cardContainer,
          ),
        );
      }

      if (onTap != null) {
        return GestureDetector(
          onTap: onTap,
          child: cardContainer,
        );
      }

      return cardContainer;
    });
  }
}
