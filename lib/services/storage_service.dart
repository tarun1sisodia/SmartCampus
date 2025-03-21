import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  static StorageService get instance => Get.find();
  final _storage = GetStorage();

  // Keys
  static const String onboardingCompletedKey = 'onboardingCompleted';
  static const String rememberUserKey = 'rememberUser';
  static const String userEmailKey = 'userEmail';
  static const String userPasswordKey = 'userPassword';

  // Initialize storage service
  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }

  // Onboarding
  bool getOnboardingStatus() {
    return _storage.read(onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingStatus(bool status) async {
    try {
      await _storage.write(onboardingCompletedKey, status);
    } catch (e) {
      print('Error saving onboarding status: $e');
    }
  }

  // Remember User
  bool getRememberUserStatus() {
    return _storage.read(rememberUserKey) ?? false;
  }

  Future<void> setRememberUserStatus(bool status) async {
    await _storage.write(rememberUserKey, status);
  }

  // User Credentials
  Future<void> saveUserCredentials(String email, String password) async {
    await _storage.write(userEmailKey, email);
    await _storage.write(userPasswordKey, password);
  }

  String? getUserEmail() {
    return _storage.read(userEmailKey);
  }

  String? getUserPassword() {
    return _storage.read(userPasswordKey);
  }

  Future<void> clearUserCredentials() async {
    await _storage.remove(userEmailKey);
    await _storage.remove(userPasswordKey);
  }

  Future<void> clearAllData() async {
    try {
      await _storage.erase();
      print('All stored data cleared successfully');
    } catch (e) {
      print('Error clearing stored data: $e');
    }
  }
}
