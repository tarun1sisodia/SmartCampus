# SmartCampus Flutter App Scaling Implementation Plan

This document outlines the systematic plan to implement the architectural changes detailed in `scaling_app.md`, exclusively focusing on the Flutter application. The plan prioritizes moving away from hardcoded secrets, optimizing rendering, adopting robust state management, and real-time monitoring.

## User Review Required

> [!WARNING]
> The `scaling_app.md` guide mentions using the **Transaction Mode connection string (Port 6543)**. The Flutter app currently uses `supabase_flutter` which talks to Supabase via its REST API (PostgREST), which inherently scales and does not require manual connection pooling. 
> 
> *Are you planning to introduce a direct Postgres connection using the dart `postgres` package for specific heavy queries? Or should we just stick with the REST API provided by `supabase_flutter` which already handles connections efficiently behind the scenes?*

## Proposed Changes

---

### Phase 1: Environment & Security Setup [High Priority]
Currently, API keys are hardcoded in `api_constants.dart`. We will implement `flutter_dotenv` to securely manage these.

#### [MODIFY] pubspec.yaml
- Add `flutter_dotenv: ^5.1.0` dependency.

#### [NEW] .env
- Create this file (and verify it's in `.gitignore`) to hold your Supabase URL and Anon Key.

#### [MODIFY] api_constants.dart
`lib/common/utils/constants/api_constants.dart`
- Refactor to load values using `dotenv.env['SUPABASE_URL']`.

#### [MODIFY] main.dart
`lib/main.dart`
- Load `dotenv` before `Supabase.initialize`.

---

### Phase 2: State Management Modernization (GetX) [COMPLETE]
The app currently uses `setState` in several critical flows which can cause memory leaks and unintended rebuilds. We will migrate these to scoped GetX Controllers.

#### [NEW] LoginController & SignupController
`lib/features/authentication/controllers/login_controller.dart` (Example)
- Create controllers to handle business logic, text editing controllers, and loading states.

#### [MODIFY] Authentication Screens
`lib/features/authentication/screens/login/login.dart`
`lib/features/authentication/screens/signup/singup_widgets/signup_form.dart`
`lib/features/authentication/screens/forgot_password/reset_password_confirmation.dart`
- Convert from Stateful to Stateless Widgets using `Obx` for reactivity.

#### [MODIFY] Teacher Screens
`lib/features/teacher/screens/about_screen.dart`
- Convert remaining `setState` instances over to GetX.

---

### Phase 3: Frontend Architecture Optimization [COMPLETE]

#### A. Lazy Loading Strategy
We will review heavily populated screens that currently use standard `ListView` or `GridView` and convert them to `ListView.builder` to prevent Out Of Memory (OOM) issues on low-end devices.
Affected files include:
- `lib/features/teacher/screens/attendance_screen.dart`
- `lib/features/teacher/screens/class_list_screen.dart`
- `lib/features/teacher/screens/teacher_messages_screen.dart`

#### B. Image Optimization
We will enforce `cached_network_image` and utilize Supabase's image transformation parameters to avoid downloading full-size raw images.
Affected files include:
- `lib/common/widgets/student_avatar.dart`
- `lib/features/teacher/widgets/swipeable_student_card.dart`
- `lib/features/teacher/screens/profile_image_view_screen.dart`

---

### Phase 4: Monitoring [COMPLETE]
Implementing Sentry to catch unhandled Flutter exceptions in production.

#### [MODIFY] pubspec.yaml
- Add `sentry_flutter: ^8.0.0`.

#### [MODIFY] main.dart
- Wrap `runApp` with `SentryFlutter.init` to track all global errors.

### Phase 5: Pagination and Load Management [Medium Priority]
Scaling the heavy class/student/session lists by fetching only the pages being viewed and giving teachers a “load more” path.

#### [MODIFY] class_service.dart / student_service.dart / attendance_service.dart
- Introduce `offset`/`limit` parameters and project only the column set needed.
- Default to page sizes (20 classes, 25 students, 20 sessions) and expose `range` queries instead of unbounded `select`.

#### [MODIFY] class_controller.dart / student_controller.dart / attendance_controller.dart
- Track offsets, `hasMore` flags, separate `isLoadingMore`, and expose `loadMore…()` helpers.
- Update real-time class handling to batch related lookups so each update executes only one subject/course query.

#### [MODIFY] class_list_screen.dart / attendance_screen.dart / add_student_screen.dart
- Render footer “Load More” buttons plus loading indicators based on the controller state instead of displaying every record at once.

---

### Phase 6: Infrastructure & Deployment (Shorebird & CI/CD) [High Priority]
Integrating Shorebird for over-the-air (OTA) updates and optimizing the CI/CD pipeline for 2026 standards.

#### [TASK] Shorebird Initialization
- Install Shorebird CLI and initialize the project (`shorebird init`).
- Add `shorebird.yaml` to version control and ignore local `.shorebird/` state.

#### [MODIFY] .github/workflows/flutter-ci.yml
- Enable `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true` to resolve Node 20 deprecation warnings and ensure long-term stability.

#### [MODIFY] .gitignore
- Add `bundletool.jar`, `sentry-wizard`, and Shorebird local state to prevent tracking of unnecessary artifacts.

## Open Questions

> [!IMPORTANT]
> 1. Do you have a `Sentry DSN` ready to test the integration for Phase 4, or should we just set up the boilerplate code?
> 2. Are there any other custom backend endpoints we need to prepare space for in the `.env` file?
> 3. Should pagination eventually be automatic (scroll-triggered) instead of manual load-more buttons, and do you want a shared paging helper for other lists?

## Verification Plan

### Automated Tests
- If existing widget tests test for `StatefulWidget` types, they will be updated.

### Manual Verification
1. Verify the app boots without throwing dotenv errors.
2. Verify authentication flows still work correctly with GetX controllers.
3. Use Flutter DevTools to monitor memory usage before and after transitioning to `ListView.builder` for the `attendance_screen`.
4. Run the app in Profile mode to ensure images are loading swiftly and cached locally.

## Outstanding Work
- **Backend alignment:** Keep `backend/complete_setup_database.sql` in sync whenever new columns or indexes are required by the app (status/closed fields on `attendance_sessions`, turbo indexes for paging, etc.). Re-run this script before pushing schema changes.
- **Auto pagination:** Consider replacing the manual `Load More` buttons in the class/session/student screens with scroll-triggered loaders and a shared pagination helper so the UX stays smooth when teachers scroll through thousands of records.
- **Sentry verification:** Once `SENTRY_DSN` is configured, trigger both handled (`Sentry.captureException`) and unhandled errors, and confirm events land in your `flutter` project before shipping.
- **Transaction-mode question:** Resolve whether the project still relies solely on Supabase REST (recommended) or if selective direct Postgres calls are needed for heavy queries. If the latter, add a dedicated service that opens a transaction-mode connection only for the expensive operations.
