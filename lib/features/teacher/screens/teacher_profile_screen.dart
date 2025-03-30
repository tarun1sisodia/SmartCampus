import 'dart:io';

import 'package:attedance__/models/user_model.dart';
import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/services/attendance_service.dart';
import 'package:attedance__/services/class_service.dart';
import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:attedance__/common/utils/helpers/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
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
                  () =>
                      controller.isEditMode.value
                          ? _buildEditForm(context, controller, dark)
                          : _buildProfileInfo(context, controller, dark),
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
            // Profile image with Hero animation
            // Replace the profile image section in _buildProfileHeader method with this:

            // Profile image with Hero animation
            Hero(
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
                  image:
                      controller.user.value?.profileImageUrl != null &&
                              controller.user.value!.profileImageUrl!.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(
                              controller.user.value!.profileImageUrl!,
                            ),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              print('Error loading profile image: $exception');
                            },
                          )
                          : const DecorationImage(
                            image: AssetImage('assets/logos/darkapplogo.png'),
                            fit: BoxFit.cover,
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
  // Add these at the top of your TeacherProfileController class
  final classService = ClassService();
  final attendanceService = AttendanceService();

  // Add these observable properties to store statistics
  final classCount = 0.obs;
  final studentCount = 0.obs;
  final averageAttendance = 0.0.obs;
  final isStatsLoading = false.obs;

  // Add this method to fetch statistics
  Future<void> loadTeacherStats() async {
    try {
      isStatsLoading.value = true;

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        return;
      }

      // Get classes count
      final classes = await classService.getTeacherClasses(currentUser.id);
      classCount.value = classes.length;

      // Get total student count
      int totalStudents = 0;
      double totalAttendancePercentage = 0.0;
      int classesWithAttendance = 0;

      for (var classModel in classes) {
        // Get students for this class
        try {
          final response = await supabase
              .from('class_students')
              .select('id')
              .eq('class_id', classModel.id);

          totalStudents += response.length;
        } catch (e) {
          print('Error getting students for class ${classModel.id}: $e');
        }

        // Get attendance stats for this class
        try {
          final stats = await attendanceService.getAttendanceStatsForClass(
            classModel.id,
          );
          if (stats['totalSessions'] > 0) {
            totalAttendancePercentage += stats['averageAttendance'] as double;
            classesWithAttendance++;
          }
        } catch (e) {
          print(
            'Error getting attendance stats for class ${classModel.id}: $e',
          );
          // Continue with next class if there's an error
        }
      }

      // Update student count
      studentCount.value = totalStudents;

      // Calculate average attendance
      if (classesWithAttendance > 0) {
        averageAttendance.value =
            totalAttendancePercentage / classesWithAttendance;
      } else {
        averageAttendance.value = 0.0;
      }
    } catch (e) {
      print('Error loading teacher stats: $e');
    } finally {
      isStatsLoading.value = false;
    }
  }

  // Update the onInit method to also load stats
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadTeacherStats();
  }

  // Add method to refresh all data
  Future<void> refreshProfileData() async {
    await Future.wait([loadUserData(), loadTeacherStats()]);
  }

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
  final isUploadingImage = false.obs;

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
          id: 'Tarun',
          name: 'Tarun ',
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

  Future<void> pickAndUploadImage() async {
    try {
      // Show image source selection dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: Get.context!,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Image Source'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: const Text('Take a photo'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: const Text('Choose from gallery'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (source == null) return; // User canceled the dialog

      isUploadingImage.value = true;

      // Get current user
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(
          message: 'You must be logged in to upload an image',
        );
        return;
      }

      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) {
        isUploadingImage.value = false;
        return; // User canceled the picker
      }

      // Get file extension
      final fileExt = path.extension(image.path);
      final fileName = '${currentUser.id}$fileExt';
      final filePath = '${currentUser.id}/$fileName';

      // Upload to Supabase Storage
      final file = File(image.path);
      await supabase.storage
          .from('profile_images')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // Get the public URL
      final imageUrl = supabase.storage
          .from('profile_images')
          .getPublicUrl(filePath);

      // Update user record with the image URL
      await supabase
          .from('users')
          .update({'profile_image_url': imageUrl})
          .eq('id', currentUser.id);

      // Refresh user data
      await loadUserData();

      TSnackBar.showSuccess(message: 'Profile image updated successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to upload image: ${e.toString()}');
      print('Image upload error: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }
}
