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

  Box get authBox => Hive.box(authBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);
  Box get cacheBox => Hive.box(cacheBoxName);
  Box get teacherProfileBox => Hive.box(teacherProfileBoxName);
  Box get organisationBox => Hive.box(organisationBoxName);
  Box get sessionCacheBox => Hive.box(sessionCacheBoxName);

  Future<void> clearAll() async {
    await authBox.clear();
    await settingsBox.clear();
    await cacheBox.clear();
    await teacherProfileBox.clear();
    await organisationBox.clear();
    await sessionCacheBox.clear();
  }
}
