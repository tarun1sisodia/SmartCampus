## File 2: `frontend_migration_guide.md`

```markdown
# SmartCampus Flutter Teacher App – Migration from Supabase to Custom Backend

This guide will transform your existing Flutter app (using Supabase) into a **teacher‑only mobile app** connected to the Node.js backend described above.

## 1. Remove Supabase Dependencies

### 1.1 Update `pubspec.yaml`
Remove:
```yaml
supabase_flutter: ^x.x.x
supabase: ^x.x.x
Add:

yaml
dio: ^5.0.0
flutter_secure_storage: ^9.0.0
sqflite: ^2.0.0
path_provider: ^2.0.0
socket_io_client: ^2.0.0  # if using WebSocket
firebase_messaging: ^14.0.0  # for push notifications
1.2 Delete Supabase Initialisation
Remove all Supabase.initialize() and related code from main.dart.

2. Add New Core Services
2.1 Secure Storage Service
File: lib/core/services/secure_storage_service.dart

dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  static Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  static Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  static Future<void> clearTokens() async => await _storage.deleteAll();
}
2.2 API Client (Dio)
File: lib/core/api/api_client.dart

dart
import 'package:dio/dio.dart';
import 'package:smartcampus/core/services/secure_storage_service.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-backend.com/api/v1',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));

  static void addInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.getAccessToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Attempt refresh
          final refreshToken = await SecureStorageService.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
              final newAccess = response.data['data']['accessToken'];
              await SecureStorageService.saveTokens(newAccess, refreshToken);
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              final retry = await _dio.fetch(error.requestOptions);
              return handler.resolve(retry);
            } catch (e) {
              // Refresh failed – logout
              await SecureStorageService.clearTokens();
              // Emit logout event
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  static Dio get dio => _dio;
}
2.3 Offline Sync Service (SQLite)
File: lib/core/services/offline_sync_service.dart

dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineSyncService {
  static Database? _db;

  static Future<void> init() async {
    final path = await getDatabasesPath();
    _db = await openDatabase(join(path, 'attendance.db'), version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE pending_attendance(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sessionId TEXT,
              studentId TEXT,
              status TEXT,
              remarks TEXT,
              timestamp TEXT,
              synced INTEGER DEFAULT 0
            )
          ''');
        });
  }

  static Future<void> addPendingAttendance(Map<String, dynamic> record) async {
    await _db?.insert('pending_attendance', {
      'sessionId': record['sessionId'],
      'studentId': record['studentId'],
      'status': record['status'],
      'remarks': record['remarks'],
      'timestamp': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedRecords() async {
    return await _db?.query('pending_attendance', where: 'synced = 0') ?? [];
  }

  static Future<void> markSynced(int id) async {
    await _db?.update('pending_attendance', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteSyncedRecords() async {
    await _db?.delete('pending_attendance', where: 'synced = 1');
  }
}
3. Rewrite Controllers (Only Keep 9)
Delete these controller files entirely:

supabase_auth_controller.dart

class_controller.dart (teachers don’t manage classes)

student_controller.dart (teachers only view, not edit)

oauth_consent_controller.dart

signup_controller.dart (teachers are invited)

onboarding_controller.dart (can keep UI but remove Supabase calls)

Keep and modify these 9 controllers:

3.1 login_controller.dart
Replace Supabase login with API call:

dart
Future<void> login() async {
  try {
    final response = await ApiClient.dio.post('/auth/login', data: {
      'email': emailController.text,
      'password': passwordController.text,
    });
    final data = response.data['data'];
    await SecureStorageService.saveTokens(data['accessToken'], data['refreshToken']);
    // Navigate to home
  } on DioError catch (e) {
    // Show error
  }
}
3.2 dashboard_controller.dart
Load today’s sessions and teacher stats:

dart
Future<void> loadDashboardData() async {
  final today = DateTime.now().toIso8601String().split('T')[0];
  final sessionsRes = await ApiClient.dio.get('/sessions?date=$today');
  final statsRes = await ApiClient.dio.get('/analytics/teacher/${teacherId}');
  // update Rx variables
}
3.3 attendance_controller.dart & carousel_attendance_controller.dart
Replace Supabase real‑time with HTTP:

dart
Future<void> submitAttendance() async {
  final payload = {
    'sessionId': sessionId,
    'attendance': attendanceList.map((s) => {
      'studentId': s.id,
      'status': s.status,
      'remarks': s.remarks,
    }).toList(),
  };
  try {
    await ApiClient.dio.post('/attendance/mark', data: payload);
    // If offline, store in SQLite
    await OfflineSyncService.addPendingAttendance(payload);
    Get.snackbar('Success', 'Attendance saved');
  } on DioError catch (e) {
    if (e.type == DioErrorType.connectionTimeout) {
      // Save to offline queue
      await OfflineSyncService.addPendingAttendance(payload);
    }
  }
}
3.4 all_sessions_controller.dart
Fetch past sessions:

dart
Future<void> loadAllSessions({int page = 1}) async {
  final res = await ApiClient.dio.get('/sessions?page=$page&limit=20');
  sessions.assignAll(res.data['data']);
}
3.5 session_details_controller.dart
Load session details and allow editing if active:

dart
Future<void> loadSessionDetails(String sessionId) async {
  final res = await ApiClient.dio.get('/attendance/session/$sessionId');
  attendanceRecords.value = res.data['data'];
}
3.6 calendar_controller.dart
Get sessions for a month:

dart
Future<void> loadData(DateTime month) async {
  final yearMonth = '${month.year}-${month.month.toString().padLeft(2,'0')}';
  final res = await ApiClient.dio.get('/sessions/month?month=$yearMonth');
  sessionsForMonth = res.data['data'];
  // Build event markers
}
3.7 teacher_profile_controller.dart
Load profile, update photo, logout:

dart
Future<void> loadUserData() async {
  final res = await ApiClient.dio.get('/users/me');
  user.value = res.data['data'];
}

Future<void> updateProfile() async {
  await ApiClient.dio.patch('/users/me', data: {'name': nameController.text});
}

Future<void> pickAndUploadImage() async {
  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  final formData = FormData.fromMap({
    'photo': await MultipartFile.fromFile(image!.path),
  });
  await ApiClient.dio.post('/users/me/photo', data: formData);
}

Future<void> logout() async {
  await ApiClient.dio.post('/auth/logout');
  await SecureStorageService.clearTokens();
  Get.offAllNamed('/login');
}
3.8 attendance_reports_controller.dart
Fetch teacher’s own analytics:

dart
Future<void> loadAttendanceData() async {
  final res = await ApiClient.dio.get('/analytics/teacher/$teacherId');
  overallPercentage.value = res.data['data']['overallAttendance'];
  subjectWiseList.assignAll(res.data['data']['subjectWise']);
}
4. Remove Supabase Real‑time Subscriptions
Delete any code that uses .on(SupabaseRealtimeEvent). Replace with:

Periodic polling (every 30 seconds) for today’s sessions (simple)

Or WebSocket (see optional section below)

5. Optional: WebSocket for Real‑time Updates
File: lib/core/services/socket_service.dart

dart
import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static Socket? socket;
  static void init(String token) {
    socket = io('https://your-backend.com', OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build());
    socket?.connect();
  }

  static void onAttendanceUpdated(Function(Map) callback) {
    socket?.on('attendance-updated', (data) => callback(data));
  }
}
Call SocketService.init(token) after login. In dashboard_controller, listen to updates and refresh UI.

6. Push Notifications (FCM)
Add Firebase to your Flutter project. Then in main.dart:

dart
await Firebase.initializeApp();
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show local notification
});
// Register token after login
final token = await FirebaseMessaging.instance.getToken();
await ApiClient.dio.post('/notifications/register-token', data: {'fcmToken': token, 'deviceId': deviceId});
7. Testing the Migrated App
Run flutter clean && flutter pub get

Start your backend locally (or staging)

Run the app, log in with a teacher account

Test offline: turn off Wi‑Fi, mark attendance, then turn on – sync should happen automatically (you can add a button or background sync using workmanager).

8. File Cleanup Checklist
Delete lib/controllers/supabase_auth_controller.dart

Delete lib/controllers/class_controller.dart

Delete lib/controllers/student_controller.dart (full)

Delete lib/controllers/signup_controller.dart

Delete lib/controllers/oauth_consent_controller.dart

Modify remaining 9 controllers as per above snippets

Add lib/core/api/ folder with api_client.dart, endpoints.dart

Add lib/core/services/secure_storage_service.dart

Add lib/core/services/offline_sync_service.dart

Update pubspec.yaml dependencies

Run flutter build apk to verify no Supabase references remain

Now your Flutter app is fully migrated and ready to connect to the new Node.js backend.