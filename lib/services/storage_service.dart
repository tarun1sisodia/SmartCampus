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
    //print('Initializing StorageService...');
    await GetStorage.init();
    //print('StorageService initialized.');
    return this;
  }

  // Onboarding
  bool getOnboardingStatus() {
    //print('Getting onboarding status...');
    final status = _storage.read(onboardingCompletedKey) ?? false;
    //print('Onboarding status: $status');
    return status;
  }

  Future<void> setOnboardingStatus(bool status) async {
    //print('Setting onboarding status to $status...');
    await _storage.write(onboardingCompletedKey, status);
    //print('Onboarding status set.');
  }

  // Remember User
  bool getRememberUserStatus() {
    //print('Getting remember user status...');
    final status = _storage.read(rememberUserKey) ?? false;
    //print('Remember user status: $status');
    return status;
  }

  Future<void> setRememberUserStatus(bool status) async {
    //print('Setting remember user status to $status...');
    await _storage.write(rememberUserKey, status);
    //print('Remember user status set.');
  }

  // User Credentials
  Future<void> saveUserCredentials(String email, String password) async {
    //print('Saving user credentials...');
    await _storage.write(userEmailKey, email);
    await _storage.write(userPasswordKey, password);
    //print('User credentials saved.');
  }

  String? getUserEmail() {
    //print('Getting user email...');
    final email = _storage.read(userEmailKey);
    //print('User email: $email');
    return email;
  }

  String? getUserPassword() {
    //print('Getting user password...');
    final password = _storage.read(userPasswordKey);
    //print('User password: $password');
    return password;
  }

  Future<void> clearUserCredentials() async {
    //print('Clearing user credentials...');
    await _storage.remove(userEmailKey);
    await _storage.remove(userPasswordKey);
    //print('User credentials cleared.');
  }

  // Get cache size in MB - optimized for mobile platforms
  Future<double> getCacheSize() async {
    //print('Calculating cache size...');
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final cacheDir = await getTemporaryDirectory();
        final appDocDir = await getApplicationDocumentsDirectory();
        final cacheSize = await _calculateDirectorySize(cacheDir);
        final docSize = await _calculateDirectorySize(appDocDir);
        final totalSize = (cacheSize + docSize) / (1024 * 1024);
        //print('Cache size: $totalSize MB');
        return totalSize;
      } else {
        //print('Returning default cache size for non-mobile platform.');
        return 15.0;
      }
    } catch (e) {
      //print('Error calculating cache size: $e');
      return 0.0;
    }
  }

  // Calculate directory size - optimized for mobile
  Future<int> _calculateDirectorySize(Directory dir) async {
    //print('Calculating size for directory: ${dir.path}');
    int totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (final FileSystemEntity entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          try {
            if (entity is File) {
              final fileSize = await entity.length();
              totalSize += fileSize;
            }
          } catch (e) {
            //print('Skipping file: ${entity.path}');
          }
        }
      }
      //print('Total size for directory ${dir.path}: $totalSize bytes');
      return totalSize;
    } catch (e) {
      //print('Error calculating directory size: $e');
      return totalSize;
    }
  }

  // Clear cache - optimized for mobile platforms
  Future<void> clearCache() async {
    //print('Clearing cache...');
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          final entities = await tempDir.list().toList();
          for (var entity in entities) {
            try {
              if (entity is Directory) {
                await entity.delete(recursive: true);
              } else if (entity is File) {
                await entity.delete();
              }
            } catch (e) {
              //print('Could not delete ${entity.path}: $e');
            }
          }
        }

        if (Platform.isAndroid) {
          final appCacheDir = await getExternalCacheDirectories();
          if (appCacheDir != null) {
            for (var dir in appCacheDir) {
              if (await dir.exists()) {
                await dir.delete(recursive: true);
              }
            }
          }
        }
      } else {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          final appCacheDir = Directory('${tempDir.path}/flutter_cache');
          if (await appCacheDir.exists()) {
            await appCacheDir.delete(recursive: true);
          }
        }
      }
      //print('Cache cleared.');
    } catch (e) {
      //print('Error clearing cache: $e');
    }
  }

  // Clear all stored data
  Future<void> clearAllData() async {
    //print('Clearing all data...');
    try {
      await _storage.erase();
      await clearCache();

      if (Platform.isAndroid) {
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
            //print('Could not delete ${entity.path}: $e');
          }
        }
      }
      //print('All data cleared.');
    } catch (e) {
      //print('Error clearing all data: $e');
      rethrow;
    }
  }

  // Export user data - optimized for mobile
  Future<void> exportUserData() async {
    //print('Exporting user data...');
    try {
      final Map<String, dynamic> allData = {};
      final keys = _storage.getKeys();

      for (final key in keys) {
        if (key == userPasswordKey) continue;
        allData[key] = _storage.read(key);
      }

      allData['exportDate'] = DateTime.now().toIso8601String();
      allData['platform'] = Platform.operatingSystem;
      allData['version'] = Platform.operatingSystemVersion;

      final String jsonData = jsonEncode(allData);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/attendance_app_data_export.json');
      await file.writeAsString(jsonData);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Attendance App Data Export');

      //print('User data exported successfully.');
    } catch (e) {
      //print('Error exporting data: $e');
      rethrow;
    }
  }
}
