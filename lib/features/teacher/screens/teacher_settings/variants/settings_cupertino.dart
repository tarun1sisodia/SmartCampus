import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Divider, Icons, InkWell, Color, ColorScheme, Theme, ThemeData, CircleAvatar, TextButton, FontWeight, TextStyle, BorderRadius, Radius, Offset, BoxShape, BoxShadow, BoxDecoration, Border, BorderSide, Widget, EdgeInsets, Column, Row, Expanded, SizedBox, BuildContext, StatelessWidget, Center, ListView, Stack, Positioned, Obx, Get, IconData, Icon, MainAxisAlignment, CrossAxisAlignment, MainAxisSize, VoidCallback, Spacer, Badge, CircleAvatar, TextSelectionTheme, TextSelectionThemeData, TextFormField, InputDecoration, InputBorder, OutlineInputBorder, FileImage, Chip;
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/theme_configs.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../common/ui_patterns/ui_style.dart';
import '../../../../common/ui_patterns/ui_style_controller.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../../../../services/language_service.dart';
import '../teacher_profile_screen.dart';

class SettingsCupertino extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsCupertino({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          _buildIosProfile(context),
          const SizedBox(height: 32),
          _buildIosSection('PREFERENCES', [
            _buildIosItem('Language', CupertinoIcons.globe, 
              trailing: Obx(() => Text(languageService.getCurrentLanguageName(), style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13))),
              onTap: () => _showLanguageSelectionDialog(context)
            ),
            _buildIosItem('Biometric Login', CupertinoIcons.lock_shield, 
              trailing: Obx(() {
                final bio = Get.find<BiometricAuthService>();
                return bio.isAvailable.value 
                  ? CupertinoSwitch(value: bio.isBiometricEnabled.value, onChanged: (v) => controller.toggleBiometric(v)) 
                  : const SizedBox.shrink();
              })
            ),
            _buildIosItem('Email Notifications', CupertinoIcons.bell, 
              trailing: Obx(() => CupertinoSwitch(value: controller.emailNotifications.value, onChanged: (v) => controller.toggleEmailNotifications(v)))
            ),
          ]),
          const SizedBox(height: 24),
          _buildIosSection('APPEARANCE', [
            _buildThemeSelector(context),
            _buildPatternSelector(context),
          ]),
          const SizedBox(height: 24),
          _buildIosSection('DATA & TOOLS', [
            _buildIosItem('Import Data', CupertinoIcons.icloud_and_arrow_down, onTap: () => Get.toNamed(AppRoutes.import)),
            _buildIosItem('Export History', CupertinoIcons.icloud_and_arrow_up, onTap: () => Get.toNamed(AppRoutes.export)),
            _buildIosItem('Storage Management', CupertinoIcons.cube_box, onTap: () => _showStorageDataDialog(context)),
          ]),
          const SizedBox(height: 48),
          _buildSignOutButton(context),
          const SizedBox(height: 40),
          const Center(child: Text('VERSION 1.2.4', style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 1))),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildIosProfile(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFC7C7CC)),
            ),
            child: const Icon(CupertinoIcons.person_fill, color: Color(0xFF007AFF), size: 40),
          ),
          const SizedBox(height: 16),
          Text(user?.name ?? 'Teacher', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5)),
          Text(user?.email ?? 'teacher@campus.com', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Get.to(() => TeacherProfileScreen()),
            child: const Text('Edit Account Info', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      );
    });
  }

  Widget _buildIosSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.normal, fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildIosItem(String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF007AFF), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ),
            trailing ?? const Icon(CupertinoIcons.chevron_forward, size: 16, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final tc = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
        const Padding(padding: EdgeInsets.only(left: 16, top: 16, bottom: 12), child: Text('Color Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppThemes.themes.length,
            itemBuilder: (context, index) {
              final theme = AppThemes.themes[index];
              return Obx(() {
                final sel = tc.currentThemeIndex.value == index;
                return GestureDetector(
                  onTap: () => tc.setTheme(index),
                  child: Container(
                    width: 50, margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                      border: sel ? Border.all(color: const Color(0xFF007AFF), width: 3) : Border.all(color: const Color(0xFFC7C7CC), width: 1),
                    ),
                    child: sel ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 20) : null,
                  ),
                );
              });
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPatternSelector(BuildContext context) {
    final uc = UIStyleController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, indent: 16, color: Color(0xFFF2F2F7)),
        const Padding(padding: EdgeInsets.only(left: 16, top: 16, bottom: 12), child: Text('Design Pattern', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: UIStyle.values.length,
            itemBuilder: (context, index) {
              final style = UIStyle.values[index];
              return Obx(() {
                final sel = uc.currentStyle.value == style;
                return GestureDetector(
                  onTap: () => uc.setStyle(style),
                  child: Container(
                    width: 80, margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF007AFF) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIcon(style), color: sel ? Colors.white : const Color(0xFF007AFF), size: 24),
                        const SizedBox(height: 8),
                        Text(style.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: sel ? Colors.white : const Color(0xFF007AFF))),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  IconData _getIcon(UIStyle s) {
    switch (s) {
      case UIStyle.industrialCorporate: return CupertinoIcons.building_2_fill;
      case UIStyle.softMinimalist: return CupertinoIcons.circle_grid_hex;
      case UIStyle.glassmorphism: return CupertinoIcons.sparkles;
      case UIStyle.neumorphism: return CupertinoIcons.app_badge;
      case UIStyle.material3: return CupertinoIcons.fullscreen;
      case UIStyle.cupertinoPro: return CupertinoIcons.device_phone_portrait;
      case UIStyle.cyberpunkNeon: return CupertinoIcons.bolt_fill;
      case UIStyle.brutalistBold: return CupertinoIcons.square_on_square_fill;
      case UIStyle.academicClassic: return CupertinoIcons.book_fill;
      case UIStyle.fluentLayered: return CupertinoIcons.layers_fill;
    }
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Language'),
        actions: languageService.languages.map((lang) => CupertinoActionSheetAction(
          onPressed: () {
            languageService.changeLanguage(lang['code']);
            Get.back();
          },
          child: Text(lang['name'].toString()),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showStorageDataDialog(BuildContext context) async {
    final storageService = Get.find<StorageService>();
    final cacheSize = await storageService.getCacheSize();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Storage Management'),
        message: Text('Cache Size: ${cacheSize.toStringAsFixed(1)} MB'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () { storageService.clearCache(); Get.back(); },
            child: const Text('Clear Cache'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () { storageService.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); },
            child: const Text('Hard Reset'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return CupertinoButton(
      child: const Text('Secure Sign Out', style: TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.bold)),
      onPressed: () => _confirmSignOut(context),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to exit? Your data is safe.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: const Text('Stay'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => controller.logout(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
