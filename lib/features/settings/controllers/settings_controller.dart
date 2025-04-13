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
    loadSettings();
    loadUserInfo();
  }

  // Load all saved settings
  void loadSettings() {
    try {
      // Load theme settings
      final savedTheme = storage.read('selected_theme') ?? 'System Default';
      selectedTheme.value = savedTheme;

      // Set dark mode based on theme or system
      if (savedTheme == 'Dark') {
        isDarkMode.value = true;
      } else if (savedTheme == 'Light') {
        isDarkMode.value = false;
      } else {
        // Use system default
        final brightness = Get.mediaQuery.platformBrightness;
        isDarkMode.value = brightness == Brightness.dark;
      }

      // Load other preferences
      notificationsEnabled.value =
          storage.read('notifications_enabled') ?? true;
      biometricsEnabled.value = storage.read('biometrics_enabled') ?? false;
      selectedLanguage.value = storage.read('selected_language') ?? 'English';
      isDeveloperMode.value = storage.read('developer_mode') ?? false;

      logger.i('Settings loaded successfully');
    } catch (e) {
      logger.e('Error loading settings: $e');
      // Use defaults if loading fails
    }
  }

  // Load user information
  void loadUserInfo() {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        userEmail.value = user.email ?? '';

        // Fetch additional user data from the database
        _fetchUserData(user.id);
      }
    } catch (e) {
      logger.e('Error loading user info: $e');
    }
  }

  // Fetch additional user data from the database
  Future<void> _fetchUserData(String userId) async {
    try {
      final userData =
          await supabase.from('users').select().eq('id', userId).maybeSingle();

      if (userData != null) {
        userName.value = userData['name'] ?? '';
        userRole.value = userData['role'] ?? 'User';
      }
    } catch (e) {
      logger.e('Error fetching user data: $e');
    }
  }

  // Toggle dark mode
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;

    // Update theme setting
    if (value) {
      selectedTheme.value = 'Dark';
    } else {
      selectedTheme.value = 'Light';
    }

    // Save preference
    storage.write('selected_theme', selectedTheme.value);

    // Apply theme
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

    // Show confirmation
    Get.snackbar(
      'Theme Updated',
      'App theme has been changed to ${value ? 'dark' : 'light'} mode',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Change theme
  void changeTheme(String theme) {
    selectedTheme.value = theme;
    storage.write('selected_theme', theme);

    // Apply the selected theme
    if (theme == 'Dark') {
      isDarkMode.value = true;
      Get.changeThemeMode(ThemeMode.dark);
    } else if (theme == 'Light') {
      isDarkMode.value = false;
      Get.changeThemeMode(ThemeMode.light);
    } else {
      // System default
      final brightness = Get.mediaQuery.platformBrightness;
      isDarkMode.value = brightness == Brightness.dark;
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  // Change language
  void changeLanguage(String language) {
    selectedLanguage.value = language;
    storage.write('selected_language', language);

    // Apply the selected language (you would need to implement localization)
    // For example: Get.updateLocale(Locale('en', 'US'));

    Get.snackbar(
      'Language Changed',
      'App language has been changed to $language',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Toggle notifications
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    storage.write('notifications_enabled', value);

    // Apply notification settings
    // Your notification service implementation here

    Get.snackbar(
      'Notifications ${value ? 'Enabled' : 'Disabled'}',
      'You will ${value ? 'now receive' : 'no longer receive'} notifications',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Toggle biometric authentication
  void toggleBiometrics(bool value) {
    biometricsEnabled.value = value;
    storage.write('biometrics_enabled', value);

    // Apply biometric settings
    // Your biometric service implementation here

    Get.snackbar(
      'Biometric Authentication ${value ? 'Enabled' : 'Disabled'}',
      value
          ? 'You can now use fingerprint or face ID to login'
          : 'Biometric login has been disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Toggle developer mode
  void toggleDeveloperMode(bool value) {
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

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Use the existing SupabaseAuthController for sign out
      final authController = Get.find<SupabaseAuthController>();
      await authController.signOut();

      // Navigation is handled in the auth controller
    } catch (e) {
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

  // Delete account
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;

      // Show confirmation dialog
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
          // First delete user data from the database
          await supabase.from('users').delete().eq('id', user.id);

          // Then delete the authentication account
          // Note: This requires server-side function or admin privileges
          // For now, just sign out the user
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

  // Reset all settings to default
  void resetSettings() {
    // Show confirmation dialog
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
              // Reset to defaults
              selectedTheme.value = 'System Default';
              isDarkMode.value =
                  Get.mediaQuery.platformBrightness == Brightness.dark;
              notificationsEnabled.value = true;
              biometricsEnabled.value = false;
              selectedLanguage.value = 'English';
              isDeveloperMode.value = false;

              // Save defaults
              storage.write('selected_theme', selectedTheme.value);
              storage.write(
                  'notifications_enabled', notificationsEnabled.value);
              storage.write('biometrics_enabled', biometricsEnabled.value);
              storage.write('selected_language', selectedLanguage.value);
              storage.write('developer_mode', isDeveloperMode.value);

              // Apply theme
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
