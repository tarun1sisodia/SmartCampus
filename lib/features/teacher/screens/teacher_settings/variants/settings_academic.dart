import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/theme_configs.dart';
import '../../../../../app/theme/theme_controller.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../common/ui_patterns/ui_style_controller.dart';
import '../../../../../services/auth_service.dart';
import '../../../../../services/storage_service.dart';
import '../../../controllers/teacher_profile_controller.dart';
import '../../../../../services/language_service.dart';
import '../../teacher_profile/teacher_profile_screen.dart';

class SettingsAcademic extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsAcademic({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    const paperColor = Color(0xFFFAF7F0);
    const inkColor = Color(0xFF2D2E32);
    const accentColor = Color(0xFF8B4513); // Saddle Brown

    return Container(
      color: paperColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        children: [
          _buildScholarProfile(accentColor, inkColor),
          const SizedBox(height: 48),
          _buildScholarSection('ACADEMIC_PREFERENCES', [
            _buildScholarItem('Lexical Selection', Iconsax.language_square, inkColor, 
              trailing: Obx(() => Text(languageService.getCurrentLanguageName().toUpperCase(), style: TextStyle(color: inkColor.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Serif'))),
              onTap: () => _showLang(context, accentColor, inkColor)
            ),
            _buildScholarItem('Biometric Credentials', Iconsax.finger_scan, inkColor, 
              trailing: Obx(() {
                final bio = Get.find<BiometricAuthService>();
                return bio.isAvailable.value 
                  ? Switch.adaptive(value: bio.isBiometricEnabled.value, onChanged: (v) => controller.toggleBiometric(v), activeColor: accentColor) 
                  : const SizedBox.shrink();
              })
            ),
            _buildScholarItem('Notification Dispatch', Iconsax.notification, inkColor, 
              trailing: Obx(() => Switch.adaptive(value: controller.emailNotifications.value, onChanged: (v) => controller.toggleEmailNotifications(v), activeColor: accentColor))
            ),
          ], accentColor, inkColor),
          const SizedBox(height: 32),
          _buildScholarSection('VISUAL_PEDAGOGY', [
            _buildThemeSelector(accentColor, inkColor),
            _buildPatternSelector(accentColor, inkColor),
          ], accentColor, inkColor),
          const SizedBox(height: 32),
          _buildScholarSection('ARCHIVAL_TOOLS', [
            _buildScholarItem('Import Data Ledger', Iconsax.import_1, inkColor, onTap: () => Get.toNamed(AppRoutes.import)),
            _buildScholarItem('Export Faculty Logs', Iconsax.export_3, inkColor, onTap: () => Get.toNamed(AppRoutes.export)),
            _buildScholarItem('Repository Maintenance', Iconsax.cloud, inkColor, onTap: () => _showStorage(context, accentColor, inkColor)),
          ], accentColor, inkColor),
          const SizedBox(height: 64),
          _buildSignOut(context, accentColor, inkColor),
          const SizedBox(height: 64),
          const Center(child: Text('EDITION 1.2.4', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif'))),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildScholarProfile(Color accent, Color ink) {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: accent.withValues(alpha: 0.4))),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(decoration: BoxDecoration(border: Border.all(color: accent.withValues(alpha: 0.1))), child: const Icon(Iconsax.user, color: Colors.black26, size: 40)),
            ),
          ),
          const SizedBox(height: 24),
          Text(user?.name ?? 'Distinguished Faculty', style: TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 20, fontFamily: 'Serif')),
          Text(user?.email ?? 'faculty@smartcampus.edu', style: TextStyle(color: ink.withValues(alpha: 0.5), fontSize: 12, fontStyle: FontStyle.italic, fontFamily: 'Serif')),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.to(() => TeacherProfileScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(border: Border.all(color: ink.withValues(alpha: 0.2))),
              child: Text('Amend Credentials', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Serif')),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildScholarSection(String title, List<Widget> items, Color accent, Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: accent.withValues(alpha: 0.6), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, fontFamily: 'Serif')),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: ink.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildScholarItem(String title, IconData icon, Color ink, {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ink.withValues(alpha: 0.01)))),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: ink.withValues(alpha: 0.6), size: 20),
        title: Text(title, style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Serif')),
        trailing: trailing ?? Icon(Iconsax.arrow_right_3, size: 16, color: ink.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _buildThemeSelector(Color accent, Color ink) {
    final tc = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 20, top: 20, bottom: 12), child: Text('Illumination Palette', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ink.withValues(alpha: 0.8), fontFamily: 'Serif'))),
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
                    decoration: BoxDecoration(color: theme.primary, border: Border.all(color: sel ? accent : Colors.transparent, width: 2)),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.2)))),
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

  Widget _buildPatternSelector(Color accent, Color ink) {
    final uc = UIStyleController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Padding(padding: const EdgeInsets.only(left: 20, top: 16, bottom: 12), child: Text('Curricular Design Architecture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ink.withValues(alpha: 0.8), fontFamily: 'Serif'))),
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
                    decoration: BoxDecoration(color: sel ? ink : Colors.white, border: Border.all(color: ink.withValues(alpha: 0.1))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIcon(style), color: sel ? Colors.white : ink.withValues(alpha: 0.4), size: 24),
                        const SizedBox(height: 8),
                        Text(style.label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: sel ? Colors.white : ink.withValues(alpha: 0.4), fontFamily: 'Serif')),
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

  void _showLang(BuildContext context, Color accent, Color ink) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), color: Colors.white,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: accent, width: 2))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Lexical Archive', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Serif')),
        const SizedBox(height: 32),
        ...languageService.languages.map((l) => ListTile(
          onTap: () { languageService.changeLanguage(l['code']); Get.back(); },
          title: Text(l['name'].toString().toUpperCase(), style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Serif')),
          trailing: Icon(Iconsax.arrow_right_3, size: 14, color: ink.withValues(alpha: 0.2)),
        )),
      ]),
    ));
  }

  void _showStorage(BuildContext context, Color accent, Color ink) async {
    final storage = Get.find<StorageService>();
    final size = await storage.getCacheSize();
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), color: Colors.white,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: accent, width: 2))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Repository Maintenance', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Serif')),
        const SizedBox(height: 32),
        _buildScholarItem('Purge Temporary Files (${size.toStringAsFixed(1)}MB)', Iconsax.trash, ink, onTap: () { storage.clearCache(); Get.back(); }),
        _buildScholarItem('Permanent Archival Wipe', Iconsax.warning_2, ink, onTap: () { storage.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }),
      ]),
    ));
  }

  Widget _buildSignOut(BuildContext context, Color accent, Color ink) {
    return Center(
      child: TextButton(
        onPressed: () => _confirm(context, accent, ink),
        child: Text('Resign Session Access', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.underline, fontFamily: 'Serif')),
      ),
    );
  }

  void _confirm(BuildContext context, Color accent, Color ink) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(48), color: Colors.white,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: accent, width: 2))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Confirm Resignation', style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Serif')),
        const SizedBox(height: 16),
        Text('Are you certain you wish to terminate the current session access?', textAlign: TextAlign.center, style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 14, fontFamily: 'Serif')),
        const SizedBox(height: 48),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => controller.logout(), style: ElevatedButton.styleFrom(backgroundColor: ink, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), padding: const EdgeInsets.all(16)), child: const Text('DISCONNECT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Serif')))),
        TextButton(onPressed: () => Get.back(), child: Text('REMAIN', style: TextStyle(color: ink.withValues(alpha: 0.4), fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Serif'))),
      ]),
    ));
  }
}
