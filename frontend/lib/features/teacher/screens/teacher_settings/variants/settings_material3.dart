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

class SettingsMaterial3 extends StatelessWidget {
  final TeacherProfileController controller;
  final LanguageService languageService;

  const SettingsMaterial3({super.key, required this.controller, required this.languageService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildM3Profile(theme),
          const SizedBox(height: 32),
          _buildM3Section(theme, 'Preferences', [
            _buildM3Item(theme, 'Language', Iconsax.language_square, 
              trailing: Obx(() => Text(languageService.getCurrentLanguageName(), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary))),
              onTap: () => _showLang(context, theme)
            ),
            _buildM3Item(theme, 'Biometric Login', Iconsax.finger_scan, 
              trailing: Obx(() {
                final bio = Get.find<BiometricAuthService>();
                return bio.isAvailable.value 
                  ? Switch(value: bio.isBiometricEnabled.value, onChanged: (v) => controller.toggleBiometric(v)) 
                  : const SizedBox.shrink();
              })
            ),
            _buildM3Item(theme, 'Notifications', Iconsax.notification, 
              trailing: Obx(() => Switch(value: controller.emailNotifications.value, onChanged: (v) => controller.toggleEmailNotifications(v)))
            ),
          ]),
          const SizedBox(height: 24),
          _buildM3Section(theme, 'Appearance', [
            _buildThemeSelector(theme),
            _buildPatternSelector(theme),
          ]),
          const SizedBox(height: 24),
          _buildM3Section(theme, 'Data & Tools', [
            _buildM3Item(theme, 'Import Data', Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
            _buildM3Item(theme, 'Export Records', Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
            _buildM3Item(theme, 'Clear Storage', Iconsax.cloud, onTap: () => _showStorage(context, theme)),
          ]),
          const SizedBox(height: 48),
          _buildSignOut(context, theme),
          const SizedBox(height: 48),
          Center(child: Text('VERSION 1.2.4', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1))),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildM3Profile(ThemeData theme) {
    return Obx(() {
      final user = controller.user.value;
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(Iconsax.user, color: theme.colorScheme.onPrimaryContainer, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Teacher', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(user?.email ?? 'teacher@campus.com', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Iconsax.edit),
                onPressed: () => Get.to(() => TeacherProfileScreen()),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildM3Section(ThemeData theme, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildM3Item(ThemeData theme, String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing ?? Icon(Iconsax.arrow_right_3, size: 16, color: theme.colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildThemeSelector(ThemeData theme) {
    final tc = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 20, top: 16, bottom: 12), child: Text('Color Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppThemes.themes.length,
            itemBuilder: (context, index) {
              final appTheme = AppThemes.themes[index];
              return Obx(() {
                final sel = tc.currentThemeIndex.value == index;
                return GestureDetector(
                  onTap: () => tc.setTheme(index),
                  child: Container(
                    width: 56, height: 56, margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: appTheme.primary,
                      shape: BoxShape.circle,
                      border: sel ? Border.all(color: theme.colorScheme.primary, width: 3) : null,
                    ),
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

  Widget _buildPatternSelector(ThemeData theme) {
    final uc = UIStyleController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const Padding(padding: EdgeInsets.only(left: 20, top: 16, bottom: 12), child: Text('Design Pattern', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        SizedBox(
          height: 110,
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
                    width: 100, margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: sel ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIcon(style), color: sel ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant, size: 28),
                        const SizedBox(height: 8),
                        Text(style.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: sel ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant)),
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

  void _showLang(BuildContext context, ThemeData theme) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Select Language', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ...languageService.languages.map((l) => ListTile(
          onTap: () { languageService.changeLanguage(l['code']); Get.back(); },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Iconsax.arrow_right_3, size: 16),
        )),
      ]),
    ));
  }

  void _showStorage(BuildContext context, ThemeData theme) async {
    final storage = Get.find<StorageService>();
    final size = await storage.getCacheSize();
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Storage Management', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildM3Item(theme, 'Clear Cache', Iconsax.trash, trailing: Text('${size.toStringAsFixed(1)} MB', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)), onTap: () { storage.clearCache(); Get.back(); }),
        _buildM3Item(theme, 'Hard Reset', Iconsax.warning_2, onTap: () { storage.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding)); }),
      ]),
    ));
  }

  Widget _buildSignOut(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirm(context, theme),
        icon: const Icon(Iconsax.logout),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(color: theme.colorScheme.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _confirm(BuildContext context, ThemeData theme) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Iconsax.logout, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 24),
        Text('Are you sure?', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Your session will be ended securely.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 32),
        Row(children: [
          Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text('Cancel'))),
          const SizedBox(width: 16),
          Expanded(child: FilledButton(onPressed: () => controller.logout(), style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error), child: const Text('Yes, Sign Out'))),
        ]),
      ]),
    ));
  }
}
