import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
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

class SettingsNeumorphism extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsNeumorphism({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE0E5EC);
    
    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          _buildNeuProfile(bgColor),
          const SizedBox(height: 48),
          _buildNeuSection(bgColor, 'PREFERENCES_LINK', [
            _buildNeuItem(bgColor, 'Language', Iconsax.language_square, 
              trailing: Obx(() => Text(languageService.getCurrentLanguageName(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF4D565F)))),
              onTap: () => _showLang(context, bgColor)
            ),
            _buildNeuItem(bgColor, 'Biometric Scan', Iconsax.finger_scan, 
              trailing: Obx(() {
                final bio = Get.find<BiometricAuthService>();
                return bio.isAvailable.value 
                  ? _neuToggle(bgColor, bio.isBiometricEnabled.value, (v) => controller.toggleBiometric(v)) 
                  : const SizedBox.shrink();
              })
            ),
            _buildNeuItem(bgColor, 'Notifications', Iconsax.notification, 
              trailing: Obx(() => _neuToggle(bgColor, controller.emailNotifications.value, (v) => controller.toggleEmailNotifications(v)))
            ),
          ]),
          const SizedBox(height: 32),
          _buildNeuSection(bgColor, 'VISUAL_ENGINE', [
            _buildThemeSelector(bgColor),
            _buildPatternSelector(bgColor),
          ]),
          const SizedBox(height: 32),
          _buildNeuSection(bgColor, 'CORE_REGISTRY', [
            _buildNeuItem(bgColor, 'Import Data Stream', Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
            _buildNeuItem(bgColor, 'Export Logs', Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
            _buildNeuItem(bgColor, 'Storage Maintenance', Iconsax.cloud, onTap: () => _showStorage(context, bgColor)),
          ]),
          const SizedBox(height: 48),
          _buildSignOut(context, bgColor),
          const SizedBox(height: 48),
          const Center(child: Text('VERSION_1.2.4_STABLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 2))),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildNeuProfile(Color bg) {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.white, offset: const Offset(-8, -8), blurRadius: 16),
                BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(8, 8), blurRadius: 16),
              ],
            ),
            child: const Icon(Iconsax.user, color: Color(0xFFA3B1C6), size: 32),
          ),
          const SizedBox(height: 24),
          Text(user?.name.toUpperCase() ?? 'TEACHER_ID', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF4D565F))),
          Text(user?.email ?? 'root@campus.sys', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFFA3B1C6))),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Get.to(() => TeacherProfileScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8),
                  BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8),
                ],
              ),
              child: const Text('EDIT_IDENTITY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF4D565F))),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNeuSection(Color bg, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA3B1C6), letterSpacing: 1.5)),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.white, offset: const Offset(-8, -8), blurRadius: 16),
              BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(8, 8), blurRadius: 16),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildNeuItem(Color bg, String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF4D565F), size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF4D565F))),
      trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 14, color: Color(0xFFA3B1C6)),
    );
  }

  Widget _neuToggle(Color bg, bool val, ValueChanged<bool> on) {
    return GestureDetector(
      onTap: () => on(!val),
      child: Container(
        width: 48, height: 24,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
            BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(2, 2), blurRadius: 4, inset: true),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: val ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: val ? const Color(0xFF6D5DFC) : const Color(0xFFA3B1C6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.white.withOpacity(0.5), offset: const Offset(-1, -1), blurRadius: 2),
                BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(1, 1), blurRadius: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(Color bg) {
    final tc = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 16, top: 16, bottom: 12), child: Text('COLOR_SCHEMA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFA3B1C6)))),
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
                    width: 44, height: 44, margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                      boxShadow: sel ? [
                        BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4, inset: true),
                        BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(2, 2), blurRadius: 4, inset: true),
                      ] : [
                        BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8),
                        BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8),
                      ],
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

  Widget _buildPatternSelector(Color bg) {
    final uc = UIStyleController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Colors.white30),
        const Padding(padding: EdgeInsets.only(left: 16, top: 20, bottom: 12), child: Text('DESIGN_SYSTEM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFA3B1C6)))),
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
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: sel ? [
                        BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8, inset: true),
                        BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8, inset: true),
                      ] : [
                        BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8),
                        BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8),
                      ],
                    ),
                    child: Center(
                      child: Icon(_getIcon(style), color: sel ? const Color(0xFF6D5DFC) : const Color(0xFF4D565F), size: 24),
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

  void _showLang(BuildContext context, Color bg) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('SELECT_LOCALE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF4D565F))),
        const SizedBox(height: 32),
        ...languageService.languages.map((l) => GestureDetector(
          onTap: () { languageService.changeLanguage(l['code']); Get.back(); },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8)]),
            child: Center(child: Text(l['name'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF4D565F)))),
          ),
        )),
      ]),
    ));
  }

  void _showStorage(BuildContext context, Color bg) async {
    final storage = Get.find<StorageService>();
    final size = await storage.getCacheSize();
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('STORAGE_MGMT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF4D565F))),
        const SizedBox(height: 32),
        _buildNeuItem(bg, 'CLEAR_CACHE', Iconsax.trash, trailing: Text('${size.toStringAsFixed(1)}MB', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFFA3B1C6))), onTap: () { storage.clearCache(); Get.back(); }),
        const SizedBox(height: 16),
        _buildNeuItem(bg, 'HARD_RESET', Iconsax.warning_2, onTap: () { storage.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }),
      ]),
    ));
  }

  Widget _buildSignOut(BuildContext context, Color bg) {
    return GestureDetector(
      onTap: () => _confirm(context, bg),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: const Offset(-8, -8), blurRadius: 16),
            BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(8, 8), blurRadius: 16),
          ],
        ),
        child: const Center(child: Text('TERMINATE_SESSION', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent, letterSpacing: 1))),
      ),
    );
  }

  void _confirm(BuildContext context, Color bg) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(48), decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Iconsax.logout, size: 48, color: Colors.redAccent),
        const SizedBox(height: 24),
        const Text('LOGOUT_CONFIRM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF4D565F))),
        const SizedBox(height: 32),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => Get.back(), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8)]), child: const Center(child: Text('ABORT', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4D565F))))))),
          const SizedBox(width: 24),
          Expanded(child: GestureDetector(onTap: () => controller.logout(), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.white, offset: const Offset(-4, -4), blurRadius: 8, inset: true), BoxShadow(color: const Color(0xFFA3B1C6), offset: const Offset(4, 4), blurRadius: 8, inset: true)]), child: const Center(child: Text('EXECUTE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent)))))),
        ]),
      ]),
    ));
  }
}
