import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

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
    await _storage.write(onboardingCompletedKey, status);
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

  // Get cache size in MB - optimized for mobile platforms
  Future<double> getCacheSize() async {
    try {
      // For mobile platforms (Android and iOS)
      if (Platform.isAndroid || Platform.isIOS) {
        // Get app cache directory
        final cacheDir = await getTemporaryDirectory();
        
        // Get app documents directory
        final appDocDir = await getApplicationDocumentsDirectory();
        
        // Calculate total size
        final cacheSize = await _calculateDirectorySize(cacheDir);
        final docSize = await _calculateDirectorySize(appDocDir);
        
        // Return total size in MB
        return (cacheSize + docSize) / (1024 * 1024);
      } else {
        // For other platforms, return an estimated value
        return 15.0; // Default estimated value
      }
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0.0;
    }
  }

  // Calculate directory size - optimized for mobile
  Future<int> _calculateDirectorySize(Directory dir) async {
    int totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (final FileSystemEntity entity in dir.list(recursive: true, followLinks: false)) {
          try {
            if (entity is File) {
              totalSize += await entity.length();
            }
          } catch (e) {
            // Skip files that can't be accessed
            print('Skipping file: ${entity.path}');
          }
        }
      }
      return totalSize;
    } catch (e) {
      print('Error calculating directory size: $e');
      return totalSize;
    }
  }

  // Clear cache - optimized for mobile platforms
  Future<void> clearCache() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Clear temp directory
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          // On Android and iOS, we can safely clear the entire temp directory
          final entities = await tempDir.list().toList();
          for (var entity in entities) {
            try {
              if (entity is Directory) {
                await entity.delete(recursive: true);
              } else if (entity is File) {
                await entity.delete();
              }
            } catch (e) {
              print('Could not delete ${entity.path}: $e');
            }
          }
        }
        
        // For Android, also clear the app cache directory
        if (Platform.isAndroid) {
          try {
            final appCacheDir = await getExternalCacheDirectories();
            if (appCacheDir != null) {
              for (var dir in appCacheDir) {
                if (await dir.exists()) {
                  await dir.delete(recursive: true);
                }
              }
            }
          } catch (e) {
            print('Error clearing Android external cache: $e');
          }
        }
      } else {
        // For other platforms, just clear the temp directory
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          try {
            // Create a new directory for app-specific cache
            final appCacheDir = Directory('${tempDir.path}/flutter_cache');
            if (await appCacheDir.exists()) {
              await appCacheDir.delete(recursive: true);
            }
          } catch (e) {
            print('Error clearing cache on non-mobile platform: $e');
          }
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Clear all stored data
  Future<void> clearAllData() async {
    try {
      // Clear all data in GetStorage
      await _storage.erase();
      
      // Clear cache
      await clearCache();
      
      // On Android, clear app data directories
      if (Platform.isAndroid) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final entities = await appDir.list().toList();
          for (var entity in entities) {
            try {
              if (entity is Directory) {
                await entity.delete(recursive: true);
              } else if (entity is File) {
                await entity.delete();
              }
            } catch (e) {
              print('Could not delete ${entity.path}: $e');
            }
          }
        } catch (e) {
          print('Error clearing Android app data: $e');
        }
      }
      
      return;
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }

  // Export user data - optimized for mobile
  Future<void> exportUserData() async {
    try {
      // Create a map to store all data
      final Map<String, dynamic> allData = {};
      
      // Get all keys from GetStorage
      final keys = _storage.getKeys();
      
      // Manually build the map
      for (final key in keys) {
        // Skip sensitive data like passwords
        if (key == userPasswordKey) continue;
        
        // Add the value to our map
        allData[key] = _storage.read(key);
      }
      
      // Add timestamp and device info
      allData['exportDate'] = DateTime.now().toIso8601String();
      allData['platform'] = Platform.operatingSystem;
      allData['version'] = Platform.operatingSystemVersion;
      
      // Convert to JSON
      final String jsonData = jsonEncode(allData);
      
      // Create a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/attendance_app_data_export.json');
      await file.writeAsString(jsonData);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Attendance App Data Export',
      );
      
      return;
    } catch (e) {
      print('Error exporting data: $e');
      rethrow;
    }
  }
}