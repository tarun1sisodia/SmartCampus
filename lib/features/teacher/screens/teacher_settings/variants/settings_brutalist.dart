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

class SettingsBrutalist extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsBrutalist({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFE14D);
    const orange = Color(0xFFFF8C42);
    const blue = Color(0xFF4D91FF);

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildBrutalProfile(yellow, orange),
          const SizedBox(height: 48),
          _buildBrutalSection('PREFERENCES_01', [
            _buildBrutalItem('LANGUAGE_SELECT', Iconsax.language_square, onTap: () => _showLang(context, yellow)),
            _buildBrutalItem('BIOMETRIC_LOCK', Iconsax.finger_scan, 
              trailing: Obx(() {
                final bio = Get.find<BiometricAuthService>();
                return bio.isAvailable.value 
                  ? _brutalSwitch(bio.isBiometricEnabled.value, (v) => controller.toggleBiometric(v)) 
                  : const SizedBox.shrink();
              })
            ),
            _buildBrutalItem('ALERT_SYSTEM', Iconsax.notification, 
              trailing: Obx(() => _brutalSwitch(controller.emailNotifications.value, (v) => controller.toggleEmailNotifications(v)))
            ),
          ], blue),
          const SizedBox(height: 32),
          _buildBrutalSection('STYLE_ENGINE', [
            _buildThemeSelector(),
            _buildPatternSelector(),
          ], yellow),
          const SizedBox(height: 32),
          _buildBrutalSection('CORE_MAINTENANCE', [
            _buildBrutalItem('IMPORT_UPLINK', Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
            _buildBrutalItem('EXPORT_VAULT', Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
            _buildBrutalItem('STORAGE_WIPE', Iconsax.cloud, onTap: () => _showStorage(context, orange)),
          ], orange),
          const SizedBox(height: 64),
          _buildSignOut(context, orange),
          const SizedBox(height: 48),
          const Center(child: Text('VERSION_1.2.4_BOLD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2))),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildBrutalProfile(Color yellow, Color orange) {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: yellow, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))]),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
              child: const Icon(Iconsax.user, color: Colors.black, size: 40),
            ),
            const SizedBox(height: 24),
            Text(user?.name.toUpperCase() ?? 'TEACHER_ROOT', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1)),
            Text(user?.email.toUpperCase() ?? 'ADMIN@SMARTCAMPUS', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.black54)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Get.to(() => TeacherProfileScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
                child: const Text('EDIT_REGISTRY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBrutalSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: accent, offset: const Offset(6, 6))]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildBrutalItem(String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1))),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: Colors.black, size: 24),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.black),
      ),
    );
  }

  Widget _brutalSwitch(bool val, ValueChanged<bool> on) {
    return GestureDetector(
      onTap: () => on(!val),
      child: Container(
        width: 60, height: 32,
        decoration: BoxDecoration(color: val ? Colors.green : Colors.white, border: Border.all(color: Colors.black, width: 2.5), boxShadow: val ? null : const [BoxShadow(color: Colors.black, offset: Offset(2, 2))]),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: val ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 24, height: 24, color: Colors.black, margin: const EdgeInsets.all(2)),
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final tc = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 20, top: 20, bottom: 12), child: Text('COLOR_VAULT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
        SizedBox(
          height: 80,
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
                    width: 50, margin: const EdgeInsets.only(right: 16, bottom: 8),
                    decoration: BoxDecoration(color: theme.primary, border: Border.all(color: Colors.black, width: 3), boxShadow: sel ? null : const [BoxShadow(color: Colors.black, offset: Offset(3, 3))]),
                    child: sel ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
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

  Widget _buildPatternSelector() {
    final uc = UIStyleController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Colors.black),
        const Padding(padding: EdgeInsets.only(left: 20, top: 20, bottom: 12), child: Text('UI_ARCHITECTURE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
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
                    width: 100, margin: const EdgeInsets.only(right: 16, bottom: 12),
                    decoration: BoxDecoration(color: sel ? Colors.black : Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: sel ? null : const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIcon(style), color: sel ? Colors.white : Colors.black, size: 28),
                        const SizedBox(height: 4),
                        Text(style.label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: sel ? Colors.white : Colors.black)),
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

  void _showLang(BuildContext context, Color yellow) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), color: Colors.white,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 4))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('LOCALE_MODERNIZER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 32),
        ...languageService.languages.map((l) => GestureDetector(
          onTap: () { languageService.changeLanguage(l['code']); Get.back(); },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: yellow, border: Border.all(color: Colors.black, width: 2), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
            child: Center(child: Text(l['name'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900))),
          ),
        )),
      ]),
    ));
  }

  void _showStorage(BuildContext context, Color orange) async {
    final storage = Get.find<StorageService>();
    final size = await storage.getCacheSize();
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), color: Colors.white,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 4))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('STORAGE_PURGE_PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 32),
        _buildBrutalItem('FLUSH_CACHE (${size.toStringAsFixed(1)}MB)', Iconsax.trash, onTap: () { storage.clearCache(); Get.back(); }),
        _buildBrutalItem('WIPE_VAULT_01', Iconsax.warning_2, onTap: () { storage.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }),
      ]),
    ));
  }

  Widget _buildSignOut(BuildContext context, Color orange) {
    return GestureDetector(
      onTap: () => _confirm(context),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.redAccent, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))]),
        child: const Center(child: Text('TERMINATE_UPLINK_01', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2))),
      ),
    );
  }

  void _confirm(BuildContext context) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(48), color: Colors.white,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 4))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('DISCONNECT?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        const SizedBox(height: 16),
        const Text('ARE YOU SURE YOU WANT TO DISCONNECT FROM THE GRID?', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black54)),
        const SizedBox(height: 48),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => Get.back(), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]), child: const Center(child: Text('STAY', style: TextStyle(fontWeight: FontWeight.w900)))))),
          const SizedBox(width: 24),
          Expanded(child: GestureDetector(onTap: () => controller.logout(), child: Container(padding: const EdgeInsets.all(16), color: Colors.black, child: const Center(child: Text('EXIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))))),
        ]),
      ]),
    ));
  }
}
