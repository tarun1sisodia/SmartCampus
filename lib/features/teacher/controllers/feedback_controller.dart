import 'dart:async';
import 'package:attedance__/features/teacher/screens/feedback_screen.dart';
import 'package:attedance__/services/feedback_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attedance__/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackController extends GetxController {
  final FeedbackService _feedbackService = Get.find<FeedbackService>();
  final StorageService _storageService = Get.find<StorageService>();

  final rating = 0.obs;
  final feedbackText = ''.obs;
  final isSubmitting = false.obs;

  Timer? _checkTimer;

  @override
  void onInit() {
    super.onInit();
    //printnt('FeedbackController initialized');
    // Start a timer to periodically check if feedback should be shown
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      //printnt('Periodic timer triggered');
      checkAndShowFeedback();
    });

    // Also check immediately after a short delay
    Future.delayed(const Duration(seconds: 10), () {
      //printnt('Initial delayed check triggered');
      checkAndShowFeedback();
    });
  }

  @override
  void onClose() {
    //printnt('FeedbackController is being closed');
    _checkTimer?.cancel();
    super.onClose();
  }

  void checkAndShowFeedback() {
    //printnt('Checking if feedback should be shown');
    if (_feedbackService.shouldShowFeedback()) {
      //printnt('Feedback should be shown');
      showFeedbackDialog();
    } else {
      //printnt('Feedback should not be shown');
    }
  }

  void showFeedbackDialog() {
    //printnt('Showing feedback dialog');
    _feedbackService.markFeedbackAsShown();
    Get.dialog(
      FeedbackScreen(),
      barrierDismissible: true,
    );
  }

  void setRating(int value) {
    //printnt('Setting rating to $value');
    rating.value = value;
  }

  void updateFeedbackText(String text) {
    //printnt('Updating feedback text to: $text');
    feedbackText.value = text;
  }

  Future<void> submitFeedback() async {
    //printnt('Submitting feedback');
    if (rating.value == 0) {
      //printnt('Rating is required before submitting');
      Get.snackbar(
        'Rating Required',
        'Please provide a rating before submitting',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // Use the current user's email or 'anonymous' if not available
      final userEmail = _storageService.getUserEmail() ?? 'anonymous';
      //printnt('User email: $userEmail');

      // Get the current user ID from Supabase if available
      String userId = 'anonymous';
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        userId = currentUser.id;
      }
      //printnt('User ID: $userId');

      final feedbackData = {
        'user_id': userId,
        'user_email': userEmail,
        'rating': rating.value,
        'feedback': feedbackText.value,
        'created_at': DateTime.now().toIso8601String(),
      };
      // Only add user_email if it's not anonymous (to avoid potential column issues)
      if (userEmail != 'anonymous') {
        feedbackData['user_email'] = userEmail;
      }

      // Submit the feedback
      await Supabase.instance.client.from('user_feedback').insert(feedbackData);

      //printnt('Feedback submitted successfully');
      _feedbackService.markFeedbackAsSubmitted();
      Get.back(); // Close dialog

      Get.snackbar(
        'Thank You!',
        'Your feedback has been submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    } catch (e) {
      //printnt('Error submitting feedback: $e');

      // Try a fallback approach without user_email if that was the issue
      if (e.toString().contains('user_email')) {
        try {
          final userId =
              Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
          await Supabase.instance.client.from('user_feedback').insert({
            'user_id': userId,
            'rating': rating.value,
            'feedback': feedbackText.value,
            'created_at': DateTime.now().toIso8601String(),
          });

          //printnt('Feedback submitted successfully with fallback approach');
          _feedbackService.markFeedbackAsSubmitted();
          Get.back(); // Close dialog

          Get.snackbar(
            'Thank You!',
            'Your feedback has been submitted successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[800],
          );
          return;
        } catch (fallbackError) {
          //printnt('Fallback approach also failed: $fallbackError');
        }
      }

      Get.snackbar(
        'Error',
        'Failed to submit feedback. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isSubmitting.value = false;
      //printnt('Feedback submission process completed');
    }
  }

  void dismissFeedback() {
    //printnt('Dismissing feedback dialog');
    Get.back(); // Close dialog
  }
}
