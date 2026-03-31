import 'package:flutter/material.dart';

class ThemeConfig {
  final String name;
  final bool isDark;
  final Color primary;
  final Color background;
  final Color surface;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color error;
  final Color warning;

  const ThemeConfig({
    required this.name,
    required this.isDark,
    required this.primary,
    required this.background,
    required this.surface,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    this.success = const Color(0xFF10B981),
    this.error = const Color(0xFFEF4444),
    this.warning = const Color(0xFFF59E0B),
  });
}

class AppThemes {
  static const List<ThemeConfig> themes = [
    // 1: Neobrutalist Orange
    ThemeConfig(
      name: 'Neobrutalist Orange',
      isDark: false,
      primary: Color(0xFFFF6B00),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFF3F4F6),
      accent: Color(0xFF000000),
      textPrimary: Color(0xFF000000),
      textSecondary: Color(0xFF4B5563),
      border: Color(0xFF000000),
    ),
    // 2: Onyx Brutalist
    ThemeConfig(
      name: 'Onyx Brutalist',
      isDark: true,
      primary: Color(0xFFF3F4F6),
      background: Color(0xFF000000),
      surface: Color(0xFF111827),
      accent: Color(0xFFFF6B00),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFF9CA3AF),
      border: Color(0xFF374151),
    ),
    // 4: Cyberpunk Edge
    ThemeConfig(
      name: 'Cyberpunk Edge',
      isDark: true,
      primary: Color(0xFF00FF9F),
      background: Color(0xFF050505),
      surface: Color(0xFF0F0F0F),
      accent: Color(0xFFFF0055),
      textPrimary: Color(0xFFE0E0E0),
      textSecondary: Color(0xFFA0A0A0),
      border: Color(0xFF1F1F1F),
    ),
    // 6: Wireframe Dark
    ThemeConfig(
      name: 'Wireframe Dark',
      isDark: true,
      primary: Color(0xFFFFFFFF),
      background: Color(0xFF000000),
      surface: Color(0xFF0A0A0A),
      accent: Color(0xFF333333),
      textPrimary: Color(0xFFFAFAFA),
      textSecondary: Color(0xFF737373),
      border: Color(0xFF1A1A1A),
    ),
    // 7: Sepia Terracotta
    ThemeConfig(
      name: 'Sepia Terracotta',
      isDark: false,
      primary: Color(0xFFBC6C25),
      background: Color(0xFFFEFAE0),
      surface: Color(0xFFFAEDCD),
      accent: Color(0xFFD4A373),
      textPrimary: Color(0xFF283618),
      textSecondary: Color(0xFF606C38),
      border: Color(0xFFE9EDC9),
    ),
    // 9: Sandstone Olive
    ThemeConfig(
      name: 'Sandstone Olive',
      isDark: false,
      primary: Color(0xFF606C38),
      background: Color(0xFFF2E8CF),
      surface: Color(0xFFE2D9C2),
      accent: Color(0xFFA7C957),
      textPrimary: Color(0xFF386641),
      textSecondary: Color(0xFF6A994E),
      border: Color(0xFFBCBD8B),
    ),
    // 10: Desert Night
    ThemeConfig(
      name: 'Desert Night',
      isDark: true,
      primary: Color(0xFFE9C46A),
      background: Color(0xFF1A1A1A),
      surface: Color(0xFF242424),
      accent: Color(0xFFF4A261),
      textPrimary: Color(0xFFF4A261),
      textSecondary: Color(0xFF2A9D8F),
      border: Color(0xFF2A9D8F),
    ),
    // 13: Crisp Executive Navy
    ThemeConfig(
      name: 'Crisp Executive Navy',
      isDark: false,
      primary: Color(0xFF1D4ED8),
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      accent: Color(0xFF60A5FA),
      textPrimary: Color(0xFF1E293B),
      textSecondary: Color(0xFF64748B),
      border: Color(0xFFE2E8F0),
    ),
    // 15: Banking Blue Light
    ThemeConfig(
      name: 'Banking Blue Light',
      isDark: false,
      primary: Color(0xFF0284C7),
      background: Color(0xFFF0F9FF),
      surface: Color(0xFFFFFFFF),
      accent: Color(0xFF0EA5E9),
      textPrimary: Color(0xFF0C4A6E),
      textSecondary: Color(0xFF0369A1),
      border: Color(0xFFBAE6FD),
    ),
    // 18: Monolithic Slate
    ThemeConfig(
      name: 'Monolithic Slate',
      isDark: true,
      primary: Color(0xFFCBD5E1),
      background: Color(0xFF0F172A),
      surface: Color(0xFF1E293B),
      accent: Color(0xFFFFFFFF),
      textPrimary: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
      border: Color(0xFF334155),
    ),
    // 20: Abyssal Crimson
    ThemeConfig(
      name: 'Abyssal Crimson',
      isDark: true,
      primary: Color(0xFFEE4444),
      background: Color(0xFF0F0000),
      surface: Color(0xFF1A0000),
      accent: Color(0xFFFF8888),
      textPrimary: Color(0xFFFFEEEE),
      textSecondary: Color(0xFFCC8888),
      border: Color(0xFF2A0000),
    ),
    // 21: Deep Ocean Cyan
    ThemeConfig(
      name: 'Deep Ocean Cyan',
      isDark: true,
      primary: Color(0xFF22D3EE),
      background: Color(0xFF081C25),
      surface: Color(0xFF0E2E3B),
      accent: Color(0xFF06B6D4),
      textPrimary: Color(0xFFE0F2FE),
      textSecondary: Color(0xFF7DD3FC),
      border: Color(0xFF164E63),
    ),
    // 23: Obsidian & Amber
    ThemeConfig(
      name: 'Obsidian & Amber',
      isDark: true,
      primary: Color(0xFFF59E0B),
      background: Color(0xFF050505),
      surface: Color(0xFF121212),
      accent: Color(0xFFD97706),
      textPrimary: Color(0xFFFAFAF9),
      textSecondary: Color(0xFFA8A29E),
      border: Color(0xFF1C1917),
    ),
    // 25: Pure Minimal Light
    ThemeConfig(
      name: 'Pure Minimal Light',
      isDark: false,
      primary: Color(0xFF18181B),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFAFAFA),
      accent: Color(0xFF52525B),
      textPrimary: Color(0xFF09090B),
      textSecondary: Color(0xFF71717A),
      border: Color(0xFFE4E4E7),
    ),
    // 29: Midnight Indigo
    ThemeConfig(
      name: 'Midnight Indigo',
      isDark: true,
      primary: Color(0xFF818CF8),
      background: Color(0xFF1E1B4B),
      surface: Color(0xFF312E81),
      accent: Color(0xFFA5B4FC),
      textPrimary: Color(0xFFEEF2FF),
      textSecondary: Color(0xFFC7D2FE),
      border: Color(0xFF4338CA),
    ),
    // 30: Monochrome Precision
    ThemeConfig(
      name: 'Monochrome Precision',
      isDark: false,
      primary: Color(0xFF000000),
      background: Color(0xFFFAFAFA),
      surface: Color(0xFFFFFFFF),
      accent: Color(0xFF717171),
      textPrimary: Color(0xFF171717),
      textSecondary: Color(0xFF525252),
      border: Color(0xFFE5E5E5),
    ),
  ];
}
