import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String authBoxName = 'auth_box';
  static const String settingsBoxName = 'settings_box';
  static const String cacheBoxName = 'cache_box';
  static const String teacherProfileBoxName = 'teacher_profile_box';
  static const String organisationBoxName = 'organisation_box';
  static const String sessionCacheBoxName = 'session_cache_box';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters here once models are created
    // Hive.registerAdapter(UserAdapter());
    
    await openBoxes();
  }

  Future<void> openBoxes() async {
    await Hive.openBox(authBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(cacheBoxName);
    await Hive.openBox(teacherProfileBoxName);
    await Hive.openBox(organisationBoxName);
    await Hive.openBox(sessionCacheBoxName);
  }

  // Generic methods
  T? getData<T>(String boxName, String key, {T? defaultValue}) {
    final box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> putData<T>(String boxName, String key, T value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  Future<void> deleteData(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  Box get authBox => Hive.box(authBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);
  Box get cacheBox => Hive.box(cacheBoxName);
  Box get teacherProfileBox => Hive.box(teacherProfileBoxName);
  Box get organisationBox => Hive.box(organisationBoxName);
  Box get sessionCacheBox => Hive.box(sessionCacheBoxName);

  Future<void> clearAll() async {
    await Hive.box(authBoxName).clear();
    await Hive.box(settingsBoxName).clear();
    await Hive.box(cacheBoxName).clear();
    await Hive.box(teacherProfileBoxName).clear();
    await Hive.box(organisationBoxName).clear();
    await Hive.box(sessionCacheBoxName).clear();
  }
}

