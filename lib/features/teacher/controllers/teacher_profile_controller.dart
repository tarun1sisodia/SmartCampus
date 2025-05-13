import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes/app_routes.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../models/user_model.dart';
import '../../../services/attendance_service.dart';
import '../../../services/class_service.dart';
import '../screens/profile_image_view_screen.dart';

// Consolidated TeacherProfileController
class TeacherProfileController extends GetxController {
  // Services for handling class and attendance-related operations
  final classService = ClassService();
  final attendanceService = AttendanceService();

  // Form key for validating forms
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Observable properties to store teacher statistics
  final classCount = 0.obs; // Number of classes the teacher has
  final studentCount = 0.obs; // Total number of students across all classes
  final averageAttendance = 0.0.obs; // Average attendance percentage
  final isStatsLoading = false.obs; // Loading state for statistics

  // Supabase client instance
  final supabase = Supabase.instance.client;

  // Observable user data
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // Controllers for form fields (name and phone)
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // UI state variables
  final isLoading = false.obs; // Loading state for general operations
  final errorMessage = ''.obs; // Error message for UI display
  final isEditMode = false.obs; // Toggle for edit mode
  final emailNotifications = true.obs; // Email notification toggle
  final isUploadingImage = false.obs; // Loading state for image upload

  // Dispose controllers when the controller is closed
  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Initialize the controller and load user data and statistics
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadTeacherStats();
  }

  // Fetch and calculate teacher statistics
  Future<void> loadTeacherStats() async {
    try {
      isStatsLoading.value = true;

      // Get the currently authenticated user
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        return;
      }

      // Fetch the classes associated with the teacher
      final classes = await classService.getTeacherClasses(currentUser.id);
      classCount.value = classes.length;

      // Initialize counters for students and attendance
      int totalStudents = 0;
      double totalAttendancePercentage = 0.0;
      int classesWithAttendance = 0;

      // Iterate through each class to calculate statistics
      for (var classModel in classes) {
        try {
          // Fetch the number of students in the class
          final response = await supabase
              .from('class_students')
              .select('id')
              .eq('class_id', classModel.id);

          totalStudents += response.length;
        } catch (e) {
          // Handle errors while fetching students
        }

        try {
          // Fetch attendance statistics for the class
          final stats = await attendanceService.getAttendanceStatsForClass(
            classModel.id,
          );
          if (stats['totalSessions'] > 0) {
            totalAttendancePercentage += stats['averageAttendance'] as double;
            classesWithAttendance++;
          }
        } catch (e) {
          // Handle errors while fetching attendance stats
        }
      }

      // Update the total student count
      studentCount.value = totalStudents;

      // Calculate the average attendance percentage
      if (classesWithAttendance > 0) {
        averageAttendance.value =
            totalAttendancePercentage / classesWithAttendance;
      } else {
        averageAttendance.value = 0.0;
      }
    } catch (e) {
      // Handle errors during statistics loading
    } finally {
      isStatsLoading.value = false;
    }
  }

  // Refresh both user data and statistics
  Future<void> refreshProfileData() async {
    await Future.wait([loadUserData(), loadTeacherStats()]);
  }

  // Load user data from Supabase or fallback to placeholder data
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get the currently authenticated user
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        errorMessage.value = 'You are not authenticated';

        // Fallback user data
        user.value = UserModel(
          id: 'Tarun',
          name: 'Tarun ',
          email: 'teacher@example.com',
          phone: 'Not available',
        );

        // Set form controllers with placeholder values
        nameController.text = user.value?.name ?? '';
        phoneController.text = user.value?.phone ?? '';

        return;
      }

      try {
        // Fetch user data from the database
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
          // Create a new user entry in the database
          final newUserData = {
            'id': currentUser.id,
            'name': currentUser.userMetadata?['name'] ?? 'New Teacher',
            'email': currentUser.email ?? '',
            'phone': currentUser.userMetadata?['phone'] ?? '',
            'created_at': DateTime.now().toIso8601String(),
          };

          await supabase.from('users').insert(newUserData);

          user.value = UserModel.fromJson(newUserData);
        }
      } catch (e) {
        // Fallback to basic user data from authentication
        user.value = UserModel(
          id: currentUser.id,
          name: currentUser.userMetadata?['name'] ?? 'New Teacher',
          email: currentUser.email ?? '',
          phone: currentUser.userMetadata?['phone'] ?? '',
        );
      }

      // Set form controllers with current user data
      nameController.text = user.value?.name ?? '';
      phoneController.text = user.value?.phone ?? '';
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle email notifications
  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
  }

  // Toggle between light and dark themes
  void toggleTheme() {
    Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  // Toggle edit mode and reset form controllers
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;

    if (isEditMode.value) {
      nameController.text = user.value?.name ?? '';
      phoneController.text = user.value?.phone ?? '';
    }
  }

  // Update user profile information
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        errorMessage.value = 'No authenticated user found';
        return;
      }

      await supabase.from('users').update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser.id);

      await loadUserData();

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

  // Log out the user
  Future<void> logout() async {
    try {
      isLoading.value = true;

      await supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.login);

      TSnackBar.showInfo(message: 'You have been signed out');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to sign out: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Pick and upload a profile image
  Future<void> pickAndUploadImage() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: Get.context!,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Image Source'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: Row(
                  children: [
                    const Icon(Iconsax.camera, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Take a photo'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: Row(
                  children: [
                    const Icon(Iconsax.gallery, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Choose from gallery'),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Get.back();
                },
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          );
        },
      );

      if (source == null) return;

      isUploadingImage.value = true;

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(
          message: 'You must be logged in to upload an image',
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: source, imageQuality: 100);

      if (image == null) {
        isUploadingImage.value = false;
        return;
      }

      final fileExt = path.extension(image.path);
      final fileName = '${currentUser.id}$fileExt';
      final filePath = '${currentUser.id}/$fileName';

      final file = File(image.path);
      await supabase.storage
          .from('profile_images')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      final imageUrl =
          supabase.storage.from('profile_images').getPublicUrl(filePath);

      await supabase
          .from('users')
          .update({'profile_image_url': imageUrl}).eq('id', currentUser.id);

      await loadUserData();

      TSnackBar.showSuccess(message: 'Profile image updated successfully');
    } catch (e) {
      TSnackBar.showError(message: 'Failed to upload image: ${e.toString()}');
    } finally {
      isUploadingImage.value = false;
    }
  }

  // Delete the user's account and associated data to run this function we need a admin account...
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        TSnackBar.showError(message: 'No authenticated user found');
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await supabase.from('users').delete().eq('id', currentUser.id);

      if (user.value?.profileImageUrl != null &&
          user.value!.profileImageUrl!.isNotEmpty) {
        try {
          final filePath =
              '${currentUser.id}/${currentUser.id}${path.extension(user.value!.profileImageUrl!)}';
          await supabase.storage.from('profile_images').remove([filePath]);
        } catch (e) {
          Get.snackbar('Delete Account can be only run by', 'Admin');
        }
      }

      try {
        final classes = await classService.getTeacherClasses(currentUser.id);
        for (var classModel in classes) {
          await supabase
              .from('attendance_sessions')
              .delete()
              .eq('class_id', classModel.id);

          await supabase
              .from('class_students')
              .delete()
              .eq('class_id', classModel.id);

          await supabase.from('classes').delete().eq('id', classModel.id);
        }
      } catch (e) {
        Get.snackbar('Delete Account can be only run by', 'Admin');
      }

      await supabase.auth.admin.deleteUser(currentUser.id);

      Get.back();

      await supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.splash);

      TSnackBar.showSuccess(
        message: 'Your account has been deleted successfully',
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      TSnackBar.showError(message: 'Failed to delete account: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // View the profile image in a separate screen
  void viewProfileImage() {
    if (user.value?.profileImageUrl != null &&
        user.value!.profileImageUrl!.isNotEmpty) {
      Get.to(
        () => ProfileImageViewScreen(imageUrl: user.value!.profileImageUrl!),
        transition: Transition.fadeIn,
      );
    } else {
      TSnackBar.showInfo(message: 'No profile image available');
    }
  }
}
