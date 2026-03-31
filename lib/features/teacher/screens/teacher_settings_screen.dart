import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/theme_configs.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.spaceBtwItems),
        child: Column(
          children: [
            _buildProfileCard(context, controller),
            const SizedBox(height: TSizes.spaceBtwSections),
            _buildSection(
              context: context,
              title: 'Preferences',
              items: [
                _buildProfileMenuItem(
                  context: context,
                  title: 'Language',
                  icon: Iconsax.language_square,
                  trailing: Obx(() => Text(languageService.getCurrentLanguageName(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold))),
                  onTap: () => _showLanguageSelectionDialog(context, languageService),
                ),
                _buildProfileMenuItem(
                  context: context,
                  title: 'Biometric Login',
                  icon: Icons.fingerprint,
                  trailing: Obx(() {
                    final biometricService = Get.find<BiometricAuthService>();
                    if (!biometricService.isAvailable.value) return const SizedBox.shrink();
                    return Switch.adaptive(
                      value: biometricService.isBiometricEnabled.value,
                      onChanged: (value) => controller.toggleBiometric(value),
                      activeColor: colorScheme.primary,
                    );
                  }),
                ),
                _buildProfileMenuItem(
                  context: context,
                  title: 'Email Alerts',
                  icon: Iconsax.notification,
                  trailing: Obx(() => Switch.adaptive(
                    value: controller.emailNotifications.value,
                    onChanged: controller.toggleEmailNotifications,
                    activeColor: colorScheme.primary,
                  )),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            _buildSection(
              context: context,
              title: 'Appearance',
              items: [_buildThemeSelector(context)],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            _buildSection(
              context: context,
              title: 'Data & Maintenance',
              items: [
                _buildProfileMenuItem(context: context, title: 'Import Data', icon: Iconsax.import_1, onTap: () => Get.toNamed(AppRoutes.import)),
                _buildProfileMenuItem(context: context, title: 'Export History', icon: Iconsax.export_3, onTap: () => Get.toNamed(AppRoutes.export)),
                _buildProfileMenuItem(context: context, title: 'Storage Management', icon: Iconsax.cloud, onTap: () => _showStorageDataDialog(context)),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            _buildSection(
              context: context,
              title: 'Support',
              items: [
                _buildProfileMenuItem(context: context, title: 'Help Center', icon: Iconsax.support, onTap: () => Get.toNamed(AppRoutes.help)),
                _buildProfileMenuItem(context: context, title: 'Privacy & Security', icon: Iconsax.security_safe, onTap: () => Get.toNamed(AppRoutes.privacyPolicy)),
                _buildProfileMenuItem(context: context, title: 'App Feedback', icon: Iconsax.message_question, onTap: () => Get.toNamed(AppRoutes.feedback)),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            _buildSignOutButton(context, controller),
            const SizedBox(height: TSizes.spaceBtwSections),
            Text('Version 1.2.4 (Build 1205)', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline)),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, TeacherProfileController controller) {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Iconsax.user, size: 30)),
            const SizedBox(width: TSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Teacher Name', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(user?.email ?? 'email@campus.com', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(onPressed: () => Get.to(() => TeacherProfileScreen()), icon: const Icon(Iconsax.edit, size: 20)),
          ],
        ),
      );
    });
  }

  Widget _buildSection({required BuildContext context, required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Theme.of(context).colorScheme.onSurfaceVariant))),
        Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(TSizes.cardRadiusLg), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
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
        Padding(padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8), child: Text('Interface Theme', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                      border: Border.all(color: isSelected ? theme.primary : Theme.of(context).colorScheme.outlineVariant, width: isSelected ? 3 : 1),
                      boxShadow: isSelected ? [BoxShadow(color: theme.primary.withValues(alpha: 0.2), blurRadius: 8)] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildColorCircle(theme.primary), const SizedBox(width: 4), _buildColorCircle(theme.accent)]),
                        const SizedBox(height: 8),
                        Text(theme.name, style: TextStyle(color: theme.textPrimary, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        if (isSelected) Icon(Icons.check_circle, color: theme.primary, size: 14),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(width: 20, height: 20, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3))));
  }

  Widget _buildProfileMenuItem({required BuildContext context, required String title, required IconData icon, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18)),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 14),
    );
  }

  Widget _buildSignOutButton(BuildContext context, TeacherProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmSignOut(context, controller),
        icon: const Icon(Iconsax.logout, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.cardRadiusLg)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, TeacherProfileController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: TSizes.spaceBtwSections),
            const Icon(Iconsax.logout, size: 48, color: Colors.red),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text('Sign Out?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: TSizes.sm),
            const Text('Are you sure you want to exit? Attendance data is safe.', textAlign: TextAlign.center),
            const SizedBox(height: TSizes.spaceBtwSections),
            Row(children: [
              Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text('Stay'))),
              Expanded(child: ElevatedButton(onPressed: () => controller.logout(), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Sign Out'))),
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
      title: const Text('Storage Safety'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Cache Data'), subtitle: Text('${cacheSize.toStringAsFixed(2)} MB'), trailing: TextButton(onPressed: () => _confirmClearCache(context, storageService), child: const Text('Clear'))),
          const Divider(),
          ListTile(leading: const Icon(Iconsax.danger, color: Colors.red), title: const Text('Hard Reset'), subtitle: const Text('Wipe all local data'), onTap: () => _confirmClearAllData(context, storageService)),
        ],
      ),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text('Done'))],
    ));
  }

  void _confirmClearCache(BuildContext context, StorageService service) {
    Get.back();
    service.clearCache();
    TSnackBar.showSuccess(message: 'Cache freed!');
  }

  void _confirmClearAllData(BuildContext context, StorageService service) {
    Get.back();
    service.clearAllData().then((_) => Get.offAllNamed(AppRoutes.onboarding));
  }

  void _showLanguageSelectionDialog(BuildContext context, LanguageService languageService) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Language', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: TSizes.spaceBtwItems),
            ...languageService.languages.map((lang) => ListTile(
                  title: Text(lang['name']),
                  trailing: languageService.currentLocale.value.toString() == lang['locale'].toString() ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
                  onTap: () {
                    languageService.changeLanguage(lang['code']);
                    Get.back();
                  },
                )),
          ],
        ),
      ),
    );
  }
}
