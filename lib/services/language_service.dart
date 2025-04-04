import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageService extends GetxService {
  final _storage = GetStorage();
  final _languageKey = 'selected_language';
  
  // Available languages
  final List<Map<String, dynamic>> languages = [
    {
      'name': 'English',
      'locale': const Locale('en', 'US'),
      'code': 'en_US',
    },
    {
      'name': 'Hindi',
      'locale': const Locale('hi', 'IN'),
      'code': 'hi_IN',
    },
    
  ];
  
  // Current language
  final Rx<Locale> currentLocale = Rx<Locale>(const Locale('en', 'US'));
  
  // @override
Future<LanguageService> init() async {
  super.onInit();
  // Load saved language
  final savedLanguage = _storage.read(_languageKey);
  if (savedLanguage != null) {
    final languageMap = languages.firstWhere(
      (lang) => lang['code'] == savedLanguage,
      orElse: () => languages[0],
    );
    currentLocale.value = languageMap['locale'];
    updateLocale(currentLocale.value);
  }
  return this;
}

  // Change language
  void changeLanguage(String languageCode) {
    final languageMap = languages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => languages[0],
    );
    
    final locale = languageMap['locale'] as Locale;
    
    // Save to storage
    _storage.write(_languageKey, languageCode);
    
    // Update app locale
    currentLocale.value = locale;
    updateLocale(locale);
  }
  
  // Update app locale
  void updateLocale(Locale locale) {
    Get.updateLocale(locale);
  }
  
  // Get current language name
  String getCurrentLanguageName() {
    final currentCode = currentLocale.value.toString();
    final languageMap = languages.firstWhere(
      (lang) => lang['locale'].toString() == currentCode,
      orElse: () => languages[0],
    );
    return languageMap['name'];
  }
}
