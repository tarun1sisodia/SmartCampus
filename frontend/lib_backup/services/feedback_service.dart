import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FeedbackService extends GetxService {
  final GetStorage _storage = GetStorage();
  
  // Keys for storage
  static const String _hasFeedbackBeenShownKey = 'has_feedback_been_shown';
  static const String _hasFeedbackBeenSubmittedKey = 'has_feedback_been_submitted';
  static const String _firstAppOpenTimeKey = 'first_app_open_time';
  
  // Time delay before showing feedback (in minutes)
  static const int _feedbackDelayMinutes = 5;
  
  Future<FeedbackService> init() async {
    // Initialize first app open time if not set
    if (!_storage.hasData(_firstAppOpenTimeKey)) {
      _storage.write(_firstAppOpenTimeKey, DateTime.now().millisecondsSinceEpoch);
    }
    return this;
  }
  
  bool get hasFeedbackBeenShown => _storage.read(_hasFeedbackBeenShownKey) ?? false;
  
  bool get hasFeedbackBeenSubmitted => _storage.read(_hasFeedbackBeenSubmittedKey) ?? false;
  
  void markFeedbackAsShown() {
    _storage.write(_hasFeedbackBeenShownKey, true);
  }
  
  void markFeedbackAsSubmitted() {
    _storage.write(_hasFeedbackBeenSubmittedKey, true);
  }
  
  bool shouldShowFeedback() {
    // If feedback has been shown or submitted, don't show it again
    if (hasFeedbackBeenShown || hasFeedbackBeenSubmitted) {
      return false;
    }
    
    // Check if enough time has passed since first app open
    final firstOpenTime = _storage.read(_firstAppOpenTimeKey) ?? DateTime.now().millisecondsSinceEpoch;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedMinutes = (currentTime - firstOpenTime) / (1000 * 60);
    
    return elapsedMinutes >= _feedbackDelayMinutes;
  }
  
  void resetFeedbackStatus() {
    // For testing purposes
    _storage.remove(_hasFeedbackBeenShownKey);
    _storage.remove(_hasFeedbackBeenSubmittedKey);
    _storage.write(_firstAppOpenTimeKey, DateTime.now().millisecondsSinceEpoch);
  }
}
