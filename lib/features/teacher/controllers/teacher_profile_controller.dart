import 'dart:io';

import 'package:attedance__/features/teacher/screens/profile_image_view_screen.dart';
import 'package:attedance__/models/user_model.dart';
import 'package:attedance__/app/routes/app_routes.dart';
import 'package:attedance__/services/attendance_service.dart';
import 'package:attedance__/services/class_service.dart';
import 'package:attedance__/common/utils/helpers/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // fetch statistics
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
          //printnt('Error getting students for class ${classModel.id}: $e');
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
          //print('Error getting attendance stats for class ${classModel.id}: $e',          );
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
      //printnt('Error loading teacher stats: $e');
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
        final userData = await supabase
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

        //printnt('Error fetching user data: $e');
      }

      // Set up form controllers with current values
      nameController.text = user.value?.name ?? '';
      phoneController.text = user.value?.phone ?? '';
    } catch (e) {
      errorMessage.value = e.toString();
      //printnt('Profile error: $e');
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
      await supabase.from('users').update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser.id);

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
        imageQuality: 100,
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
      final imageUrl =
          supabase.storage.from('profile_images').getPublicUrl(filePath);

      // Update user record with the image URL
      await supabase
          .from('users')
          .update({'profile_image_url': imageUrl}).eq('id', currentUser.id);

      // Refresh user data
      await loadUserData();

      TSnackBar.showSuccess(message: 'Profile image updated successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to upload image: ${e.toString()}');
      //printnt('Image upload error: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;

      // Get current user
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(message: 'No authenticated user found');
        return;
      }

      // Show a loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 1. Delete user data from the users table
      await supabase.from('users').delete().eq('id', currentUser.id);

      // 2. Delete profile image from storage if it exists
      if (user.value?.profileImageUrl != null &&
          user.value!.profileImageUrl!.isNotEmpty) {
        try {
          final filePath =
              '${currentUser.id}/${currentUser.id}${path.extension(user.value!.profileImageUrl!)}';
          await supabase.storage.from('profile_images').remove([filePath]);
        } catch (e) {
          // Continue even if image deletion fails
          //printnt('Failed to delete profile image: $e');
        }
      }

      // 3. Delete the user's classes (optional - you may want to handle this differently)
      try {
        final classes = await classService.getTeacherClasses(currentUser.id);
        for (var classModel in classes) {
          // Delete attendance sessions for this class
          await supabase
              .from('attendance_sessions')
              .delete()
              .eq('class_id', classModel.id);

          // Delete class_students relationships
          await supabase
              .from('class_students')
              .delete()
              .eq('class_id', classModel.id);

          // Delete the class itself
          await supabase.from('classes').delete().eq('id', classModel.id);
        }
      } catch (e) {
        //printnt('Error deleting classes: $e');
        // Continue with account deletion even if class deletion fails
      }

      // 4. Finally, delete the user account from Supabase Auth
      await supabase.auth.admin.deleteUser(currentUser.id);

      // Close the loading dialog
      Get.back();

      // 5. Sign out (this will happen automatically, but we'll do it explicitly)
      await supabase.auth.signOut();

      // 6. Navigate to splash screen
      Get.offAllNamed(AppRoutes.splash);

      // Show success message
      TSnackBar.showSuccess(
        message: 'Your account has been deleted successfully',
      );
    } catch (e) {
      // Close the loading dialog if it's open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      TSnackBar.showError(message: 'Failed to delete account: ${e.toString()}');
      //printnt('Account deletion error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // your TeacherProfileController class

  void viewProfileImage() {
    if (user.value?.profileImageUrl != null &&
        user.value!.profileImageUrl!.isNotEmpty) {
      Get.to(
        () => ProfileImageViewScreen(
          imageUrl: user.value!.profileImageUrl!,
        ),
        transition: Transition.fadeIn,
      );
    } else {
      // If no profile image, show a message
      TSnackBar.showInfo(message: 'No profile image available');
    }
  }
}
