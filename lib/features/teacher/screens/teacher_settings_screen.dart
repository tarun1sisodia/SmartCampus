import 'package:attedance__/features/teacher/screens/teacher_profile_screen.dart';
import 'package:attedance__/routes/app_routes.dart';
import 'package:attedance__/services/storage_service.dart';
import 'package:attedance__/utils/constants/colors.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:attedance__/utils/helpers/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final controller = Get.put(
      TeacherProfileController(),
    ); // Ensure initialization

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
                    Get.to(() => const TeacherProfileScreen());
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Change Password',
                  icon: Iconsax.password_check,
                  dark: dark,
                  onTap: () {
                    // Implement change password functionality
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Email Notifications',
                  icon: Iconsax.notification,
                  dark: dark,
                  trailing: Obx(
                    () => Switch(
                      value: controller.emailNotifications.value,
                      onChanged: controller.toggleEmailNotifications,
                      activeColor: dark ? TColors.yellow : TColors.deepPurple,
                    ),
                  ),
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
                    onChanged: (_) => controller.toggleTheme(),
                    activeColor: dark ? TColors.yellow : TColors.deepPurple,
                  ),
                ),
                _buildProfileMenuItem(
                  title: 'Language',
                  icon: Iconsax.language_square,
                  dark: dark,
                  trailing: const Text('English'),
                  onTap: () {
                    // Implement language selection
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Notifications',
                  icon: Iconsax.notification,
                  dark: dark,
                  onTap: () {
                    // Implement notification settings
                  },
                ),

                _buildProfileMenuItem(
                  title: 'Storage & Data',
                  icon: Iconsax.cloud,
                  dark: dark,
                  onTap: () async {
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
                                color:
                                    dark ? TColors.yellow : TColors.deepPurple,
                              ),
                              title: const Text('Cache Size'),
                              subtitle: Text(cacheSizeText),
                              trailing: TextButton(
                                onPressed: () {
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
                                color:
                                    dark ? TColors.yellow : TColors.deepPurple,
                              ),
                              title: const Text('Clear All Data'),
                              subtitle: const Text(
                                'Reset app to default state',
                              ),
                              onTap: () {
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
                                            Get.offAllNamed(AppRoutes.login);
                                          } catch (e) {
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
                                color:
                                    dark ? TColors.yellow : TColors.deepPurple,
                              ),
                              title: const Text('Export Data'),
                              subtitle: const Text(
                                'Download your data as a file',
                              ),
                              onTap: () async {
                                try {
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
                    // Implement help & support
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Terms of Service',
                  icon: Iconsax.document,
                  dark: dark,
                  onTap: () {
                    // Implement terms of service
                  },
                ),
                _buildProfileMenuItem(
                  title: 'Privacy Policy',
                  icon: Iconsax.security_safe,
                  dark: dark,
                  onTap: () {
                    // Implement privacy policy
                  },
                ),
                _buildProfileMenuItem(
                  title: 'About',
                  icon: Iconsax.info_circle,
                  dark: dark,
                  onTap: () {
                    // Implement about screen
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
                  Get.defaultDialog(
                    title: 'Sign Out',
                    middleText: 'Are you sure you want to sign out?',
                    textConfirm: 'Yes',
                    textCancel: 'No',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
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

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
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
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder:
                (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
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
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (dark ? TColors.yellow : TColors.deepPurple).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: dark ? TColors.yellow : TColors.deepPurple),
      ),
      title: Text(title),
      trailing: trailing ?? const Icon(Iconsax.arrow_right_3, size: 18),
    );
  }
}
