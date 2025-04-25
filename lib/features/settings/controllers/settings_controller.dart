import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../features/authentication/controllers/supabase_auth_controller.dart';

class SettingsController extends GetxController {
  // Dependencies
  final logger = Logger();
  final supabase = Supabase.instance.client;
  final storage = GetStorage();

  // Observable variables
  final isDarkMode = false.obs;
  final isLoading = false.obs;
  final isDeveloperMode = false.obs;
  final notificationsEnabled = true.obs;
  final biometricsEnabled = false.obs;
  final selectedLanguage = 'English'.obs;
  final selectedTheme = 'System Default'.obs;

  // Available options
  final List<String> availableLanguages = [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German'
  ];
  final List<String> availableThemes = ['System Default', 'Light', 'Dark'];

  // User information
  final userEmail = ''.obs;
  final userName = ''.obs;
  final userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    //printnt('onInit called');
    loadSettings();
    loadUserInfo();
  }

  // Load all saved settings
  void loadSettings() {
    try {
      //printnt('Loading settings...');
      final savedTheme = storage.read('selected_theme') ?? 'System Default';
      selectedTheme.value = savedTheme;
      //printnt('Saved theme: $savedTheme');

      if (savedTheme == 'Dark') {
        isDarkMode.value = true;
      } else if (savedTheme == 'Light') {
        isDarkMode.value = false;
      } else {
        final brightness = Get.mediaQuery.platformBrightness;
        isDarkMode.value = brightness == Brightness.dark;
      }

      notificationsEnabled.value =
          storage.read('notifications_enabled') ?? true;
      biometricsEnabled.value = storage.read('biometrics_enabled') ?? false;
      selectedLanguage.value = storage.read('selected_language') ?? 'English';
      isDeveloperMode.value = storage.read('developer_mode') ?? false;

      //printnt('Settings loaded: $selectedTheme, $isDarkMode, $notificationsEnabled, $biometricsEnabled, $selectedLanguage, $isDeveloperMode');
      logger.i('Settings loaded successfully');
    } catch (e) {
      //printnt('Error loading settings: $e');
      logger.e('Error loading settings: $e');
    }
  }

  // Load user information
  void loadUserInfo() {
    try {
      //printnt('Loading user info...');
      final user = supabase.auth.currentUser;
      if (user != null) {
        userEmail.value = user.email ?? '';
        //printnt('User email: ${userEmail.value}');
        _fetchUserData(user.id);
      }
    } catch (e) {
      //printnt('Error loading user info: $e');
      logger.e('Error loading user info: $e');
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      //printnt('Fetching user data for userId: $userId');
      final userData =
          await supabase.from('users').select().eq('id', userId).maybeSingle();

      if (userData != null) {
        userName.value = userData['name'] ?? '';
        userRole.value = userData['role'] ?? 'User';
        //printnt('User data fetched: $userName, $userRole');
      }
    } catch (e) {
      //printnt('Error fetching user data: $e');
      logger.e('Error fetching user data: $e');
    }
  }

  void toggleDarkMode(bool value) {
    //printnt('Toggling dark mode to: $value');
    isDarkMode.value = value;

    if (value) {
      selectedTheme.value = 'Dark';
    } else {
      selectedTheme.value = 'Light';
    }

    storage.write('selected_theme', selectedTheme.value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

    Get.snackbar(
      'Theme Updated',
      'App theme has been changed to ${value ? 'dark' : 'light'} mode',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void changeTheme(String theme) {
    //printnt('Changing theme to: $theme');
    selectedTheme.value = theme;
    storage.write('selected_theme', theme);

    if (theme == 'Dark') {
      isDarkMode.value = true;
      Get.changeThemeMode(ThemeMode.dark);
    } else if (theme == 'Light') {
      isDarkMode.value = false;
      Get.changeThemeMode(ThemeMode.light);
    } else {
      final brightness = Get.mediaQuery.platformBrightness;
      isDarkMode.value = brightness == Brightness.dark;
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  void changeLanguage(String language) {
    //printnt('Changing language to: $language');
    selectedLanguage.value = language;
    storage.write('selected_language', language);

    Get.snackbar(
      'Language Changed',
      'App language has been changed to $language',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleNotifications(bool value) {
    //printnt('Toggling notifications to: $value');
    notificationsEnabled.value = value;
    storage.write('notifications_enabled', value);

    Get.snackbar(
      'Notifications ${value ? 'Enabled' : 'Disabled'}',
      'You will ${value ? 'now receive' : 'no longer receive'} notifications',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleBiometrics(bool value) {
    //printnt('Toggling biometrics to: $value');
    biometricsEnabled.value = value;
    storage.write('biometrics_enabled', value);

    Get.snackbar(
      'Biometric Authentication ${value ? 'Enabled' : 'Disabled'}',
      value
          ? 'You can now use fingerprint or face ID to login'
          : 'Biometric login has been disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleDeveloperMode(bool value) {
    //printnt('Toggling developer mode to: $value');
    isDeveloperMode.value = value;
    storage.write('developer_mode', value);

    if (value) {
      Get.snackbar(
        'Developer Mode Enabled',
        'AI testing tools and advanced features are now available',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: TColors.primary.withOpacity(0.1),
      );
    } else {
      Get.snackbar(
        'Developer Mode Disabled',
        'Developer features have been turned off',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> signOut() async {
    try {
      //printnt('Signing out...');
      isLoading.value = true;

      final authController = Get.find<SupabaseAuthController>();
      await authController.signOut();
    } catch (e) {
      //printnt('Error signing out: $e');
      logger.e('Error signing out: $e');
      Get.snackbar(
        'Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      //printnt('Deleting account...');
      isLoading.value = true;

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          await supabase.from('users').delete().eq('id', user.id);

          final authController = Get.find<SupabaseAuthController>();
          await authController.signOut();

          Get.snackbar(
            'Account Deleted',
            'Your account has been permanently deleted',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      //printnt('Error deleting account: $e');
      logger.e('Error deleting account: $e');
      Get.snackbar(
        'Error',
        'Failed to delete account: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetSettings() {
    //printnt('Resetting settings...');
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              selectedTheme.value = 'System Default';
              isDarkMode.value =
                  Get.mediaQuery.platformBrightness == Brightness.dark;
              notificationsEnabled.value = true;
              biometricsEnabled.value = false;
              selectedLanguage.value = 'English';
              isDeveloperMode.value = false;

              storage.write('selected_theme', selectedTheme.value);
              storage.write(
                  'notifications_enabled', notificationsEnabled.value);
              storage.write('biometrics_enabled', biometricsEnabled.value);
              storage.write('selected_language', selectedLanguage.value);
              storage.write('developer_mode', isDeveloperMode.value);

              Get.changeThemeMode(ThemeMode.system);

              Get.back();
              Get.snackbar(
                'Settings Reset',
                'All settings have been reset to default values',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
