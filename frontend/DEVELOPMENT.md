# Prompt for Cursor AI – SmartCampus Flutter Teacher App Development

You are an expert Flutter developer and architect. You will build the **SmartCampus Teacher App** from scratch, following a **single source of truth** defined in the documents provided.

---

## Context (Read Carefully)

- **Backend specification:**  
  `@backend/SmartCampus Backend – Complete Production‑Ready Architecture.md`  
  → The backend is **fully implemented** (Node.js, Express, MongoDB, Redis, JWT, CQRS, etc.). All API endpoints listed in section 8 are live and ready.

- **Frontend documentation:**  
  `@frontend/SmartCampus – Frontend Documentation.md`  
  → This defines the **expected architecture, folder structure, BLoC pattern, offline sync, push notifications, and screens** for the Flutter teacher app.

- **Existing codebase (old, to be replaced):**  
  `@frontend/lib_backup/`  
  → Contains legacy code (maybe using Supabase or different state management). **Do not copy from it directly** – only use it as a reference for business logic if needed, but you are **re‑creating the app cleanly** inside `@frontend/lib/`.

- **Current state of new app:**  
  `@frontend/lib/` – may contain partial work (some folders, maybe some BLoC stubs). You must **analyze what is already done** and **continue from there** without breaking existing progress. If something is missing or incomplete, you will implement it following the frontend documentation.

- **Your mission:**  
  Build the **complete Flutter teacher app** (iOS & Android) that connects to the backend described. Follow **all algorithms, patterns, and folder structure** from the frontend documentation. Implement **every screen, BLoC, service, and utility** listed.

---

## Phase‑by‑Phase Development Plan

You will work **in phases** as defined below. After each phase, you will produce **working, tested code**. Do not skip phases.

### Phase 0 – Environment & Foundation (Already partially done – verify & complete)
- [ ] Ensure `pubspec.yaml` has correct dependencies:  
  `flutter_bloc`, `go_router`, `dio`, `retrofit` (optional), `get_it`, `flutter_secure_storage`, `hive`, `sqflite`, `cached_network_image`, `firebase_messaging`, `workmanager`, `equatable`, `json_serializable`, `shimmer`, `table_calendar`, `fl_chart`, `image_picker`, `file_picker`.
- [ ] Create `lib/env/env_config.dart` with environment variables (`API_BASE_URL`, `ENABLE_BIOMETRIC`, etc.) using `--dart-define`.
- [ ] Complete `lib/app/dependency_injection.dart` – register all services (singletons) and BLoCs (factories) with `get_it`.
- [ ] Complete `lib/app/theme.dart` – light & dark theme using the color palette from frontend documentation (primary `#3B82F6`, etc.).
- [ ] Complete `lib/app/routes.dart` – `GoRouter` with authentication guard (redirect to `/login` if not authenticated). Define all routes: `/login`, `/home`, `/session/:sessionId`, `/attendance/:sessionId`, `/history`, `/calendar`, `/student/:studentId`, `/analytics`, `/profile`.

### Phase 1 – Core Services & API Client
- [ ] `lib/core/api/api_client.dart` – Dio singleton with interceptors:
  - `TokenInterceptor`: adds `Authorization: Bearer <accessToken>`.
  - `RefreshTokenInterceptor`: on 401, attempt refresh using refresh token; retry original request; on failure, logout and redirect to login.
  - `LogInterceptor` (debug only).
- [ ] `lib/core/api/endpoints.dart` – all API path constants (e.g., `kLoginEndpoint = '/auth/login'`).
- [ ] `lib/core/services/secure_storage_service.dart` – store/retrieve access & refresh tokens using `flutter_secure_storage`.
- [ ] `lib/core/services/connectivity_service.dart` – check internet status (using `connectivity_plus`).
- [ ] `lib/core/services/background_task_service.dart` – schedule periodic sync using `workmanager` (Android) and `background_fetch` (iOS fallback).
- [ ] `lib/core/services/notification_service.dart` – initialise FCM, register token with backend (`POST /notifications/register-token`), handle foreground/background messages.
- [ ] `lib/core/database/app_database.dart` – initialise `sqflite`, create tables `pending_attendance` and `session_cache`. Create DAOs for each.
- [ ] `lib/core/cache/hive_service.dart` – initialise Hive boxes for caching teacher profile, organisation data, etc.

### Phase 2 – Authentication Feature
- [ ] `lib/features/auth/models/user_model.dart` (with `json_serializable`).
- [ ] `lib/features/auth/repositories/auth_repository.dart`:
  - `login(email, password)` → `POST /auth/login`, returns `UserModel` + tokens.
  - `logout()` → `POST /auth/logout` (ignore errors) + clear local tokens.
  - `forgotPassword(email)` → `POST /auth/forgot-password`.
  - `resetPassword(token, newPassword)` → `POST /auth/reset-password`.
- [ ] `lib/features/auth/bloc/auth_bloc.dart`:
  - Events: `LoginRequested`, `LogoutRequested`, `ForgotPasswordRequested`, `ResetPasswordRequested`.
  - States: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`.
  - Logic: on `LoginRequested`, call repository, store tokens, emit `AuthAuthenticated`. On `LogoutRequested`, clear tokens, emit `AuthUnauthenticated`.
- [ ] `lib/features/auth/views/login_screen.dart` – email + password fields, validation, Biometric login button (optional).
- [ ] `lib/features/auth/views/forgot_password_screen.dart` – email input, call `ForgotPasswordRequested`.
- [ ] Add routing: `/login` → `LoginScreen`, `/forgot-password` → `ForgotPasswordScreen`.

### Phase 3 – Home Screen (Today’s Sessions)
- [ ] `lib/features/home/models/session_model.dart`.
- [ ] `lib/features/home/repositories/home_repository.dart`:
  - `fetchTodaySessions()` → `GET /sessions?date=today` (teacher ID taken from JWT).
- [ ] `lib/features/home/bloc/home_bloc.dart`:
  - Event: `LoadTodaySessions`.
  - States: `HomeLoading`, `HomeLoaded(List<SessionModel>)`, `HomeError`.
  - Use caching: store in Hive with TTL until midnight.
- [ ] `lib/features/home/views/home_screen.dart`:
  - Show `ShimmerLoading` while loading.
  - List of `SessionCard` widgets (showing subject, time, section).
  - Pull‑to‑refresh triggers reload.
  - Tapping a session navigates to `SessionDetailScreen`.
- [ ] `lib/features/home/widgets/stats_overview.dart` – small KPIs (e.g., total students taught today – optional).

### Phase 4 – Session Detail & Attendance Marking
- [ ] `lib/features/session/` – models, repository, BLoC:
  - `fetchSessionDetail(sessionId)` → `GET /sessions/:sessionId`.
  - `fetchStudentsForSession(sessionId)` → `GET /students?sessionId=...`.
- [ ] `lib/features/session/views/session_detail_screen.dart`:
  - Show session info (subject, time, section, teacher).
  - Button “Mark Attendance” → navigates to `AttendanceCarouselScreen`.
- [ ] `lib/features/attendance/` – core:
  - `lib/features/attendance/models/attendance_record.dart`.
  - `lib/features/attendance/repositories/attendance_repository.dart`:
    - `markAttendance(sessionId, List<AttendanceRecord>)` → `POST /attendance/mark`.
    - `syncOffline(List<Map<String,dynamic>>)` → `POST /attendance/sync`.
  - `lib/features/attendance/bloc/attendance_bloc.dart`:
    - Events: `MarkAttendance`, `SyncPending`, `LoadStudents`.
    - States: `AttendanceInitial`, `AttendanceLoading`, `AttendanceMarked`, `AttendanceOfflineSaved`, `AttendanceError`.
    - Logic: if online, call API; if offline, store in SQLite and emit `OfflineSaved`.
  - `lib/features/attendance/views/carousel_attendance_screen.dart`:
    - Use `PageView.builder` to show one student per page.
    - Each student card: photo (CachedNetworkImage with Cloudinary optimisation), name, roll number, three status buttons (Present/Absent/Late).
    - Show progress indicator (e.g., 5/30 marked).
    - On status tap, add to local list and update UI.
    - “Submit All” button calls `MarkAttendance` event.
  - `lib/features/attendance/views/attendance_summary_screen.dart` – after submission, show counts.

### Phase 5 – Session History & Calendar
- [ ] `lib/features/session/views/session_history_screen.dart`:
  - Fetch past sessions (last 30 days) using `GET /sessions?teacherId=...&endDate=...`.
  - Group by date, show list.
- [ ] `lib/features/calendar/` – new feature:
  - `lib/features/calendar/models/calendar_session_model.dart`.
  - `lib/features/calendar/repositories/calendar_repository.dart`:
    - `fetchSessionsForMonth(year, month)` → `GET /sessions?month=YYYY-MM`.
  - `lib/features/calendar/bloc/calendar_bloc.dart`:
    - Event: `LoadMonth(DateTime month)`.
    - State: `CalendarLoaded(Map<DateTime, List<CalendarSession>>)`.
  - `lib/features/calendar/views/calendar_screen.dart`:
    - Use `table_calendar`.
    - Show dots on days with sessions.
    - On day tap → bottom sheet listing sessions of that day.
    - Tapping a session → navigates to `SessionDetailScreen`.

### Phase 6 – Student Profile (Read‑Only)
- [ ] `lib/features/student/`:
  - `lib/features/student/models/student_detail_model.dart`.
  - `lib/features/student/repositories/student_repository.dart`:
    - `fetchStudentDetails(studentId)` → `GET /students/:id`.
    - `fetchStudentAttendanceSummary(studentId)` → `GET /attendance/student/:studentId`.
  - `lib/features/student/bloc/student_profile_bloc.dart`:
    - Event: `LoadStudentProfile`.
    - State: `StudentProfileLoaded(StudentDetail, AttendanceSummary)`.
  - `lib/features/student/views/student_profile_screen.dart`:
    - Show photo, roll number, name, contact, parent contact, course, semester, section.
    - Show circular percent indicator + present/absent/late counts.
    - List recent attendance (optional).
- [ ] Navigate from `SessionDetailScreen` or `AttendanceCarouselScreen` by tapping on student name/photo.

### Phase 7 – Analytics (Teacher Stats)
- [ ] `lib/features/analytics/` – using `fl_chart`:
  - `lib/features/analytics/repositories/analytics_repository.dart`:
    - `fetchTeacherStats(teacherId, startDate, endDate)` → `GET /analytics/teacher/:teacherId`.
  - `lib/features/analytics/bloc/analytics_bloc.dart`:
    - Event: `LoadStats(DateTimeRange)`.
    - State: `AnalyticsLoaded(TeacherStats)`.
  - `lib/features/analytics/views/analytics_screen.dart`:
    - Date range selector (last 7 days, this month, custom).
    - Show overall attendance percentage (circular indicator).
    - Bar chart for subject‑wise attendance.
    - List of subjects with percentages.

### Phase 8 – Profile Screen & Settings
- [ ] `lib/features/profile/`:
  - `lib/features/profile/repositories/profile_repository.dart`:
    - `fetchProfile()` → `GET /users/me`.
    - `updateProfile(Map<String,dynamic>)` → `PATCH /users/me`.
    - `uploadPhoto(File)` → `POST /users/me/photo`.
    - `changePassword(oldPassword, newPassword)` → `POST /users/change-password`.
  - `lib/features/profile/bloc/profile_bloc.dart`:
    - Events: `LoadProfile`, `UpdateProfile`, `UploadPhoto`, `ChangePassword`.
    - States: `ProfileLoaded`, `ProfileUpdateSuccess`, etc.
  - `lib/features/profile/views/profile_screen.dart`:
    - Show avatar (with edit icon → pick image).
    - Name, email (read‑only).
    - Fields to change name, contact (if allowed).
    - Change password section.
    - Theme toggle (Light/Dark).
    - Language selector.
    - Logout button.
- [ ] Add biometric toggle (local, using `local_auth`).

### Phase 9 – Offline Sync & Background Tasks
- [ ] Complete `lib/core/services/sync_service.dart`:
  - On app start, check for unsynced records in SQLite.
  - If online, send batch to `POST /attendance/sync`.
  - On success, delete synced records.
  - On failure, retry with exponential backoff (store retry count).
- [ ] Integrate `background_task_service.dart`:
  - Schedule periodic sync every 15 minutes (only when device has network and battery not low).
  - Use `Workmanager` for Android, `background_fetch` for iOS.
- [ ] Ensure conflict resolution: compare `timestamp` field; if server record is newer, discard local change and notify user.

### Phase 10 – Push Notifications (FCM)
- [ ] Configure Firebase in the project (`google-services.json`, `GoogleService-Info.plist`).
- [ ] In `notification_service.dart`:
  - On app start, get FCM token, send to backend `POST /notifications/register-token`.
  - Listen to `onMessage` (foreground) → show local notification.
  - Handle `onMessageOpenedApp` → navigate to session detail.
- [ ] Backend is already set up to send notifications (via `eventBus` when attendance marked or session reminder).

### Phase 11 – Final Polish & Testing
- [ ] Add `sentry_flutter` for crash reporting.
- [ ] Add `flutter_native_splash` and `flutter_launcher_icon`.
- [ ] Write unit tests for repositories and BLoCs.
- [ ] Write integration tests for critical flows (login → load home → mark attendance).
- [ ] Build release APK/IPA and test on real devices.

---

## What You Must Do Now

1. **Analyse the existing `@frontend/lib/` folder** – see which phases have already been partially implemented. Do not delete working code; only improve and fill gaps.

2. **Read both documentation files** (`backend/*.md` and `frontend/*.md`) thoroughly. Use them as the **single source of truth** for endpoint contracts, data models, and UI requirements.

3. **Update the frontend documentation** if you discover inconsistencies or missing details (e.g., add the `CalendarScreen` and `StudentProfileScreen` which are already required but may not be listed in the original frontend doc). Produce an updated version of `SmartCampus – Frontend Documentation.md` reflecting all screens and features you will implement.

4. **Implement the app phase by phase** as described above. For each phase, output the **exact file contents** (full code) with proper imports, error handling, and comments.

5. **Do not copy from `lib_backup`** – rewrite everything cleanly following modern Flutter best practices (BLoC, go_router, get_it, dio, etc.).

6. **Assume the backend is fully functional** – all endpoints listed in the backend spec are available. Use the `Endpoints` class to reference them.

7. **Provide a final summary** listing which phases are completed and any outstanding tasks.

---

## Additional Notes

- Use **relative imports** inside `lib/` (avoid deep `../../`).
- Use **`freezed`** (or `equatable`) for BLoC states and events.
- For JSON serialisation, use `json_serializable`.
- For environment variables, create a `.env` file (not committed) and use `flutter_dotenv` or `--dart-define`. Document the required variables.
- For image uploads (profile photo), use `dio` with `FormData` and `MultipartFile`.
- For calendar, use `table_calendar` package.
- For charts, use `fl_chart`.

Now, **start with Phase 0** – verify and complete the foundation. Then proceed to Phase 1, etc. Output each file as you go.