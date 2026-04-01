import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../app/theme/theme_controller.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/theme_configs.dart';
import '../../../../../common/ui_patterns/ui_style.dart';
import '../../../../../common/ui_patterns/ui_style_controller.dart';
import '../../../../../services/auth_service.dart';
import '../../../../../services/storage_service.dart';
import '../../../controllers/teacher_profile_controller.dart';
import '../../../../../services/language_service.dart';
import '../../teacher_profile/teacher_profile_screen.dart';

class SettingsFluent extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsFluent({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    const fluentBg = Color(0xFFF3F3F3);
    
    return Container(
      color: fluentBg,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          _buildFluentProfile(context),
          const SizedBox(height: 32),
          _buildFluentSection('PREFERENCES', [
            _buildFluentItem('Language', Iconsax.language_square, 
              trailing: Obx(() => Text(languageService.getCurrentLanguageName(), style: const TextStyle(color: Color(0xFF605E5C), fontSize: 13, fontWeight: FontWeight.w600))),
              onTap: () => _showLang(context)
            ),
            _buildFluentItem('Biometric Login', Iconsax.finger_scan, 
              trailing: Obx(() {
                final bio = Get.find<BiometricAuthService>();
                return bio.isAvailable.value 
                  ? Switch.adaptive(value: bio.isBiometricEnabled.value, onChanged: (v) => controller.toggleBiometric(v), activeColor: const Color(0xFF0078D4)) 
                  : const SizedBox.shrink();
              })
            ),
            _buildFluentItem('Email Alerts', Iconsax.notification, 
              trailing: Obx(() => Switch.adaptive(value: controller.emailNotifications.value, onChanged: (v) => controller.toggleEmailNotifications(v), activeColor: const Color(0xFF0078D4)))
            ),
          ]),
          const SizedBox(height: 24),
          _buildFluentSection('APPEARANCE', [
            _buildThemeSelector(context),
            _buildPatternSelector(context),
          ]),
          const SizedBox(height: 24),
          _buildFluentSection('DATA & ARCHIVE', [
            _buildFluentItem('Import Data', Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
            _buildFluentItem('Export History', Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
            _buildFluentItem('Clear Local Cache', Iconsax.cloud, onTap: () => _showStorage(context)),
          ]),
          const SizedBox(height: 48),
          _buildSignOut(context),
          const SizedBox(height: 40),
          const Center(child: Text('RELEASE 1.2.4', style: TextStyle(color: Color(0xFFA19F9D), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5))),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildFluentProfile(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(30)),
              child: const Icon(Iconsax.user, color: Color(0xFF0078D4), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Teacher', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF201F1E))),
                  Text(user?.email ?? 'teacher@campus.com', style: const TextStyle(color: Color(0xFF605E5C), fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Get.to(() => TeacherProfileScreen()),
              icon: const Icon(Iconsax.edit, color: Color(0xFF201F1E), size: 20),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFluentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFF605E5C), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildFluentItem(String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.02)))),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: const Color(0xFF201F1E), size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF201F1E))),
        trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 16, color: Color(0xFFA19F9D)),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final tc = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 16, top: 16, bottom: 8), child: Text('Color Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        SizedBox(
          height: 60,
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
                    width: 44, height: 44, margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(4), border: sel ? Border.all(color: Colors.black, width: 2) : Border.all(color: Colors.black.withValues(alpha: 0.1))),
                    child: sel ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
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
        const Divider(height: 1),
        const Padding(padding: EdgeInsets.only(left: 16, top: 16, bottom: 8), child: Text('Design Pattern', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        SizedBox(
          height: 90,
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
                    width: 80, margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: sel ? const Color(0xFF0078D4) : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIcon(style), color: sel ? Colors.white : const Color(0xFF201F1E), size: 24),
                        const SizedBox(height: 4),
                        Text(style.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 9, color: sel ? Colors.white : const Color(0xFF605E5C))),
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

  void _showLang(BuildContext context) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), color: Colors.white,
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Language Selection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 24),
        ...languageService.languages.map((l) => ListTile(
          onTap: () { languageService.changeLanguage(l['code']); Get.back(); },
          title: Text(l['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Iconsax.arrow_right_3, size: 14),
        )),
      ]),
    ));
  }

  void _showStorage(BuildContext context) async {
    final storage = Get.find<StorageService>();
    final size = await storage.getCacheSize();
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), color: Colors.white,
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Storage Maintenance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 24),
        _buildFluentItem('Clear Cache (${size.toStringAsFixed(1)}MB)', Iconsax.trash, onTap: () { storage.clearCache(); Get.back(); }),
        _buildFluentItem('Wipe All Storage', Iconsax.warning_2, onTap: () { storage.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }),
      ]),
    ));
  }

  Widget _buildSignOut(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _confirm(context),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078D4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(16)),
        child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
    );
  }

  void _confirm(BuildContext context) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(48), color: Colors.white,
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Sign out?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Text('Your attendance data is securely synced to the cloud.', style: TextStyle(color: Color(0xFF605E5C), fontSize: 13)),
        const SizedBox(height: 32),
        Row(children: [
          Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Color(0xFF201F1E))))),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton(onPressed: () => controller.logout(), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE81123), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text('Sign Out'))),
        ]),
      ]),
    ));
  }
}
