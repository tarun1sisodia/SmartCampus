// =============================================================
// hive_service.dart  ->  ALGORITHM ONLY (source: frontend/lib/core/cache/hive_service.dart)
// Hive = fast key-value cache storage.
// =============================================================

// class HiveService :
//   box names (constants): auth_box, settings_box, cache_box, teacher_profile_box, organisation_box, session_cache_box

// init() :
//   Hive.initFlutter() -> prepare Hive for the app
//   (adapters for typed models would be registered here)
//   openBoxes()

// openBoxes() : open all 6 boxes so they are ready for read/write

// generic helpers:
//   getData(box, key, default)   -> read value from a box
//   putData(box, key, value)     -> write value to a box
//   deleteData(box, key)         -> delete one key from a box
//   getters authBox/settingsBox/cacheBox/... -> direct access to each open box

// clearAll() : clear the content of every box (used on logout / debug)
