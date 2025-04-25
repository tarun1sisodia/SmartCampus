import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:attedance__/features/teacher/controllers/teacher_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
                      color: dark ? TColors.yellow : TColors.deepPurple,
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
                            image: AssetImage('assets/logos/smartcampus.png'),
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
                    color: dark ? TColors.yellow : TColors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () => controller.pickAndUploadImage(),
                    child: Icon(
                      Iconsax.camera,
                      size: 20,
                      color: dark ? Colors.black : Colors.white,
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
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
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
            separatorBuilder: (_, __) => Divider(
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
