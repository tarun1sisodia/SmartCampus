// =============================================================
// storage_utility.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/common/utils/local_storage/storage_utility.dart)
// Legacy big localStorage utility (SharedPreferences + files + fake "encryption").
// =============================================================

// class TStorageUtility :
//   saveData<T>(key, value) / removeData(key) / clearAll() -> generic prefs write/delete/clear
//   getString / setString                                -> simple string prefs
//   saveObject / saveObjectList<T>                       -> jsonEncode object/list into prefs
//   saveImage(name, bytes)  -> hash file name, write bytes to the image cache dir, return path
//   getImage(name) / deleteImage(name) -> read / delete cached image file
//   saveThemeMode / saveLanguage / getLanguage -> persist UI settings
//   saveUserProfile / updateUserProfile      -> merge-update a profile map in prefs
//   saveAppSettings / updateAppSettings      -> same for settings map
//   updateLastSyncTime() -> store 'last_sync_<key>' = now
//   getCacheSize()       -> sum size of cache dirs
//   clearCache() -> wipe cache directory
//   _getCacheDirectory / _getImageDirectory / _getDocumentsDirectory -> resolve folders, create if missing
//   _hashFileName(fileName) -> cheap hash of the name used as the stored file name
//   saveDocument/getDocument/deleteDocument -> same pattern as images but for files
//   saveSecureData / getSecureData -> prefs value masked by _encryptString
//   _encryptString / _decryptString -> simple character-shift obfuscation (NOT real crypto)
//   saveOfflineData / clearOfflineData -> jsonEncode offline payloads under a key
//   saveTeacherProfile / getTeacherProfile / updateTeacherProfile -> profile map in prefs + image file
//   getTeacherProfileImage() -> read stored image file
//   saveAttendanceData(classId, sessionId, ...) -> legacy attendance cache in prefs
