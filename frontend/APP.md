SmartCampus Flutter Teacher App – Complete File‑by‑File Structure & Algorithms
This document defines every file needed for the Flutter teacher app, with step‑by‑step algorithms in plain English. An AI can use this to generate the actual code with minimal hallucination.

1. Project Folder Tree (Standardized - Implemented)
text
lib/
├── main.dart (Done)
├── app/ (Done)
│   ├── app.dart (Done)
│   ├── routes.dart (Refactored - Done)
│   ├── theme.dart (Done)
│   └── dependency_injection.dart (Done)
├── core/ (Done)
│   ├── api/ (Done)
│   │   ├── api_client.dart (Done)
│   │   ├── endpoints.dart (Done)
│   │   ├── token_interceptor.dart (Done)
│   │   └── refresh_token_interceptor.dart (Done)
│   ├── cache/ (Done)
│   │   ├── hive_service.dart (Done)
│   │   ├── hive_adapters.dart (Done)
│   │   └── cache_keys.dart (Done)
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── dao/
│   │   │   ├── pending_attendance_dao.dart
│   │   │   └── session_cache_dao.dart
│   │   └── database_migrations.dart
│   ├── services/
│   │   ├── connectivity_service.dart
│   │   ├── sync_service.dart
│   │   ├── notification_service.dart
│   │   ├── biometric_service.dart
│   │   └── background_task_service.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── error_handler.dart
│   │   ├── logger.dart
│   │   ├── image_url_builder.dart
│   │   └── validators.dart
│   └── constants/
│       ├── app_constants.dart
│       └── api_constants.dart
├── features/ (Standardized - Implemented)
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   ├── auth_state.dart
│   │   │   └── auth_repository.dart
│   │   ├── views/
│   │   │   ├── login_screen.dart
│   │   │   ├── biometric_prompt_dialog.dart
│   │   │   └── forgot_password_screen.dart
│   │   └── models/
│   │       └── user_model.dart
│   ├── home/
│   │   ├── bloc/
│   │   │   ├── home_bloc.dart
│   │   │   ├── home_event.dart
│   │   │   ├── home_state.dart
│   │   │   └── home_repository.dart
│   │   ├── views/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── session_card.dart
│   │   │       └── stats_overview.dart
│   │   └── models/
│   │       └── session_model.dart
│   ├── session/
│   │   ├── bloc/
│   │   │   ├── session_bloc.dart
│   │   │   ├── session_event.dart
│   │   │   ├── session_state.dart
│   │   │   └── session_repository.dart
│   │   ├── views/
│   │   │   ├── session_detail_screen.dart
│   │   │   ├── session_history_screen.dart
│   │   │   └── widgets/
│   │   │       ├── session_info_header.dart
│   │   │       └── attendance_summary_card.dart
│   │   └── models/
│   │       └── session_detail_model.dart
│   ├── attendance/
│   │   ├── bloc/
│   │   │   ├── attendance_bloc.dart
│   │   │   ├── attendance_event.dart
│   │   │   ├── attendance_state.dart
│   │   │   └── attendance_repository.dart
│   │   ├── views/
│   │   │   ├── carousel_attendance_screen.dart
│   │   │   ├── attendance_summary_screen.dart
│   │   │   └── widgets/
│   │   │       ├── student_carousel_card.dart
│   │   │       ├── status_button.dart
│   │   │       └── offline_banner.dart
│   │   └── models/
│   │       └── attendance_record_model.dart
│   ├── analytics/
│   │   ├── bloc/
│   │   │   ├── analytics_bloc.dart
│   │   │   ├── analytics_event.dart
│   │   │   ├── analytics_state.dart
│   │   │   └── analytics_repository.dart
│   │   ├── views/
│   │   │   ├── analytics_screen.dart
│   │   │   └── widgets/
│   │   │       ├── attendance_percentage_chart.dart
│   │   │       └── subject_wise_list.dart
│   │   └── models/
│   │       └── teacher_stats_model.dart
│   └── profile/
│       ├── bloc/
│       │   ├── profile_bloc.dart
│       │   ├── profile_event.dart
│       │   ├── profile_state.dart
│       │   └── profile_repository.dart
│       ├── views/
│       │   ├── profile_screen.dart
│       │   └── widgets/
│       │       ├── profile_photo_picker.dart
│       │       └── change_password_form.dart
│       └── models/
│           └── profile_model.dart
├── shared/ (Implemented)
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   ├── shimmer_loading.dart
│   │   ├── network_image_with_placeholder.dart
│   │   └── confirmation_dialog.dart
│   └── mixins/
│       ├── connectivity_mixin.dart
│       └── keyboard_dismiss_mixin.dart
└── env/ (Implemented)
    ├── env_config.dart
    └── env_dev.dart / env_prod.dart (generated via --dart-define)
2. Core File Algorithms (Plain English)
2.1 lib/main.dart (Implemented - Done)
Algorithm:

Call WidgetsFlutterBinding.ensureInitialized().

Load environment configuration (API URL, feature flags) from --dart-define.

Initialize Hive (register adapters, open boxes).

Initialize SQLite database (create tables if not exist).

Initialize Firebase (for push notifications) – if enabled.

Register dependency injection (GetIt or injectable) with all repositories, services, and Blocs.

Run App() widget.

2.2 lib/app/app.dart (Implemented - Done)
Algorithm:

Build MaterialApp.router (or MaterialApp with named routes).

Set theme and darkTheme from ThemeData defined in theme.dart.

Define routerConfig (GoRouter) – see routes.dart.

Wrap with MultiBlocProvider (provide all Blocs from DI container).

Add OverlaySupport for toasts/dialogs.

Set navigatorKey for global navigation (e.g., from sync service).

Add Sentry or FirebaseCrashlytics observers.

2.3 lib/app/routes.dart (Implemented - Done)
Algorithm:

Define GoRouter with initialLocation = '/login'.

Define routes:

/login → LoginScreen

/home → HomeScreen (protected, requires auth)

/session/:sessionId → SessionDetailScreen

/sessions/history → SessionHistoryScreen

/attendance/:sessionId → CarouselAttendanceScreen

/analytics → AnalyticsScreen

/profile → ProfileScreen

Add redirect guard: if user is not authenticated and not on /login, redirect to /login. If authenticated and on /login, redirect to /home.

Use refreshListenable (AuthBloc stream) to rebuild redirect when auth state changes.

2.4 lib/core/api/api_client.dart (Implemented - Done)
Algorithm:

Create a Dio singleton.

Set baseUrl from environment.

Set connectTimeout (30s) and receiveTimeout (30s).

Add TokenInterceptor and RefreshTokenInterceptor (order matters).

Add LogInterceptor in debug mode only.

Expose Dio instance via a getter.

2.5 lib/core/api/token_interceptor.dart
Algorithm:

On request, retrieve access token from flutter_secure_storage.

If token exists, add header: Authorization: Bearer $token.

Pass request.

2.6 lib/core/api/refresh_token_interceptor.dart
Algorithm:

On error, check if status code is 401 and the request is not already a refresh attempt.

If true, call refreshToken() endpoint using stored refresh token.

On success, store new access token, update the original request header, and retry.

On failure, clear all tokens and emit AuthLogout event (via Bloc or global event bus).

2.7 lib/core/database/app_database.dart
Algorithm:

Define a singleton DatabaseHelper class.

On init, call openDatabase() with path, version, and onCreate/onUpgrade.

Create tables:

pending_attendance (id, sessionId, studentId, status, remarks, timestamp, synced)

cached_sessions (sessionId, jsonData, expiry)

Expose database getter.

Provide methods: insert, query, update, delete with transaction support.

2.8 lib/core/services/sync_service.dart
Algorithm:

On app start, check for unsynced attendance records in SQLite.

If online, batch them (max 50 per request) and send to POST /api/v1/attendance/sync.

On success, delete synced records from SQLite.

On failure, keep and retry on next sync attempt (exponential backoff).

Expose startPeriodicSync() to schedule background task via BackgroundTaskService.

2.9 lib/features/auth/bloc/auth_bloc.dart (Implemented - Done)
Algorithm – State transitions:

AuthInitial → AuthLoading on AuthLoginRequested

On success → AuthAuthenticated (store tokens, user)

On failure → AuthError

On AuthLogoutRequested → clear tokens, emit AuthUnauthenticated

2.10 lib/features/attendance/bloc/attendance_bloc.dart (Implemented - Done)
Algorithm – Mark attendance:

AttendanceMarkRequested event contains sessionId, studentId, status.

Check connectivity via ConnectivityService.

If online:

Call API POST /attendance/mark.

On success: emit AttendanceMarkedSuccess and refresh UI.

On failure: emit AttendanceError.

If offline:

Insert into pending_attendance table with current timestamp.

Emit AttendanceOfflineSaved (show toast “Saved offline”).

Also add to local queue for later sync.

3. Detailed File Algorithms for Each Feature
3.1 Authentication Feature
auth_repository.dart
Algorithm:

login(email, password) → call POST /auth/login, return tokens + user.

refreshToken(refreshToken) → call POST /auth/refresh, return new access token.

logout() → call POST /auth/logout, ignore errors.

forgotPassword(email) → call POST /auth/forgot-password.

resetPassword(token, newPassword) → call POST /auth/reset-password.

login_screen.dart
Algorithm:

Show email + password text fields.

On submit, add AuthLoginRequested event to AuthBloc.

Listen to state changes: on AuthAuthenticated, navigate to /home.

On AuthError, show error dialog.

Provide “Forgot Password” link → navigate to ForgotPasswordScreen.

Optional “Biometric Login” button – call BiometricService.authenticate().

3.2 Home Feature
home_repository.dart
Algorithm:

fetchTodaySessions(teacherId) → call GET /sessions?teacherId=...&date=today.

Cache result in Hive with key today_sessions_${teacherId} + expiry at next midnight.

home_bloc.dart
Algorithm:

On HomeLoadRequested, first check cache (Hive) for today’s sessions.

If cache exists and not expired → emit HomeLoaded with cached data.

If cache expired or missing, fetch from API.

While fetching, emit HomeLoading.

On API success, update cache and emit HomeLoaded.

On error, emit HomeError and optionally fallback to stale cache.

3.3 Attendance Carousel
attendance_repository.dart
Algorithm:

markAttendance(sessionId, attendanceList) → call POST /attendance/mark.

syncOffline(pendingList) → call POST /attendance/sync.

carousel_attendance_screen.dart
Algorithm:

Receive sessionId as argument.

Load students for this session (via AttendanceBloc).

Use PageView.builder to show one student per page.

Each page shows:

Student photo (using NetworkImageWithPlaceholder with Cloudinary optimisation)

Name, roll number

Three status buttons (Present/Absent/Late)

On status tap, add AttendanceMarkRequested to Bloc.

Show progress indicator at top (e.g., 5/30 marked).

After all students marked, show “Submit” button → calls submitAllPending().

If offline, store locally and show “Saved offline” badge.

3.4 Analytics Feature
analytics_repository.dart
Algorithm:

fetchTeacherStats(teacherId, startDate, endDate) → call GET /analytics/teacher/:teacherId?start=...&end=....

Cache result in Hive for 1 hour.

analytics_screen.dart
Algorithm:

On init, load stats via AnalyticsBloc.

Show CircularPercentIndicator for overall attendance.

Show BarChart (fl_chart) for subject‑wise attendance percentages.

Show list of subjects with individual percentages.

Allow date range filter (last 7 days, this month, custom).

On filter change, reload data.

4. Shared Widgets Algorithms
network_image_with_placeholder.dart
Algorithm:

Accept imageUrl and width/height parameters.

Append Cloudinary transformations: w=$width,c_fill,q_auto,f_auto to URL.

Use CachedNetworkImage with:

placeholder = ShimmerLoading

errorWidget = default avatar icon.

shimmer_loading.dart
Algorithm:

Use Shimmer.fromColors with baseColor and highlightColor.

Return a container with rounded corners (simulating card or image).

5. Environment & Build Configuration
env_config.dart
Algorithm:

Read String.fromEnvironment for:

API_URL

ENABLE_BIOMETRIC

ENABLE_PUSH_NOTIFICATIONS

Provide static getters.

Assert that required keys are not empty.

6. Dependency Injection (GetIt)
dependency_injection.dart
Algorithm:

Register ApiClient as singleton.

Register all repositories as singletons.

Register all Blocs as factory (so each screen gets new instance, or lazySingleton if shared).

Register SyncService and BackgroundTaskService as singletons.

Register DatabaseHelper as singleton.

Call GetIt.I.register... for each.

7. Background Sync (Android WorkManager)
background_task_service.dart
Algorithm:

Schedule periodic task every 15 minutes with constraints:

NetworkType.CONNECTED

BatteryNotLow true

RequiresCharging false (optional)

Task executes SyncService.syncPendingAttendance().

On completion, reschedule.