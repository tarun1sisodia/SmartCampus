import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';
import 'ui_style.dart';

class PatternTokens {
  final double borderRadius;
  final List<BoxShadow> shadows;
  final Border? border;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double? backdropBlur;
  final double spacingMultiplier;
  final Duration animationDuration;
  final String? fontFamily;
  final FontWeight? fontWeight;

  const PatternTokens({
    required this.borderRadius,
    this.shadows = const [],
    this.border,
    this.gradient,
    this.backgroundColor,
    this.backdropBlur,
    this.spacingMultiplier = 1.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.fontFamily,
    this.fontWeight,
  });

  static PatternTokens get(UIStyle style, {bool isDark = false}) {
    switch (style) {
      case UIStyle.industrialCorporate:
        return PatternTokens(
          borderRadius: 2.0,
          backgroundColor: isDark ? TColors.slate900 : TColors.white,
          border: Border.all(color: TColors.slate400, width: 1.5),
          shadows: [
            BoxShadow(
              color: TColors.black.withValues(alpha: 0.1),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
          spacingMultiplier: 0.8,
          animationDuration: const Duration(milliseconds: 150),
          fontWeight: FontWeight.w900,
        );

      case UIStyle.softMinimalist:
        return PatternTokens(
          borderRadius: 24.0,
          backgroundColor: isDark ? TColors.slate800 : TColors.white,
          shadows: [
            BoxShadow(
              color: TColors.slate400.withValues(alpha: 0.15),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
          spacingMultiplier: 1.2,
          animationDuration: const Duration(milliseconds: 400),
        );

      case UIStyle.glassmorphism:
        return PatternTokens(
          borderRadius: 20.0,
          backdropBlur: 10.0,
          backgroundColor: Colors.white.withValues(alpha: isDark ? 0.05 : 0.4),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: isDark ? 0.1 : 0.5),
              Colors.white.withValues(alpha: isDark ? 0.05 : 0.2),
            ],
          ),
          spacingMultiplier: 1.1,
          animationDuration: const Duration(milliseconds: 500),
        );

      case UIStyle.neumorphism:
        return PatternTokens(
          borderRadius: 30.0,
          backgroundColor: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF0F0F0),
          shadows: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white,
              offset: const Offset(-5, -5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : TColors.slate400.withValues(alpha: 0.3),
              offset: const Offset(5, 5),
              blurRadius: 10,
            ),
          ],
          spacingMultiplier: 0.9,
          animationDuration: const Duration(milliseconds: 600),
        );

      case UIStyle.material3:
        return PatternTokens(
          borderRadius: 28.0,
          backgroundColor: isDark ? TColors.slate900 : TColors.blue100.withValues(alpha: 0.3),
          shadows: [
            BoxShadow(
              color: TColors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
          spacingMultiplier: 1.0,
          animationDuration: const Duration(milliseconds: 350),
        );

      case UIStyle.cupertinoPro:
        return PatternTokens(
          borderRadius: 12.0,
          backdropBlur: 20.0,
          backgroundColor: Colors.white.withValues(alpha: isDark ? 0.1 : 0.7),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
          shadows: [
            BoxShadow(
              color: TColors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
          spacingMultiplier: 1.05,
          animationDuration: const Duration(milliseconds: 250),
        );

      case UIStyle.cyberpunkNeon:
        return PatternTokens(
          borderRadius: 0.0,
          backgroundColor: const Color(0xFF0D0D0D),
          border: Border.all(color: TColors.deepOceanCyan, width: 2.0),
          shadows: [
            BoxShadow(
              color: TColors.deepOceanCyan.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
          spacingMultiplier: 0.85,
          animationDuration: const Duration(milliseconds: 100),
        );

      case UIStyle.brutalistBold:
        return PatternTokens(
          borderRadius: 0.0,
          backgroundColor: TColors.white,
          border: Border.all(color: TColors.black, width: 3.0),
          shadows: [
            const BoxShadow(
              color: TColors.black,
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
          spacingMultiplier: 0.8,
          animationDuration: const Duration(milliseconds: 0),
          fontWeight: FontWeight.w900,
        );

      case UIStyle.academicClassic:
        return PatternTokens(
          borderRadius: 4.0,
          backgroundColor: const Color(0xFFFAF9F6), // Off-white paper
          border: const Border.fromBorderSide(BorderSide(color: Color(0xFFD4C9B0), width: 1.0)),
          shadows: [
            BoxShadow(
              color: TColors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          spacingMultiplier: 1.3,
          animationDuration: const Duration(milliseconds: 500),
          fontFamily: 'Serif',
        );

      case UIStyle.fluentLayered:
        return PatternTokens(
          borderRadius: 8.0,
          backdropBlur: 15.0,
          backgroundColor: Colors.white.withValues(alpha: isDark ? 0.05 : 0.6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.0),
          shadows: [
            BoxShadow(
              color: TColors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: TColors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          spacingMultiplier: 1.0,
          animationDuration: const Duration(milliseconds: 450),
        );
    }
  }
}
