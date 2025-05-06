import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app/routes/app_routes.dart';
import '../../../common/utils/constants/image_strings.dart';
import '../controllers/teacher_profile_controller.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherProfileController());
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          Obx(
            () => controller.isEditMode.value
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
                Obx(() {
                  if (controller.isStatsLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Row(
                    children: [
                      _buildStatItem(
                        context,
                        controller.classCount.toString(),
                        'Classes',
                      ),
                      _buildStatItem(
                        context,
                        controller.studentCount.toString(),
                        'Students',
                      ),
                      _buildStatItem(
                        context,
                        '${controller.averageAttendance.value.toStringAsFixed(1)}%',
                        'Attendance',
                      ),
                    ],
                  );
                }),
                const SizedBox(height: TSizes.spaceBtwSections),

                // User Info Form or Display
                Obx(
                  () => controller.isEditMode.value
                      ? _buildEditForm(context, controller, dark)
                      : _buildProfileInfo(context, controller, dark),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            Get.defaultDialog(
                              title: 'Sign Out',
                              middleText: 'Are you sure you want to sign out?',
                              textConfirm: 'Sign Out',
                              textCancel: 'Cancel',
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.red,
                              cancelTextColor: Colors.grey,
                              onConfirm: () {
                                Get.back();
                                controller.logout();
                              },
                            );
                          },
                    icon: const Icon(Iconsax.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    icon: const Icon(Iconsax.user_add4),
                    label: const Text('Add Another Account'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: dark ? TColors.yellow : TColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            Get.defaultDialog(
                              title: 'Delete Account',
                              middleText:
                                  'This action cannot be undone. All your data will be permanently deleted. Are you sure?',
                              textConfirm: 'Delete',
                              textCancel: 'Cancel',
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.red,
                              onConfirm: () {
                                Get.back();
                                controller.deleteAccount();
                              },
                            );
                          },
                    icon: const Icon(Iconsax.trash),
                    label: const Text('Delete Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.spaceBtwSections),

                // App version
                Text(
                  'App Version 0.0.1',
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
            // Profile image with Hero animation
            // Replace the profile image section in _buildProfileHeader method with this:

            // Profile image with Hero animation
            GestureDetector(
              onTap: () => controller.viewProfileImage(),
              child: Hero(
                tag: 'profileImage',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dark ? TColors.yellow : TColors.primary,
                      width: 2,
                    ),
                    image: controller.user.value?.profileImageUrl != null &&
                            controller.user.value!.profileImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              controller.user.value!.profileImageUrl!,
                            ),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              //print('Error loading profile image: $exception');
                            },
                          )
                        : const DecorationImage(
                            image: AssetImage(TImageStrings.appLogo),
                            fit: BoxFit.cover,
                          ),
                  ),
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
                    color: dark ? TColors.yellow : TColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () => controller.pickAndUploadImage(),
                    child: Icon(
                      Iconsax.camera,
                      size: 20,
                      color: dark ? TColors.dark : Colors.white,
                    ),
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
        Obx(() {
          return dark
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TColors.yellow,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.user,
                        color: TColors.yellow,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            controller.user.value?.name ?? 'Not available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Iconsax.user,
                      color: TColors.primary,
                    ),
                    title: Text(
                      'Name',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      controller.user.value?.name ?? 'Not available',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
        }),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Email
        Obx(() {
          return dark
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TColors.yellow,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.direct,
                        color: TColors.yellow,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            controller.user.value?.email ?? 'Not available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Iconsax.direct,
                      color: TColors.primary,
                    ),
                    title: Text(
                      'Email',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      controller.user.value?.email ?? 'Not available',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
        }),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Phone
        Obx(() {
          return dark
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TColors.yellow,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.call,
                        color: TColors.yellow,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            controller.user.value?.phone ?? 'Not available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Iconsax.call,
                      color: TColors.primary,
                    ),
                    title: Text(
                      'Phone',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      controller.user.value?.phone ?? 'Not available',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
        }),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Member Since
        Obx(() {
          return dark
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TColors.yellow,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        color: TColors.yellow,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Member Since',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            controller.user.value?.createdAt != null
                                ? '${controller.user.value!.createdAt!.day}/${controller.user.value!.createdAt!.month}/${controller.user.value!.createdAt!.year}'
                                : 'Not available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Iconsax.calendar,
                      color: TColors.primary,
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
                );
        }),
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
                color: dark ? TColors.yellow : TColors.primary,
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
                color: dark ? TColors.yellow : TColors.primary,
              ),
            ),
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              } else if (value.length != 10) {
                return 'Phone number must be exactly 10 digits';
              } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Phone number must contain only digits';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Update Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      controller.updateProfile();
                    },
              child: controller.isLoading.value
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
          border: Border.all(color: TColors.linkedin),
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
}

// Consolidated TeacherProfileController
