import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../models/user_model.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import '../screens/profile_image_view_screen.dart';

class TeacherProfileController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Statistics
  final classCount = 0.obs;
  final studentCount = 0.obs;
  final averageAttendance = 0.0.obs;
  final isStatsLoading = false.obs;

  // User Data
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // UI State
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isEditMode = false.obs;
  final emailNotifications = true.obs;
  final isUploadingImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadTeacherStats();
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

      final response = await ApiClient.dio.get('/users/me');
      if (response.statusCode == 200) {
        final userData = response.data['data'];
        user.value = UserModel.fromJson(userData);
        nameController.text = user.value?.name ?? '';
        phoneController.text = user.value?.phone ?? '';
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTeacherStats() async {
    try {
      isStatsLoading.value = true;
      final response = await ApiClient.dio.get('/analytics/teacher/me');
      final data = response.data['data'];
      
      classCount.value = data['totalClasses'] ?? 0;
      studentCount.value = data['totalStudents'] ?? 0;
      averageAttendance.value = (data['overallAttendance'] ?? 0.0).toDouble();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading stats: $e');
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      await ApiClient.dio.patch('/users/me', data: {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      await loadUserData();
      isEditMode.value = false;
      TSnackBar.showSuccess(message: 'Profile updated successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(message: 'Update failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return;

      isUploadingImage.value = true;
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(image.path, filename: 'profile.jpg'),
      });

      await ApiClient.dio.post('/users/me/photo', data: formData);
      await loadUserData();
      TSnackBar.showSuccess(message: 'Profile image updated successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(message: 'Upload failed: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      await ApiClient.dio.delete('/users/me');
      Get.back();

      await SecureStorageService.clearTokens();
      Get.offAllNamed(AppRoutes.splash);
      TSnackBar.showSuccess(message: 'Your account has been deleted successfully');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (Get.isDialogOpen ?? false) Get.back();
      TSnackBar.showError(message: 'Failed to delete account: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await ApiClient.dio.post('/auth/logout');
    } catch (e) {
      // Ignore logout errors
    } finally {
      await SecureStorageService.clearTokens();
      Get.offAllNamed(AppRoutes.login);
      isLoading.value = false;
      TSnackBar.showInfo(message: 'You have been signed out');
    }
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (isEditMode.value) {
      nameController.text = user.value?.name ?? '';
      phoneController.text = user.value?.phone ?? '';
    }
  }

  void viewProfileImage() {
    if (user.value?.profileImageUrl != null && user.value!.profileImageUrl!.isNotEmpty) {
      Get.to(() => ProfileImageViewScreen(imageUrl: user.value!.profileImageUrl!), transition: Transition.fadeIn);
    } else {
      TSnackBar.showInfo(message: 'No profile image available');
    }
  }
}
