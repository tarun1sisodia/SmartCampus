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

class SettingsCorporate extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsCorporate({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          _buildCorporateProfile(context),
          const SizedBox(height: 48),
          _buildCorporateSection(context, 'PREFERENCES_UPLINK', [
             _buildMenuItem(context, 'LANGUAGE', Iconsax.language_square, trailing: Obx(() => Text(languageService.getCurrentLanguageName().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF0F172A)))), onTap: () => _showLang(context)),
             _buildMenuItem(context, 'BIOMETRIC_SCAN', Iconsax.finger_scan, trailing: Obx(() {
                final bio = Get.find<BiometricAuthService>();
                return bio.isAvailable.value ? _corpSwitch(bio.isBiometricEnabled.value, (v) => controller.toggleBiometric(v)) : const SizedBox();
             })),
             _buildMenuItem(context, 'NOTIFICATION_HOOKS', Iconsax.notification, trailing: Obx(() => _corpSwitch(controller.emailNotifications.value, (v) => controller.toggleEmailNotifications(v)))),
          ]),
          const SizedBox(height: 32),
          _buildCorporateSection(context, 'VISUAL_ARCHITECTURE', [
             _buildThemeSelector(context),
             _buildPatternSelector(context),
          ]),
          const SizedBox(height: 32),
          _buildCorporateSection(context, 'SYSTEM_MAINTENANCE', [
             _buildMenuItem(context, 'IMPORT_DATA_STREAM', Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
             _buildMenuItem(context, 'EXPORT_HISTORICAL_LOGS', Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
             _buildMenuItem(context, 'STORAGE_CLEANUP_SCRIPT', Iconsax.cloud, onTap: () => _showStorage(context)),
          ]),
          const SizedBox(height: 48),
          _buildSignOut(context),
          const SizedBox(height: 48),
          const Center(child: Text('VERSION_1.2.4_STABLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: Color(0xFF94A3B8)))),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildCorporateProfile(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 2.5), boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.1), offset: const Offset(4, 4))]),
        child: Row(
          children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), border: Border.all(color: const Color(0xFF0F172A), width: 1.5)), child: const Icon(Iconsax.user, size: 32, color: Color(0xFF0F172A))),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name.toUpperCase() ?? 'TEACHER_ROOT', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A), letterSpacing: 0.5)),
                  Text(user?.email ?? 'root@smartcampus.sys', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            IconButton(icon: const Icon(Iconsax.edit, color: Color(0xFF0F172A)), onPressed: () => Get.to(() => TeacherProfileScreen())),
          ],
        ),
      );
    });
  }

  Widget _buildCorporateSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: Color(0xFF64748B)))),
        Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: 1.5)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: const Color(0xFF0F172A), size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0F172A), letterSpacing: 0.5)),
        trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 16, color: Color(0xFF64748B)),
      ),
    );
  }

  Widget _corpSwitch(bool val, ValueChanged<bool> on) {
    return Switch.adaptive(value: val, onChanged: on, activeTrackColor: const Color(0xFF0F172A));
  }

  Widget _buildThemeSelector(BuildContext context) {
    final tc = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 20, top: 20, bottom: 12), child: Text('COLOR_SCHEMA_MOD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B)))),
        SizedBox(
          height: 100,
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
                      width: 80, margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(color: theme.background, border: Border.all(color: sel ? theme.primary : const Color(0xFFE2E8F0), width: sel ? 2.5 : 1)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                         Container(width: 16, height: 16, color: theme.primary),
                         const SizedBox(height: 8),
                         Text(theme.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: theme.textPrimary)),
                      ]),
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

  Widget _buildPatternSelector(BuildContext context) {
    final uc = UIStyleController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const Padding(padding: EdgeInsets.only(left: 20, top: 20, bottom: 12), child: Text('DESIGN_SYSTEM_ARCH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B)))),
        SizedBox(
          height: 120,
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
                      width: 120, margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(color: sel ? const Color(0xFF0F172A) : Colors.white, border: Border.all(color: const Color(0xFF0F172A), width: sel ? 2.5 : 1)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                         Icon(_getIcon(style), color: sel ? Colors.white : const Color(0xFF0F172A), size: 24),
                         const SizedBox(height: 8),
                         Text(style.label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: sel ? Colors.white : const Color(0xFF0F172A))),
                      ]),
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

  void _showLang(BuildContext context) {
    Get.bottomSheet(Container(
       padding: const EdgeInsets.all(32), color: Colors.white,
       child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('SYSTEM_LOCALE_MOD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 24),
          ...languageService.languages.map((l) => ListTile(title: Text(l['name'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)), onTap: () { languageService.changeLanguage(l['code']); Get.back(); })),
       ]),
    ));
  }

  void _showStorage(BuildContext context) async {
     final storage = Get.find<StorageService>();
     final size = await storage.getCacheSize();
     Get.dialog(AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Color(0xFF0F172A), width: 2.5)),
        title: const Text('STORAGE_MGMT_V1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
           ListTile(title: const Text('CLEAR_CACHE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)), subtitle: Text('${size.toStringAsFixed(2)}MB_FLUSH', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10)), onTap: () { storage.clearCache(); Get.back(); }),
           ListTile(title: const Text('HARD_RESET', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12)), subtitle: const Text('WIPE_ALL_DATA_STREAM', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 10)), onTap: () { storage.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }),
        ]),
     ));
  }

  Widget _buildSignOut(BuildContext context) {
    return SizedBox(width: double.infinity, height: 60, child: OutlinedButton(onPressed: () => _confirmSignOut(context), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red, width: 2), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)), child: const Text('TERMINATE_SESSION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5))));
  }

  void _confirmSignOut(BuildContext context) {
     Get.bottomSheet(Container(
        padding: const EdgeInsets.all(48), color: Colors.white,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
           const Icon(Iconsax.logout, size: 64, color: Colors.red),
           const SizedBox(height: 24),
           const Text('SESSION_TERMINATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
           const SizedBox(height: 32),
           Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: const Text('ABORT'))),
              const SizedBox(width: 16),
              Expanded(child: ElevatedButton(onPressed: () => controller.logout(), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('EXECUTE'))),
           ]),
        ]),
     ));
  }
}
