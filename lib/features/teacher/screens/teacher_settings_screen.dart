import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import './../controllers/teacher_profile_controller.dart';
import '../../../app/routes/app_routes.dart';
import '/../services/language_service.dart';
import '/../services/storage_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'teacher_profile_screen.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //print('TeacherSettingsScreen build method called');
    final dark = THelperFunction.isDarkMode(context);
    final controller = Get.put(
      TeacherProfileController(),
    ); // Ensure initialization
    final languageService = Get.find<LanguageService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            _buildSection(
              context: context,
              title: 'Account',
              items: [
                _buildProfileMenuItem(
                  title: 'My Profile',
                  icon: Iconsax.user,
                  dark: dark,
                  onTap: () {
                    //print('Navigating to TeacherProfileScreen');
                    Get.to(() => TeacherProfileScreen());
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Change Password',
                  icon: Iconsax.password_check,
                  dark: dark,
                  onTap: () {
                    //print('Navigating to Change Password');
                    Get.toNamed(AppRoutes.changePassword);
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Email Notifications',
                  icon: Iconsax.notification,
                  dark: dark,
                  trailing: Obx(() {
                    //print('Email Notifications switch updated');
                    return Switch(
                      value: controller.emailNotifications.value,
                      onChanged: controller.toggleEmailNotifications,
                      activeColor: dark ? TColors.yellow : TColors.primary,
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // App Settings section
            _buildSection(
              context: context,
              title: 'App Settings',
              items: [
                _buildProfileMenuItem(
                  title: 'Dark Mode',
                  icon: dark ? Iconsax.moon : Iconsax.sun_1,
                  dark: dark,
                  trailing: Switch(
                    value: dark,
                    onChanged: (_) {
                      //print('Dark Mode toggled');
                      controller.toggleTheme();
                    },
                    activeColor: dark ? TColors.yellow : TColors.primary,
                  ),
                ),
                _buildProfileMenuItem(
                  title: 'language'.tr,
                  icon: Iconsax.language_square,
                  dark: dark,
                  trailing: Obx(() {
                    //print('Language updated');
                    return Text(languageService.getCurrentLanguageName());
                  }),
                  onTap: () {
                    //print('Opening Language Selection Dialog');
                    _showLanguageSelectionDialog(context, languageService);
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Notifications',
                  icon: Iconsax.notification,
                  dark: dark,
                  onTap: () {
                    //print('Navigating to Notifications');
                    Get.toNamed(AppRoutes.notifications);
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Data Import',
                  icon: Iconsax.import_1, // Updated icon for Data Import
                  dark: dark,
                  onTap: () {
                    //print('Navigating to Data Import');
                    Get.toNamed(AppRoutes.import);
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Data Export',
                  icon: Iconsax.export_3, // Updated icon for Data Export
                  dark: dark,
                  onTap: () {
                    //print('Navigating to Data Export');
                    Get.toNamed(AppRoutes.export);
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Storage & Data',
                  icon: Iconsax.cloud,
                  dark: dark,
                  onTap: () async {
                    //print('Opening Storage & Data Dialog');
                    // Get the storage service
                    final storageService = Get.find<StorageService>();

                    // Get cache size
                    final cacheSize = await storageService.getCacheSize();
                    final cacheSizeText = '${cacheSize.toStringAsFixed(2)} MB';

                    // Show a dialog with storage and data options
                    Get.dialog(
                      AlertDialog(
                        title: Text(
                          'Storage & Data',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(
                                Iconsax.document_1,
                                color: dark ? TColors.yellow : TColors.primary,
                              ),
                              title: const Text('Cache Size'),
                              subtitle: Text(cacheSizeText),
                              trailing: TextButton(
                                onPressed: () {
                                  //print('Clearing Cache');
                                  // Clear cache implementation
                                  Get.back();
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Clear Cache'),
                                      content: const Text(
                                        'Are you sure you want to clear the app cache? This will not delete any of your data.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              //print('Clearing Cache Confirmed');
                                              // Show loading indicator
                                              Get.back();
                                              Get.dialog(
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                barrierDismissible: false,
                                              );

                                              // Clear cache
                                              await storageService.clearCache();

                                              // Dismiss loading dialog
                                              Get.back();

                                              // Show success message
                                              TSnackBar.showSuccess(
                                                message:
                                                    'Cache cleared successfully',
                                              );
                                            } catch (e) {
                                              //print(
                                              // 'Failed to clear cache: ${e.toString()}');
                                              // Dismiss loading dialog
                                              Get.back();

                                              // Show error message
                                              TSnackBar.showError(
                                                message:
                                                    'Failed to clear cache: ${e.toString()}',
                                              );
                                            }
                                          },
                                          child: const Text('Clear'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Clear'),
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(
                                Iconsax.trash,
                                color: dark ? TColors.yellow : TColors.primary,
                              ),
                              title: const Text('Clear All Data'),
                              subtitle: const Text(
                                'Reset app to default state',
                              ),
                              onTap: () {
                                //print('Clearing All Data');
                                // Show confirmation dialog for clearing all data
                                Get.back();
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Clear All Data'),
                                    content: const Text(
                                      'This will reset the app to its default state and delete all your data including saved preferences, cached files, and local data. This action cannot be undone.\n\nAre you sure you want to continue?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () async {
                                          try {
                                            //print(
                                            // 'Clearing All Data Confirmed');
                                            // Show loading indicator
                                            Get.back();
                                            Get.dialog(
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              barrierDismissible: false,
                                            );

                                            // Clear all local storage
                                            await storageService.clearAllData();

                                            // Dismiss loading dialog
                                            Get.back();

                                            // Show success message
                                            TSnackBar.showSuccess(
                                              message:
                                                  'All data cleared successfully',
                                            );

                                            // Navigate to login screen
                                            Get.offAllNamed(
                                              AppRoutes.onboarding,
                                            );
                                          } catch (e) {
                                            //print(
                                            // 'Failed to clear all data: ${e.toString()}');
                                            // Dismiss loading dialog
                                            Get.back();

                                            // Show error message
                                            TSnackBar.showError(
                                              message:
                                                  'Failed to clear data: ${e.toString()}',
                                            );
                                          }
                                        },
                                        child: const Text('Clear All Data'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(
                                Iconsax.export,
                                color: dark ? TColors.yellow : TColors.primary,
                              ),
                              title: const Text('Export Data'),
                              subtitle: const Text(
                                'Download your data as a file',
                              ),
                              onTap: () async {
                                try {
                                  //print('Exporting Data');
                                  // Close the dialog
                                  Get.back();

                                  // Show loading indicator
                                  Get.dialog(
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    barrierDismissible: false,
                                  );

                                  // Export data
                                  await storageService.exportUserData();

                                  // Dismiss loading dialog
                                  Get.back();

                                  // Show success message
                                  TSnackBar.showSuccess(
                                    message: 'Data exported successfully',
                                  );
                                } catch (e) {
                                  //print(
                                  // 'Failed to export data: ${e.toString()}');
                                  // Dismiss loading dialog
                                  Get.back();

                                  // Show error message
                                  TSnackBar.showError(
                                    message:
                                        'Failed to export data: ${e.toString()}',
                                  );
                                }
                              },
                            ),

                            //to your existing settings screen
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // Support section
            _buildSection(
              context: context,
              title: 'Support',
              items: [
                _buildProfileMenuItem(
                  title: 'Help & Support',
                  icon: Iconsax.support,
                  dark: dark,
                  onTap: () {
                    //print('Navigating to Help & Support');
                    Get.toNamed(AppRoutes.help);
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Feedback',
                  icon: Iconsax.message_question,
                  dark: dark,
                  onTap: () {
                    //print('Navigating to Feedback');
                    Get.toNamed(AppRoutes.feedback);
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Privacy Policy',
                  icon: Iconsax.security_safe,
                  dark: dark,
                  onTap: () {
                    //print('Navigating to Privacy Policy');
                    // Implement privacy policy
                  },
                ),
                _buildProfileMenuItem(
                  title: 'About',
                  icon: Iconsax.info_circle,
                  dark: dark,
                  onTap: () {
                    //print('Navigating to About');
                    Get.toNamed(AppRoutes.about);
                  },
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  //print('Sign Out button pressed');
                  Get.defaultDialog(
                    title: 'Sign Out',
                    middleText: 'Are you sure you want to sign out?',
                    textConfirm: 'Yes',
                    textCancel: 'No',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      //print('Sign Out confirmed');
                      Get.back();
                      controller.logout();
                    },
                  );
                },
                icon: const Icon(Iconsax.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // App version
            const SizedBox(height: TSizes.spaceBtwSections),
            Center(
              child: Text(
                'App Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog(
    BuildContext context,
    LanguageService languageService,
  ) {
    //print('Language Selection Dialog opened');
    final dark = THelperFunction.isDarkMode(context);

    Get.dialog(
      AlertDialog(
        title: Text('select_language'.tr),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languageService.languages.length,
            itemBuilder: (context, index) {
              final language = languageService.languages[index];
              final isSelected =
                  languageService.currentLocale.value.toString() ==
                      language['locale'].toString();

              return ListTile(
                title: Text(language['name']),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: dark ? TColors.yellow : TColors.primary,
                      )
                    : null,
                onTap: () {
                  //print('Language changed to ${language['name']}');
                  languageService.changeLanguage(language['code']);
                  Get.back();
                  TSnackBar.showSuccess(message: 'language_changed'.tr);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('no'.tr)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    //print('Building section: $title');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.withAlpha(26)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.withAlpha(26),
              indent: 70,
            ),
            itemBuilder: (_, index) => items[index],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    required bool dark,
  }) {
    //print('Building profile menu item: $title');
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (dark ? TColors.yellow : TColors.primary).withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: dark ? TColors.yellow : TColors.primary),
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 18),
    );
  }
}
