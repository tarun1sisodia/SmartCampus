import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/theme_configs.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../common/widgets/sharp_toggle.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../controllers/teacher_profile_controller.dart';
import '/../services/language_service.dart';
import 'teacher_profile_screen.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherProfileController());
    final languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: TColors.slate50,
      appBar: AppBar(
        title: Text('SETTINGS', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            _buildProfileCard(context, controller),
            const SizedBox(height: 32),
            
            _buildSection(
              context: context,
              title: 'PREFERENCES',
              items: [
                _buildProfileMenuItem(
                  context: context,
                  title: 'Language',
                  icon: Iconsax.language_square,
                  trailing: Obx(() => Text(
                    languageService.getCurrentLanguageName().toUpperCase(), 
                    style: const TextStyle(color: TColors.executiveNavy, fontWeight: FontWeight.w900, fontSize: 12)
                  )),
                  onTap: () => _showLanguageSelectionDialog(context, languageService),
                ),
                _buildProfileMenuItem(
                  context: context,
                  title: 'Biometric Login',
                  icon: Iconsax.finger_scan,
                  trailing: Obx(() {
                    final biometricService = Get.find<BiometricAuthService>();
                    if (!biometricService.isAvailable.value) return const SizedBox.shrink();
                    return SharpToggle(
                      value: biometricService.isBiometricEnabled.value,
                      onChanged: (value) => controller.toggleBiometric(value),
                    );
                  }),
                ),
                _buildProfileMenuItem(
                  context: context,
                  title: 'Email Alerts',
                  icon: Iconsax.notification,
                  trailing: Obx(() => SharpToggle(
                    value: controller.emailNotifications.value,
                    onChanged: controller.toggleEmailNotifications,
                  )),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildSection(
              context: context,
              title: 'APPEARANCE',
              items: [_buildThemeSelector(context)],
            ),
            
            const SizedBox(height: 16),
            _buildSection(
              context: context,
              title: 'DATA & MAINTENANCE',
              items: [
                _buildProfileMenuItem(context: context, title: 'Import Data', icon: Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
                _buildProfileMenuItem(context: context, title: 'Export History', icon: Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
                _buildProfileMenuItem(context: context, title: 'Storage Management', icon: Iconsax.cloud, onTap: () => _showStorageDataDialog(context)),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildSection(
              context: context,
              title: 'SUPPORT',
              items: [
                _buildProfileMenuItem(context: context, title: 'Help Center', icon: Iconsax.support, onTap: () => Get.toNamed(AppRoutes.help)),
                _buildProfileMenuItem(context: context, title: 'Privacy & Security', icon: Iconsax.security_safe, onTap: () => Get.toNamed(AppRoutes.privacyPolicy)),
                _buildProfileMenuItem(context: context, title: 'App Feedback', icon: Iconsax.message_question, onTap: () => Get.toNamed(AppRoutes.feedback)),
              ],
            ),
            
            const SizedBox(height: 48),
            _buildSignOutButton(context, controller),
            
            const SizedBox(height: 32),
            Text(
              'VERSION 1.2.4 (BUILD 1205)', 
              style: TextStyle(color: TColors.slate600, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, TeacherProfileController controller) {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: TColors.slate400, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: TColors.blue100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: TColors.executiveNavy, width: 1.5),
              ),
              child: const Icon(Iconsax.user, size: 32, color: TColors.executiveNavy),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (user?.name ?? 'TEACHER NAME').toUpperCase(), 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5, color: TColors.slate900)
                  ),
                  Text(
                    user?.email ?? 'email@campus.com', 
                    style: const TextStyle(color: TColors.slate600, fontSize: 12, fontWeight: FontWeight.w600)
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Get.to(() => TeacherProfileScreen()), 
              icon: const Icon(Iconsax.edit, size: 24, color: TColors.slate900)
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSection({required BuildContext context, required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12), 
          child: Text(
            title.toUpperCase(), 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: TColors.slate600)
          )
        ),
        Container(
          decoration: BoxDecoration(
            color: TColors.white, 
            borderRadius: BorderRadius.circular(4), 
            border: Border.all(color: TColors.slate400, width: 1.5)
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeController = ThemeController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 12), 
          child: Text('INTERFACE THEME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5))
        ),
        SizedBox(
          height: 140,
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
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? theme.primary : TColors.slate400, 
                        width: isSelected ? 2.5 : 1.5
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            _buildColorCircle(theme.primary), 
                            const SizedBox(width: 4), 
                            _buildColorCircle(theme.accent)
                          ]
                        ),
                        const SizedBox(height: 12),
                        Text(
                          theme.name.toUpperCase(), 
                          style: TextStyle(
                            color: theme.textPrimary, 
                            fontSize: 10, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5
                          )
                        ),
                        if (isSelected) Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(Icons.check_box, color: theme.primary, size: 16),
                        ),
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

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 20, 
      height: 20, 
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(4), 
        border: Border.all(color: Colors.white, width: 1.5)
      )
    );
  }

  Widget _buildProfileMenuItem({required BuildContext context, required String title, required IconData icon, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: TColors.slate200, width: 1.0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: TColors.executiveNavy, size: 24),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: TColors.slate900)
        ),
        trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 18, color: TColors.slate600),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, TeacherProfileController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => _confirmSignOut(context, controller),
        icon: const Icon(Iconsax.logout, size: 20),
        label: const Text('SIGN OUT'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE11D48),
          side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, TeacherProfileController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: TColors.white, 
          borderRadius: BorderRadius.zero,
          border: Border(top: BorderSide(color: TColors.executiveNavy, width: 3.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.logout, size: 48, color: Color(0xFFE11D48)),
            const SizedBox(height: 16),
            const Text(
              'SIGN OUT?', 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)
            ),
            const SizedBox(height: 8),
            const Text(
              'ARE YOU SURE YOU WANT TO EXIT? ATTENDANCE DATA IS SAFE.', 
              textAlign: TextAlign.center,
              style: TextStyle(color: TColors.slate600, fontWeight: FontWeight.w700, fontSize: 12)
            ),
            const SizedBox(height: 32),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(), 
                  child: const Text('STAY')
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.logout(), 
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)), 
                  child: const Text('SIGN OUT')
                )
              ),
            ])
          ],
        ),
      ),
    );
  }

  void _showStorageDataDialog(BuildContext context) async {
    final storageService = Get.find<StorageService>();
    final cacheSize = await storageService.getCacheSize();
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: const Text('STORAGE SAFETY', style: TextStyle(fontWeight: FontWeight.w900)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogItem(
            title: 'CACHE DATA', 
            subtitle: '${cacheSize.toStringAsFixed(2)} MB', 
            onTap: () => _confirmClearCache(context, storageService)
          ),
          const Divider(thickness: 1.5),
          _buildDialogItem(
            title: 'HARD RESET', 
            subtitle: 'WIPE ALL LOCAL DATA', 
            isDestructive: true,
            onTap: () => _confirmClearAllData(context, storageService)
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(), 
          child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900))
        )
      ],
    ));
  }

  Widget _buildDialogItem({required String title, required String subtitle, required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: isDestructive ? const Color(0xFFE11D48) : TColors.slate600, fontWeight: FontWeight.w600, fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFE11D48).withValues(alpha: 0.1) : TColors.executiveNavy.withValues(alpha: 0.1),
          border: Border.all(color: isDestructive ? const Color(0xFFE11D48) : TColors.executiveNavy, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isDestructive ? 'WIPE' : 'CLEAR', 
          style: TextStyle(
            color: isDestructive ? const Color(0xFFE11D48) : TColors.executiveNavy, 
            fontWeight: FontWeight.w900, 
            fontSize: 10
          )
        ),
      ),
      onTap: onTap,
    );
  }

  void _confirmClearCache(BuildContext context, StorageService service) {
    Get.back();
    service.clearCache();
    TSnackBar.showSuccess(message: 'CACHE FREED!');
  }

  void _confirmClearAllData(BuildContext context, StorageService service) {
    Get.back();
    service.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding));
  }

  void _showLanguageSelectionDialog(BuildContext context, LanguageService languageService) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: TColors.white, 
          borderRadius: BorderRadius.zero,
          border: Border(top: BorderSide(color: TColors.executiveNavy, width: 3.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SELECT LANGUAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 24),
            ...languageService.languages.map((lang) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: languageService.currentLocale.value.toString() == lang['locale'].toString() 
                    ? TColors.executiveNavy 
                    : TColors.slate300, 
                  width: 1.5
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(
                title: Text(lang['name'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                trailing: languageService.currentLocale.value.toString() == lang['locale'].toString() 
                  ? const Icon(Icons.check_box, color: TColors.executiveNavy) 
                  : null,
                onTap: () {
                  languageService.changeLanguage(lang['code']);
                  Get.back();
                },
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
