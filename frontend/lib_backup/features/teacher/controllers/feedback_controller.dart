import 'dart:async';

import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../common/utils/helpers/snackbar_helper.dart';
import '../../../services/feedback_service.dart';
import '../../../services/storage_service.dart';
import '../screens/feedback_screen.dart';

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
    Get.dialog(FeedbackScreen(), barrierDismissible: true);
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
    if (rating.value == 0) {
      TSnackBar.showWarning(message: 'Please provide a rating before submitting');
      return;
    }

    isSubmitting.value = true;
    try {
      await ApiClient.dio.post('/feedback', data: {
        'rating': rating.value,
        'feedback': feedbackText.value,
      });

      _feedbackService.markFeedbackAsSubmitted();
      Get.back();
      TSnackBar.showSuccess(message: 'Your feedback has been submitted successfully.', title: 'Thank You!');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      TSnackBar.showError(message: 'Failed to submit feedback. Please try again later.');
    } finally {
      isSubmitting.value = false;
    }
  }

  void dismissFeedback() {
    //printnt('Dismissing feedback dialog');
    Get.back(); // Close dialog
  }
}
