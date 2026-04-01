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

class SettingsMinimalist extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsMinimalist({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8F9FA);
    
    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        children: [
          _buildMinProfile(context),
          const SizedBox(height: 48),
          _buildMinGroup('PREFERENCES', [
             _buildItem('Language', Iconsax.language_square, trailing: Obx(() => Text(languageService.getCurrentLanguageName(), style: const TextStyle(fontSize: 12, color: Colors.black45))), onTap: () => _showLang(context)),
             _buildItem('Biometric Login', Iconsax.finger_scan, trailing: Obx(() {
                final bio = Get.find<BiometricAuthService>();
                return bio.isAvailable.value ? Switch.adaptive(value: bio.isBiometricEnabled.value, onChanged: (v) => controller.toggleBiometric(v), activeColor: Colors.black) : const SizedBox();
             })),
             _buildItem('Email Notifications', Iconsax.notification, trailing: Obx(() => Switch.adaptive(value: controller.emailNotifications.value, onChanged: (v) => controller.toggleEmailNotifications(v), activeColor: Colors.black))),
          ]),
          const SizedBox(height: 24),
          _buildMinGroup('APPEARANCE', [
             _buildTheme(context),
             _buildPattern(context),
          ]),
          const SizedBox(height: 24),
          _buildMinGroup('OPERATIONS', [
             _buildItem('Import Data', Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
             _buildItem('Export History', Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
             _buildItem('Storage Care', Iconsax.cloud, onTap: () => _showStorage(context)),
          ]),
          const SizedBox(height: 48),
          _buildSignOut(context),
          const SizedBox(height: 48),
          const Center(child: Text('VERSION 1.2.4', style: TextStyle(fontSize: 10, letterSpacing: 0.5, color: Colors.black12, fontWeight: FontWeight.bold))),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildMinProfile(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          CircleAvatar(radius: 36, backgroundColor: Colors.white, child: const Icon(Iconsax.user, color: Colors.black26, size: 32)),
          const SizedBox(height: 16),
          Text(user?.name ?? 'Teacher', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(user?.email ?? 'teacher@campus.com', style: const TextStyle(fontSize: 12, color: Colors.black38)),
          const SizedBox(height: 16),
          TextButton(onPressed: () => Get.to(() => TeacherProfileScreen()), child: const Text('Edit Identity', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      );
    });
  }

  Widget _buildMinGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black26))),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildItem(String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: Colors.black, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.black12),
    );
  }

  Widget _buildTheme(BuildContext context) {
    final tc = ThemeController.instance;
    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          const Padding(padding: EdgeInsets.only(left: 20, top: 16, bottom: 8), child: Text('Color Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(height: 60, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: AppThemes.themes.length, itemBuilder: (context, index) {
             final theme = AppThemes.themes[index];
             return Obx(() {
                final sel = tc.currentThemeIndex.value == index;
                return GestureDetector(onTap: () => tc.setTheme(index), child: Container(width: 44, height: 44, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: theme.primary, shape: BoxShape.circle, border: Border.all(color: sel ? Colors.black : Colors.transparent, width: 2.5))));
             });
          })),
          const SizedBox(height: 12),
       ],
    );
  }

  Widget _buildPattern(BuildContext context) {
    final uc = UIStyleController.instance;
    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          const Divider(height: 1),
          const Padding(padding: EdgeInsets.only(left: 20, top: 16, bottom: 8), child: Text('Design Pattern', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: UIStyle.values.length, itemBuilder: (context, index) {
             final style = UIStyle.values[index];
             return Obx(() {
                final sel = uc.currentStyle.value == style;
                return GestureDetector(onTap: () => uc.setStyle(style), child: Container(width: 80, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: sel ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? Colors.black : Colors.black12)), child: Center(child: Icon(_getIcon(style), color: sel ? Colors.white : Colors.black, size: 20))));
             });
          })),
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
    Get.bottomSheet(Container(padding: const EdgeInsets.all(32), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: Column(mainAxisSize: MainAxisSize.min, children: [
       const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
       const SizedBox(height: 24),
       ...languageService.languages.map((l) => ListTile(title: Text(l['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)), onTap: () { languageService.changeLanguage(l['code']); Get.back(); })),
    ])));
  }

  void _showStorage(BuildContext context) async {
     final storage = Get.find<StorageService>();
     final size = await storage.getCacheSize();
     Get.bottomSheet(Container(padding: const EdgeInsets.all(32), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Storage Maintenance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 24),
        _buildItem('Clear Cache', Iconsax.trash, trailing: Text('${size.toStringAsFixed(1)} MB', style: const TextStyle(fontSize: 11, color: Colors.black26)), onTap: () { storage.clearCache(); Get.back(); }),
        _buildItem('Wipe All Data', Iconsax.warning_2, onTap: () { storage.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }),
     ])));
  }

  Widget _buildSignOut(BuildContext context) {
    return Center(child: TextButton(onPressed: () => _confirm(context), child: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))));
  }

  void _confirm(BuildContext context) {
     Get.bottomSheet(Container(padding: const EdgeInsets.all(48), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        const Text('Logging out will end your session.', style: TextStyle(color: Colors.black38, fontSize: 13)),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => controller.logout(), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(16)), child: const Text('Yes, Sign Out'))),
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.black))),
     ])));
  }
}
