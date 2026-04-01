import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/theme_configs.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../common/ui_patterns/ui_style_controller.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import '../../controllers/teacher_profile_controller.dart';
import '../../../../services/language_service.dart';
import '../teacher_profile_screen.dart';

class SettingsGlassmorphism extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsGlassmorphism({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          children: [
            _buildGlassProfile(context),
            const SizedBox(height: 32),
            _buildGlassSection('PREFERENCES', [
              _buildGlassItem('Language', Iconsax.language_square, 
                trailing: Obx(() => Text(languageService.getCurrentLanguageName(), style: const TextStyle(color: Colors.white70, fontSize: 12))),
                onTap: () => _showLanguageSelectionDialog(context)
              ),
              _buildGlassItem('Biometric Login', Iconsax.finger_scan, 
                trailing: Obx(() {
                  final bio = Get.find<BiometricAuthService>();
                  return bio.isAvailable.value 
                    ? Switch.adaptive(value: bio.isBiometricEnabled.value, onChanged: (v) => controller.toggleBiometric(v), activeColor: Colors.white) 
                    : const SizedBox.shrink();
                })
              ),
              _buildGlassItem('Email Notifications', Iconsax.notification, 
                trailing: Obx(() => Switch.adaptive(value: controller.emailNotifications.value, onChanged: (v) => controller.toggleEmailNotifications(v), activeColor: Colors.white))
              ),
            ]),
            const SizedBox(height: 24),
            _buildGlassSection('APPEARANCE', [
              _buildThemeSelector(context),
              _buildPatternSelector(context),
            ]),
            const SizedBox(height: 24),
            _buildGlassSection('OPERATIONS', [
              _buildGlassItem('Import Data', Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
              _buildGlassItem('Export Data', Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
              _buildGlassItem('Storage Management', Iconsax.cloud, onTap: () => _showStorageDataDialog(context)),
            ]),
            const SizedBox(height: 48),
            _buildSignOutButton(context),
            const SizedBox(height: 40),
            const Center(child: Text('BUILD 1.2.4', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2))),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassProfile(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return _glassContainer(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
                gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.05)]),
              ),
              child: const Icon(Iconsax.user, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Teacher', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(user?.email ?? 'teacher@campus.com', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.edit, color: Colors.white70),
              onPressed: () => Get.to(() => TeacherProfileScreen()),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGlassSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
        ),
        _glassContainer(
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildGlassItem(String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.white30),
      ),
    );
  }

  Widget _glassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeController = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 20, bottom: 12),
          child: Text('COLOR THEME', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppThemes.themes.length,
            itemBuilder: (context, index) {
              final theme = AppThemes.themes[index];
              return Obx(() {
                final isSelected = themeController.currentThemeIndex.value == index;
                return GestureDetector(
                  onTap: () => themeController.setTheme(index),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
                      boxShadow: isSelected ? [BoxShadow(color: theme.primary.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)] : null,
                    ),
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
    final uiController = UIStyleController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white10),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 16, bottom: 12),
          child: Text('DESIGN PATTERN', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: UIStyle.values.length,
            itemBuilder: (context, index) {
              final style = UIStyle.values[index];
              return Obx(() {
                final isSelected = uiController.currentStyle.value == style;
                return GestureDetector(
                  onTap: () => uiController.setStyle(style),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? Colors.white : Colors.white12),
                    ),
                    child: Center(
                      child: Icon(_getStyleIcon(style), color: Colors.white, size: 24),
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

  IconData _getStyleIcon(UIStyle style) {
    switch (style) {
      case UIStyle.industrialCorporate: return Iconsax.building_3;
      case UIStyle.softMinimalist: return Iconsax.ghost;
      case UIStyle.glassmorphism: return Iconsax.mirror;
      case UIStyle.neumorphism: return Iconsax.finger_scan;
      case UIStyle.material3: return Iconsax.shapes;
      case UIStyle.cupertinoPro: return Iconsax.mobile;
      case UIStyle.cyberpunkNeon: return Iconsax.flash;
      case UIStyle.brutalistBold: return Iconsax.maximize;
      case UIStyle.academicClassic: return Iconsax.teacher;
      case UIStyle.fluentLayered: return Iconsax.layer;
    }
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    Get.bottomSheet(
      _glassContainer(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('SELECT LANGUAGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              ...languageService.languages.map((lang) => ListTile(
                title: Text(lang['name'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                onTap: () {
                  languageService.changeLanguage(lang['code']);
                  Get.back();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showStorageDataDialog(BuildContext context) async {
    final storageService = Get.find<StorageService>();
    final cacheSize = await storageService.getCacheSize();
    Get.bottomSheet(
      _glassContainer(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('STORAGE MANAGEMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              _buildGlassItem('Clear Cache', Iconsax.trash, 
                trailing: Text('${cacheSize.toStringAsFixed(1)} MB', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                onTap: () { storageService.clearCache(); Get.back(); }
              ),
              _buildGlassItem('Hard Reset', Iconsax.warning_2, 
                onTap: () { storageService.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => _confirmSignOut(context),
        child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    Get.bottomSheet(
      _glassContainer(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ARE YOU SURE?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 16),
              const Text('Session will be terminated.', style: TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.logout(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.all(16)),
                  child: const Text('YES, SIGN OUT'),
                ),
              ),
              TextButton(onPressed: () => Get.back(), child: const Text('CANCEL', style: TextStyle(color: Colors.white70))),
            ],
          ),
        ),
      ),
    );
  }
}
