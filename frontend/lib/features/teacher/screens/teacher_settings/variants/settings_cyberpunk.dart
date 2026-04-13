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

class SettingsCyberpunk extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsCyberpunk({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF000814);
    const cyan = Color(0xFF00F5FF);
    const magenta = Color(0xFFFF00CC);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildGridOverlay(cyan),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            children: [
              _buildCyberProfile(context, cyan, magenta),
              const SizedBox(height: 48),
              _buildCyberSection('CORE_PREFERENCES', [
                _buildCyberItem('LANGUAGE_UPLINK', Iconsax.language_square, cyan, 
                  trailing: Obx(() => Text(languageService.getCurrentLanguageName().toUpperCase(), style: TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Courier'))),
                  onTap: () => _showLang(context, cyan, magenta)
                ),
                _buildCyberItem('BIOMETRIC_AUTH', Iconsax.finger_scan, cyan, 
                  trailing: Obx(() {
                    final bio = Get.find<BiometricAuthService>();
                    return bio.isAvailable.value 
                      ? _cyberToggle(cyan, bio.isBiometricEnabled.value, (v) => controller.toggleBiometric(v)) 
                      : const SizedBox.shrink();
                  })
                ),
                _buildCyberItem('NOTIFICATION_NODE', Iconsax.notification, cyan, 
                  trailing: Obx(() => _cyberToggle(cyan, controller.emailNotifications.value, (v) => controller.toggleEmailNotifications(v)))
                ),
              ], cyan),
              const SizedBox(height: 32),
              _buildCyberSection('VISUAL_ENGINE_architecture', [
                _buildThemeSelector(cyan),
                _buildPatternSelector(cyan),
              ], magenta),
              const SizedBox(height: 32),
              _buildCyberSection('SYSTEM_MAINTENANCE_LOGS', [
                _buildCyberItem('IMPORT_DATA_STREAM', Iconsax.import_1, cyan, onTap: () => Get.toNamed(AppRoutes.import)),
                _buildCyberItem('EXPORT_HISTORICAL_CACHE', Iconsax.export_3, cyan, onTap: () => Get.toNamed(AppRoutes.export)),
                _buildCyberItem('STORAGE_WIPE_PROTOCOLS', Iconsax.cloud, cyan, onTap: () => _showStorage(context, cyan, magenta)),
              ], cyan),
              const SizedBox(height: 64),
              _buildSignOut(context, cyan, magenta),
              const SizedBox(height: 48),
              Center(child: Text('VERSION_1.2.4_STABLE_UPLINK', style: TextStyle(color: cyan.withValues(alpha: 0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, fontFamily: 'Courier'))),
              const SizedBox(height: 64),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay(Color cyan) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter(color: cyan.withValues(alpha: 0.04))));
  }

  Widget _buildCyberProfile(BuildContext context, Color cyan, Color magenta) {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: cyan, width: 2),
          boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: -5)],
        ),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.black, border: Border.all(color: magenta, width: 2)),
              child: Stack(
                children: [
                  Center(child: Icon(Iconsax.user, color: cyan, size: 40)),
                  Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(4), color: magenta, child: const Icon(Iconsax.edit, color: Colors.black, size: 12))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(user?.name.toUpperCase() ?? 'IDENTIFIED_USER', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1, fontFamily: 'Courier')),
            Text(user?.email.toUpperCase() ?? 'UPLINK_PENDING', style: TextStyle(color: cyan.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Courier')),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Get.to(() => TeacherProfileScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(border: Border.all(color: cyan)),
                child: Text('MODIFY_IDENTITY_PROFILE', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, fontFamily: 'Courier')),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCyberSection(String title, List<Widget> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2, fontFamily: 'Courier')),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: accent.withValues(alpha: 0.3))),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildCyberItem(String title, IconData icon, Color cyan, {Widget? trailing, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: cyan, size: 20),
        title: Text(title, style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Courier')),
        trailing: trailing ?? Icon(Iconsax.arrow_right_3, size: 16, color: cyan.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _cyberToggle(Color cyan, bool val, ValueChanged<bool> on) {
    return GestureDetector(
      onTap: () => on(!val),
      child: Container(
        width: 50, height: 26,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.black, border: Border.all(color: cyan)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: val ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16, height: 16,
            color: val ? cyan : cyan.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(Color cyan) {
    final tc = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 20, top: 16, bottom: 12), child: Text('SCHEMA_UPLINK', style: TextStyle(color: cyan.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Courier'))),
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
                    width: 50, margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: theme.primary, border: Border.all(color: sel ? cyan : Colors.transparent, width: 2)),
                    child: sel ? const Icon(Icons.check, color: Colors.black, size: 20) : null,
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

  Widget _buildPatternSelector(Color cyan) {
    final uc = UIStyleController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white10),
        Padding(padding: const EdgeInsets.only(left: 20, top: 16, bottom: 12), child: Text('SYSTEM_ARCHITECTURE_MOD', style: TextStyle(color: cyan.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Courier'))),
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
                    width: 80, margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: sel ? cyan : Colors.black, border: Border.all(color: cyan)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIcon(style), color: sel ? Colors.black : cyan, size: 24),
                        const SizedBox(height: 8),
                        Text(style.label.substring(0, style.label.length > 5 ? 5 : style.label.length).toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: sel ? Colors.black : cyan, fontFamily: 'Courier')),
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

  void _showLang(BuildContext context, Color cyan, Color magenta) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), color: Colors.black,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('CHOOSE_LOCALE_PROTOCOL', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Courier')),
        const SizedBox(height: 32),
        ...languageService.languages.map((l) => GestureDetector(
          onTap: () { languageService.changeLanguage(l['code']); Get.back(); },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: cyan.withValues(alpha: 0.3))),
            child: Center(child: Text(l['name'].toString().toUpperCase(), style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Courier'))),
          ),
        )),
      ]),
    ));
  }

  void _showStorage(BuildContext context, Color cyan, Color magenta) async {
    final storage = Get.find<StorageService>();
    final size = await storage.getCacheSize();
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), color: Colors.black,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('STORAGE_CLEANUP_INIT', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Courier')),
        const SizedBox(height: 32),
        _buildCyberItem('FLUSH_CACHE (${size.toStringAsFixed(1)}MB)', Iconsax.trash, cyan, onTap: () { storage.clearCache(); Get.back(); }),
        _buildCyberItem('HARD_WIPE_ALL_REGISTRY', Iconsax.warning_2, magenta, onTap: () { storage.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }),
      ]),
    ));
  }

  Widget _buildSignOut(BuildContext context, Color cyan, Color magenta) {
    return GestureDetector(
      onTap: () => _confirm(context, cyan, magenta),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(border: Border.all(color: magenta, width: 2), color: magenta.withValues(alpha: 0.05)),
        child: Center(child: Text('TERMINATE_UPLINK_U01', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Courier'))),
      ),
    );
  }

  void _confirm(BuildContext context, Color cyan, Color magenta) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(48), color: Color(0xFF000814),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('TERMINATE?', style: TextStyle(color: magenta, fontWeight: FontWeight.w900, fontSize: 24, fontFamily: 'Courier')),
        const SizedBox(height: 16),
        Text('ARE YOU SURE YOU WANT TO TERMINATE ACCESS?', textAlign: TextAlign.center, style: TextStyle(color: cyan, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Courier')),
        const SizedBox(height: 48),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => Get.back(), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: cyan)), child: Center(child: Text('ABORT', style: TextStyle(color: cyan, fontWeight: FontWeight.w900, fontFamily: 'Courier')))))),
          const SizedBox(width: 24),
          Expanded(child: GestureDetector(onTap: () => controller.logout(), child: Container(padding: const EdgeInsets.all(16), color: magenta, child: Center(child: Text('EXECUTE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontFamily: 'Courier')))))),
        ]),
      ]),
    ));
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.0;
    const double step = 40.0;
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
