import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String authBoxName = 'auth_box';
  static const String settingsBoxName = 'settings_box';
  static const String cacheBoxName = 'cache_box';

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
  }

  Box get authBox => Hive.box(authBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);
  Box get cacheBox => Hive.box(cacheBoxName);

  Future<void> clearAll() async {
    await authBox.clear();
    await settingsBox.clear();
    await cacheBox.clear();
  }
}
