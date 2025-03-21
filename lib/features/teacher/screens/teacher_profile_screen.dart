import 'package:attedance__/models/user_model.dart';
import 'package:attedance__/routes/app_routes.dart';
import 'package:attedance__/utils/constants/colors.dart';
import 'package:attedance__/utils/constants/sized.dart';
import 'package:attedance__/utils/helpers/helper_function.dart';
import 'package:attedance__/utils/helpers/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherProfileController());
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teacher Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          Obx(
            () =>
                controller.isEditMode.value
                    ? IconButton(
                      onPressed: () => controller.toggleEditMode(),
                      icon: const Icon(Icons.close),
                    )
                    : IconButton(
                      onPressed: () => controller.toggleEditMode(),
                      icon: const Icon(Iconsax.edit),
                    ),
          ),
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Iconsax.logout),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.user.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  controller.errorMessage.value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                ElevatedButton(
                  onPressed: controller.loadUserData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                // Profile header with image and name
                _buildProfileHeader(context, controller, dark),

                const SizedBox(height: TSizes.spaceBtwSections),

                // Stats summary
                Row(
                  children: [
                    _buildStatItem(context, '12', 'Classes'),
                    _buildStatItem(context, '248', 'Students'),
                    _buildStatItem(context, '87%', 'Attendance'),
                  ],
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                // User Info Form or Display
                Obx(
                  () =>
                      controller.isEditMode.value
                          ? _buildEditForm(context, controller, dark)
                          : _buildProfileInfo(context, controller, dark),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                // Settings sections
                _buildSection(
                  context: context,
                  title: 'App Settings',
                  items: [
                    _buildProfileMenuItem(
                      title: 'Dark Mode',
                      icon: dark ? Iconsax.moon : Iconsax.sun_1,
                      trailing: Switch(
                        value: dark,
                        onChanged: (_) => controller.toggleTheme(),
                        activeColor: dark ? TColors.yellow : TColors.deepPurple,
                      ),
                      dark: dark,
                    ),
                    _buildProfileMenuItem(
                      title: 'Email Notifications',
                      icon: Iconsax.notification,
                      trailing: Obx(
                        () => Switch(
                          value: controller.emailNotifications.value,
                          onChanged: controller.toggleEmailNotifications,
                          activeColor:
                              dark ? TColors.yellow : TColors.deepPurple,
                        ),
                      ),
                      dark: dark,
                    ),
                    _buildProfileMenuItem(
                      title: 'Language',
                      icon: Iconsax.language_square,
                      trailing: const Text('English'),
                      dark: dark,
                    ),
                  ],
                ),

                const SizedBox(height: TSizes.spaceBtwItems),

                _buildSection(
                  context: context,
                  title: 'Support',
                  items: [
                    _buildProfileMenuItem(
                      title: 'Help & Support',
                      icon: Iconsax.support,
                      dark: dark,
                    ),
                    _buildProfileMenuItem(
                      title: 'Terms of Service',
                      icon: Iconsax.document,
                      dark: dark,
                    ),
                    _buildProfileMenuItem(
                      title: 'Privacy Policy',
                      icon: Iconsax.security_safe,
                      dark: dark,
                    ),
                  ],
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : () {
                              Get.defaultDialog(
                                title: 'Sign Out',
                                middleText:
                                    'Are you sure you want to sign out?',
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

                // Return to Login button
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    icon: const Icon(Iconsax.login),
                    label: const Text('Return to Login Page'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: dark ? TColors.yellow : TColors.deepPurple,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                // App version
                Text(
                  'App Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: TSizes.spaceBtwSections),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    TeacherProfileController controller,
    bool dark,
  ) {
    return Column(
      children: [
        // Profile image with edit button
        Stack(
          children: [
            // Profile image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: dark ? TColors.yellow : TColors.deepPurple,
                  width: 2,
                ),
                color: dark ? TColors.darkerGrey : TColors.grey,
              ),
              child: Center(
                child: Text(
                  controller.user.value?.name.substring(0, 1).toUpperCase() ??
                      'T',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),

            // Edit button
            if (controller.isEditMode.value)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: dark ? TColors.yellow : TColors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.camera,
                    size: 20,
                    color: dark ? Colors.black : Colors.white,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: TSizes.spaceBtwItems),

        // Teacher name
        Obx(
          () => Text(
            controller.user.value?.name ?? 'Teacher',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),

        // Teacher email
        Obx(
          () => Text(
            controller.user.value?.email ?? 'teacher@example.com',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(
    BuildContext context,
    TeacherProfileController controller,
    bool dark,
  ) {
    return Column(
      children: [
        // Name
        ListTile(
          leading: Icon(
            Iconsax.user,
            color: dark ? TColors.yellow : TColors.deepPurple,
          ),
          title: Text('Name', style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            controller.user.value?.name ?? 'Not available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const Divider(),

        // Email
        ListTile(
          leading: Icon(
            Iconsax.direct,
            color: dark ? TColors.yellow : TColors.deepPurple,
          ),
          title: Text('Email', style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            controller.user.value?.email ?? 'Not available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const Divider(),

        // Phone
        ListTile(
          leading: Icon(
            Iconsax.call,
            color: dark ? TColors.yellow : TColors.deepPurple,
          ),
          title: Text('Phone', style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            controller.user.value?.phone ?? 'Not available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const Divider(),

        // Member Since
        ListTile(
          leading: Icon(
            Iconsax.calendar,
            color: dark ? TColors.yellow : TColors.deepPurple,
          ),
          title: Text(
            'Member Since',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            controller.user.value?.createdAt != null
                ? '${controller.user.value!.createdAt!.day}/${controller.user.value!.createdAt!.month}/${controller.user.value!.createdAt!.year}'
                : 'Not available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(
    BuildContext context,
    TeacherProfileController controller,
    bool dark,
  ) {
    return Form(
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: controller.nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(
                Iconsax.user,
                color: dark ? TColors.yellow : TColors.deepPurple,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Phone Field
          TextFormField(
            controller: controller.phoneController,
            decoration: InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(
                Iconsax.call,
                color: dark ? TColors.yellow : TColors.deepPurple,
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Update Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value
                      ? null
                      : () {
                        controller.updateProfile();
                      },
              child:
                  controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Update Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: TSizes.md),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
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

// Consolidated TeacherProfileController
class TeacherProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  // User data
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // Form controllers for editing
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // UI state
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isEditMode = false.obs;
  final emailNotifications = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        errorMessage.value = 'No authenticated user found';

        // Create a fallback user model with placeholder data
        user.value = UserModel(
          id: 'guest',
          name: 'Guest Teacher',
          email: 'teacher@example.com',
          phone: 'Not available',
        );

        // Set up form controllers with placeholder values
        nameController.text = user.value?.name ?? '';
        phoneController.text = user.value?.phone ?? '';

        return;
      }

      // Try to fetch user data from the users table
      try {
        final userData =
            await supabase
                .from('users')
                .select()
                .eq('id', currentUser.id)
                .maybeSingle();

        if (userData != null) {
          // User exists in the database
          user.value = UserModel.fromJson({
            ...userData,
            'id': currentUser.id,
            'email': currentUser.email ?? '',
          });
        } else {
          // User doesn't exist in the database yet, create a new entry
          final newUserData = {
            'id': currentUser.id,
            'name': currentUser.userMetadata?['name'] ?? 'New Teacher',
            'email': currentUser.email ?? '',
            'phone': currentUser.userMetadata?['phone'] ?? '',
            'created_at': DateTime.now().toIso8601String(),
          };

          // Insert the new user
          await supabase.from('users').insert(newUserData);

          // Set the user model
          user.value = UserModel.fromJson(newUserData);
        }
      } catch (e) {
        // If there's an error fetching from the database, create a basic user model from auth
        user.value = UserModel(
          id: currentUser.id,
          name: currentUser.userMetadata?['name'] ?? 'New Teacher',
          email: currentUser.email ?? '',
          phone: currentUser.userMetadata?['phone'] ?? '',
        );

        print('Error fetching user data: $e');
      }

      // Set up form controllers with current values
      nameController.text = user.value?.name ?? '';
      phoneController.text = user.value?.phone ?? '';
    } catch (e) {
      errorMessage.value = e.toString();
      print('Profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
  }

  void toggleTheme() {
    Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;

    // Reset form controllers when entering edit mode
    if (isEditMode.value) {
      nameController.text = user.value?.name ?? '';
      phoneController.text = user.value?.phone ?? '';
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get current user
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        errorMessage.value = 'No authenticated user found';
        return;
      }

      // Update user data in the users table
      await supabase
          .from('users')
          .update({
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser.id);

      // Refresh user data
      await loadUserData();

      // Exit edit mode
      isEditMode.value = false;

      TSnackBar.showSuccess(message: 'Profile updated successfully');
    } catch (e) {
      errorMessage.value = e.toString();
      TSnackBar.showServerError(
        message: 'Failed to update profile: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      await supabase.auth.signOut();

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.login);

      TSnackBar.showInfo(message: 'You have been signed out');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to sign out: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
