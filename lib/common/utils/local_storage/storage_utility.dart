import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// TStorageUtility: An advanced singleton class for local storage operations
/// using GetStorage as the underlying storage mechanism with extended capabilities
/// for handling complex data types, images, and encrypted sensitive data.
class TStorageUtility {
  // Singleton pattern implementation ensures single instance throughout the app
  static final TStorageUtility _instance = TStorageUtility._internal();

  // Factory constructor returns the singleton instance
  factory TStorageUtility() {
    return _instance;
  }

  // Private constructor for singleton pattern
  TStorageUtility._internal();

  // GetStorage instance for persistent storage operations
  final _storage = GetStorage();

  // Storage keys
  static const String _cacheDirectoryName = 'app_cache';
  static const String _imageDirectoryName = 'profile_images';
  static const String _documentsDirectoryName = 'documents';
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _userProfileKey = 'user_profile';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _appSettingsKey = 'app_settings';

  /// Saves data of any type T to local storage
  /// Usage: await storage.saveData('user_token', 'abc123')
  Future<void> saveData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  /// Reads data of type T from local storage
  /// Usage: final token = storage.readData<String>('user_token')
  T? readData<T>(String key) {
    return _storage.read<T>(key);
  }

  /// Deletes specific data from storage
  /// Usage: await storage.removeData('user_token')
  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  /// Clears all data from storage
  /// Usage: await storage.clearAll()
  Future<void> clearAll() async {
    await _storage.erase();
    await _clearCacheDirectory();
  }

  /// Gets a string value from storage
  /// Usage: final language = storage.getString('language_code')
  String? getString(String key) {
    return readData<String>(key);
  }

  /// Saves a string value to storage
  /// Usage: await storage.setString('language_code', 'en')
  Future<void> setString(String key, String value) async {
    await saveData(key, value);
  }

  /// Saves a complex object by serializing it to JSON
  /// Usage: await storage.saveObject('user_profile', userProfileObject)
  Future<void> saveObject(String key, dynamic object) async {
    if (object == null) return;

    try {
      final jsonString = jsonEncode(object);
      await _storage.write(key, jsonString);
    } catch (e) {
      //printnt('Error saving object to storage: $e');
      rethrow;
    }
  }

  /// Reads a complex object by deserializing from JSON
  /// Usage: final userProfile = storage.readObject('user_profile', (json) => UserProfile.fromJson(json))
  T? readObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final jsonString = _storage.read<String>(key);
      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      //printnt('Error reading object from storage: $e');
      return null;
    }
  }

  /// Saves a list of complex objects
  /// Usage: await storage.saveObjectList('students', studentsList)
  Future<void> saveObjectList<T>(String key, List<T> objects) async {
    try {
      final jsonString = jsonEncode(objects);
      await _storage.write(key, jsonString);
    } catch (e) {
      //printnt('Error saving object list to storage: $e');
      rethrow;
    }
  }

  /// Reads a list of complex objects
  /// Usage: final students = storage.readObjectList('students', (json) => Student.fromJson(json))
  List<T>? readObjectList<T>(
      String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final jsonString = _storage.read<String>(key);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      //printnt('Error reading object list from storage: $e');
      return null;
    }
  }

  /// Saves an image to local storage and returns the file path
  /// Usage: final imagePath = await storage.saveImage('teacher_profile', imageBytes)
  Future<String?> saveImage(String imageName, Uint8List imageBytes) async {
    try {
      final directory = await _getImageDirectory();
      final hashedName = _hashFileName(imageName);
      final filePath = '${directory.path}/$hashedName.jpg';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Save the mapping of original name to file path
      final imagePathsMap =
          readData<Map<dynamic, dynamic>>('image_paths') ?? {};
      imagePathsMap[imageName] = filePath;
      await saveData('image_paths', imagePathsMap);

      return filePath;
    } catch (e) {
      //printnt('Error saving image: $e');
      return null;
    }
  }

  /// Retrieves an image from local storage
  /// Usage: final imageFile = await storage.getImage('teacher_profile')
  Future<File?> getImage(String imageName) async {
    try {
      final imagePathsMap = readData<Map<dynamic, dynamic>>('image_paths');
      if (imagePathsMap == null) return null;

      final filePath = imagePathsMap[imageName];
      if (filePath == null) return null;

      final file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      //printnt('Error retrieving image: $e');
      return null;
    }
  }

  /// Deletes an image from local storage
  /// Usage: await storage.deleteImage('teacher_profile')
  Future<bool> deleteImage(String imageName) async {
    try {
      final imagePathsMap = readData<Map<dynamic, dynamic>>('image_paths');
      if (imagePathsMap == null) return false;

      final filePath = imagePathsMap[imageName];
      if (filePath == null) return false;

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();

        // Update the image paths map
        imagePathsMap.remove(imageName);
        await saveData('image_paths', imagePathsMap);
        return true;
      }
      return false;
    } catch (e) {
      //printnt('Error deleting image: $e');
      return false;
    }
  }

  /// Saves app theme preference
  /// Usage: await storage.saveThemeMode(ThemeMode.dark)
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await saveData(_themeKey, themeMode.index);
  }

  /// Gets app theme preference
  /// Usage: final themeMode = storage.getThemeMode()
  ThemeMode getThemeMode() {
    final themeIndex = readData<int>(_themeKey);
    if (themeIndex == null) return ThemeMode.system;
    return ThemeMode.values[themeIndex];
  }

  /// Saves app language preference
  /// Usage: await storage.saveLanguage('en')
  Future<void> saveLanguage(String languageCode) async {
    await saveData(_languageKey, languageCode);
  }

  /// Gets app language preference
  /// Usage: final language = storage.getLanguage()
  String getLanguage() {
    return readData<String>(_languageKey) ?? 'en';
  }

  /// Saves user profile data
  /// Usage: await storage.saveUserProfile(userProfileMap)
  Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
    await saveData(_userProfileKey, jsonEncode(profileData));
  }

  /// Gets user profile data
  /// Usage: final userProfile = storage.getUserProfile()
  Map<String, dynamic>? getUserProfile() {
    final profileJson = readData<String>(_userProfileKey);
    if (profileJson == null) return null;
    return jsonDecode(profileJson) as Map<String, dynamic>;
  }

  /// Updates specific fields in user profile
  /// Usage: await storage.updateUserProfile({'name': 'New Name'})
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final currentProfile = getUserProfile() ?? {};
    currentProfile.addAll(updates);
    await saveUserProfile(currentProfile);
  }

  /// Saves app settings
  /// Usage: await storage.saveAppSettings({'notifications': true, 'darkMode': false})
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await saveData(_appSettingsKey, jsonEncode(settings));
  }

  /// Gets app settings
  /// Usage: final settings = storage.getAppSettings()
  Map<String, dynamic> getAppSettings() {
    final settingsJson = readData<String>(_appSettingsKey);
    if (settingsJson == null) return {};
    return jsonDecode(settingsJson) as Map<String, dynamic>;
  }

  /// Updates specific app settings
  /// Usage: await storage.updateAppSettings({'notifications': false})
  Future<void> updateAppSettings(Map<String, dynamic> updates) async {
    final currentSettings = getAppSettings();
    currentSettings.addAll(updates);
    await saveAppSettings(currentSettings);
  }

  /// Records last sync timestamp
  /// Usage: await storage.updateLastSyncTime()
  Future<void> updateLastSyncTime() async {
    await saveData(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Gets last sync timestamp
  /// Usage: final lastSync = storage.getLastSyncTime()
  DateTime? getLastSyncTime() {
    final timestamp = readData<int>(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Calculates cache size in MB
  /// Usage: final cacheSize = await storage.getCacheSize()
  Future<double> getCacheSize() async {
    try {
      final directory = await _getCacheDirectory();
      int totalSize = 0;

      if (await directory.exists()) {
        await for (final FileSystemEntity entity
            in directory.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      // Convert bytes to MB
      return totalSize / (1024 * 1024);
    } catch (e) {
      //printnt('Error calculating cache size: $e');
      return 0.0;
    }
  }

  /// Clears the cache directory
  /// Usage: await storage.clearCache()
  Future<void> clearCache() async {
    await _clearCacheDirectory();
  }

  // Helper method to get or create the cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDirectoryName');

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  // Helper method to get or create the image directory
  Future<Directory> _getImageDirectory() async {
    final cacheDir = await _getCacheDirectory();
    final imageDir = Directory('${cacheDir.path}/$_imageDirectoryName');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    return imageDir;
  }

  // Helper method to get or create the documents directory
  Future<Directory> _getDocumentsDirectory() async {
    final cacheDir = await _getCacheDirectory();
    final docsDir = Directory('${cacheDir.path}/$_documentsDirectoryName');

    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }

    return docsDir;
  }

  // Helper method to clear the cache directory
  Future<void> _clearCacheDirectory() async {
    try {
      final directory = await _getCacheDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create(recursive: true);
      }
    } catch (e) {
      //printnt('Error clearing cache directory: $e');
    }
  }

  // Helper method to hash filenames for security and consistency
  String _hashFileName(String fileName) {
    final bytes = utf8.encode(fileName);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Saves a document file and returns the file path
  /// Usage: final docPath = await storage.saveDocument('syllabus', docBytes, 'pdf')
  Future<String?> saveDocument(
      String docName, Uint8List docBytes, String extension) async {
    try {
      final directory = await _getDocumentsDirectory();
      final hashedName = _hashFileName(docName);
      final filePath = '${directory.path}/$hashedName.$extension';

      final file = File(filePath);
      await file.writeAsBytes(docBytes);

      // Save the mapping of original name to file path
      final docPathsMap =
          readData<Map<dynamic, dynamic>>('document_paths') ?? {};
      docPathsMap[docName] = filePath;
      await saveData('document_paths', docPathsMap);

      return filePath;
    } catch (e) {
      //printnt('Error saving document: $e');
      return null;
    }
  }

  /// Retrieves a document from local storage
  /// Usage: final docFile = await storage.getDocument('syllabus')
  Future<File?> getDocument(String docName) async {
    try {
      final docPathsMap = readData<Map<dynamic, dynamic>>('document_paths');
      if (docPathsMap == null) return null;

      final filePath = docPathsMap[docName];
      if (filePath == null) return null;

      final file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      //printnt('Error retrieving document: $e');
      return null;
    }
  }

  /// Deletes a document from local storage
  /// Usage: await storage.deleteDocument('syllabus')
  Future<bool> deleteDocument(String docName) async {
    try {
      final docPathsMap = readData<Map<dynamic, dynamic>>('document_paths');
      if (docPathsMap == null) return false;

      final filePath = docPathsMap[docName];
      if (filePath == null) return false;

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();

        // Update the document paths map
        docPathsMap.remove(docName);
        await saveData('document_paths', docPathsMap);
        return true;
      }
      return false;
    } catch (e) {
      //printnt('Error deleting document: $e');
      return false;
    }
  }

  /// Saves encrypted sensitive data
  /// Usage: await storage.saveSecureData('api_key', 'secret_key_value')
  Future<void> saveSecureData(String key, String value) async {
    try {
      // Simple encryption - in a real app, use a proper encryption library
      final encrypted = _encryptString(value);
      await saveData('secure_$key', encrypted);
    } catch (e) {
      //printnt('Error saving secure data: $e');
      rethrow;
    }
  }

  /// Retrieves and decrypts sensitive data
  /// Usage: final apiKey = storage.getSecureData('api_key')
  String? getSecureData(String key) {
    try {
      final encrypted = readData<String>('secure_$key');
      if (encrypted == null) return null;

      return _decryptString(encrypted);
    } catch (e) {
      //printnt('Error retrieving secure data: $e');
      return null;
    }
  }

  // Simple encryption/decryption methods
  // Note: For production, use a proper encryption library like encrypt or flutter_secure_storage
  String _encryptString(String input) {
    // This is a very basic XOR encryption - not secure for production
    final key = 'AttendanceAppSecretKey';
    final result = StringBuffer();

    for (var i = 0; i < input.length; i++) {
      final inputChar = input.codeUnitAt(i);
      final keyChar = key.codeUnitAt(i % key.length);
      result.writeCharCode(inputChar ^ keyChar);
    }

    return base64Encode(utf8.encode(result.toString()));
  }

  String _decryptString(String encrypted) {
    // Matching decryption for the above encryption
    final key = 'AttendanceAppSecretKey';
    final decoded = utf8.decode(base64Decode(encrypted));
    final result = StringBuffer();

    for (var i = 0; i < decoded.length; i++) {
      final encChar = decoded.codeUnitAt(i);
      final keyChar = key.codeUnitAt(i % key.length);
      result.writeCharCode(encChar ^ keyChar);
    }

    return result.toString();
  }

  /// Saves offline data for sync later
  /// Usage: await storage.saveOfflineData('attendance_records', recordsList)
  Future<void> saveOfflineData(
      String key, List<Map<String, dynamic>> data) async {
    try {
      final existingData = getOfflineData(key) ?? [];
      existingData.addAll(data);

      await saveData('offline_$key', jsonEncode(existingData));
    } catch (e) {
      //printnt('Error saving offline data: $e');
      rethrow;
    }
  }

  /// Gets offline data for syncing
  /// Usage: final offlineRecords = storage.getOfflineData('attendance_records')
  List<Map<String, dynamic>>? getOfflineData(String key) {
    try {
      final jsonString = readData<String>('offline_$key');
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      //printnt('Error retrieving offline data: $e');
      return null;
    }
  }

  /// Clears offline data after successful sync
  /// Usage: await storage.clearOfflineData('attendance_records')
  Future<void> clearOfflineData(String key) async {
    await removeData('offline_$key');
  }

  /// Saves a teacher profile with all related data
  /// Usage: await storage.saveTeacherProfile(teacherData, profileImageBytes)
  Future<void> saveTeacherProfile(
      Map<String, dynamic> teacherData, Uint8List? profileImageBytes) async {
    try {
      // Save profile image if provided
      if (profileImageBytes != null) {
        final teacherId = teacherData['id']?.toString() ?? 'default';
        final imagePath =
            await saveImage('teacher_profile_$teacherId', profileImageBytes);

        if (imagePath != null) {
          teacherData['profile_image_path'] = imagePath;
        }
      }

      // Save teacher data
      await saveData('teacher_profile', jsonEncode(teacherData));
    } catch (e) {
      //printnt('Error saving teacher profile: $e');
      rethrow;
    }
  }

  /// Gets teacher profile data including image
  /// Usage: final teacherProfile = await storage.getTeacherProfile()
  Future<Map<String, dynamic>?> getTeacherProfile() async {
    try {
      final profileJson = readData<String>('teacher_profile');
      if (profileJson == null) return null;

      final profileData = jsonDecode(profileJson) as Map<String, dynamic>;

      // Get profile image if available
      final imagePath = profileData['profile_image_path'];
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          // We don't include the actual image bytes in the returned map
          // but confirm the image exists
          profileData['has_profile_image'] = true;
        } else {
          profileData['has_profile_image'] = false;
        }
      }

      return profileData;
    } catch (e) {
      //printnt('Error retrieving teacher profile: $e');
      return null;
    }
  }

  /// Gets teacher profile image as a File
  /// Usage: final imageFile = await storage.getTeacherProfileImage()
  Future<File?> getTeacherProfileImage() async {
    try {
      final profileData = await getTeacherProfile();
      if (profileData == null) return null;

      final imagePath = profileData['profile_image_path'];
      if (imagePath == null) return null;

      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return imageFile;
      }
      return null;
    } catch (e) {
      //printnt('Error retrieving teacher profile image: $e');
      return null;
    }
  }

  /// Updates teacher profile data
  /// Usage: await storage.updateTeacherProfile(updatedData, newProfileImageBytes)
  Future<void> updateTeacherProfile(
      Map<String, dynamic> updates, Uint8List? newProfileImageBytes) async {
    try {
      final currentProfile = await getTeacherProfile() ?? {};

      // Update with new data
      currentProfile.addAll(updates);

      // Update profile image if provided
      if (newProfileImageBytes != null) {
        final teacherId = currentProfile['id']?.toString() ?? 'default';
        final imagePath =
            await saveImage('teacher_profile_$teacherId', newProfileImageBytes);

        if (imagePath != null) {
          currentProfile['profile_image_path'] = imagePath;
        }
      }

      // Save updated profile
      await saveData('teacher_profile', jsonEncode(currentProfile));
    } catch (e) {
      //printnt('Error updating teacher profile: $e');
      rethrow;
    }
  }

  /// Saves attendance data for offline use
  /// Usage: await storage.saveAttendanceData(classId, sessionId, attendanceList)
  Future<void> saveAttendanceData(String classId, String sessionId,
      List<Map<String, dynamic>> attendanceData) async {
    try {
      final key = 'attendance_${classId}_$sessionId';
      await saveData(key, jsonEncode(attendanceData));

      // Also save to offline data for syncing
      await saveOfflineData('pending_attendance', [
        {
          'class_id': classId,
          'session_id': sessionId,
          'attendance_data': attendanceData,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ]);
    } catch (e) {
      //printnt('Error saving attendance data: $e');
      rethrow;
    }
  }

  /// Gets attendance data for a specific class and session
  /// Usage: final attendanceData = storage.getAttendanceData(classId, sessionId)
  List<Map<String, dynamic>>? getAttendanceData(
      String classId, String sessionId) {
    try {
      final key = 'attendance_${classId}_$sessionId';
      final jsonString = readData<String>(key);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      //printnt('Error retrieving attendance data: $e');
      return null;
    }
  }

  /// Gets all pending attendance data that needs to be synced
  /// Usage: final pendingData = storage.getPendingAttendanceData()
  List<Map<String, dynamic>>? getPendingAttendanceData() {
    return getOfflineData('pending_attendance');
  }

  /// Marks attendance data as synced
  /// Usage: await storage.markAttendanceAsSynced(classId, sessionId)
  Future<void> markAttendanceAsSynced(String classId, String sessionId) async {
    try {
      final pendingData = getPendingAttendanceData() ?? [];
      final updatedPendingData = pendingData
          .where((item) =>
              item['class_id'] != classId || item['session_id'] != sessionId)
          .toList();

      if (updatedPendingData.length < pendingData.length) {
        await saveData(
            'offline_pending_attendance', jsonEncode(updatedPendingData));
      }
    } catch (e) {
      //printnt('Error marking attendance as synced: $e');
      rethrow;
    }
  }
}
