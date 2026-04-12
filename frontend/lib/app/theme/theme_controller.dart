import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'theme_configs.dart';
import 'theme.dart';

class ThemeController extends GetxController {
  static ThemeController get instance => Get.find();

  final _storage = GetStorage();
  final String _storageKey = 'selected_theme_index';

  // Observable current theme index
  final RxInt currentThemeIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved theme index or default to 0
    currentThemeIndex.value = _storage.read<int>(_storageKey) ?? 0;
  }

  // Get current theme config
  ThemeConfig get currentConfig => AppThemes.themes[currentThemeIndex.value];

  // Get ThemeData based on current config
  ThemeData get themeData => TAppTheme.createTheme(currentConfig);

  // Change theme and persist
  void setTheme(int index) {
    if (index >= 0 && index < AppThemes.themes.length) {
      currentThemeIndex.value = index;
      _storage.write(_storageKey, index);
      
      // Force UI update
      Get.changeTheme(themeData);
    }
  }

  // Helper to check if current theme is dark
  bool get isDarkMode => currentConfig.isDark;
}
