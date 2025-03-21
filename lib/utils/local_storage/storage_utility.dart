import 'package:get_storage/get_storage.dart';

/// TStorageUtility: A powerful singleton class for local storage operations
/// using GetStorage as the underlying storage mechanism
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

  /// Saves data of any type T to local storage
  /// Usage: await storage.saveData('user_token', 'abc123')
  Future<void> saveData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  /// Reads data of type T from local storage
  /// Usage: final token = storage.readData<String>('user_token')
  T? readData<T>(String key) {
    return _storage.read(key);
  }

  /// Deletes specific data from storage
  /// Usage: await storage.deleteData('user_token', null)
  Future<void> deleteData<T>(String key, T value) async {
    await _storage.remove(key);
  }

  /// Clears all data from storage
  /// Usage: await storage.clearAll()
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
