# SmartCampus Teacher App - Implementation Runbook

This runbook is the execution guide for final stabilization and release readiness.
It is command-first, phase-gated, and evidence-driven.

---

## Scope

- Active app paths:
  - `lib/app`
  - `lib/core`
  - `lib/env`
  - `lib/features`
  - `lib/shared`
- Verification source of truth:
  - `DEVELOPMENT.md` (phases 0-11)

---

## Rules

1. Execute phases in order.
2. Do not proceed if the current phase acceptance gate fails.
3. Save all outputs listed under "Evidence".
4. Keep all fixes inside active app scope unless an error requires touching legacy code.

---

## Phase 0 - Baseline & Tracking Setup

### Objectives

- Create a repeatable baseline snapshot.
- Capture current health before further changes.

### Commands

```bash
git checkout -b release/teacher-app-1.0
git status
flutter doctor -v > baseline_doctor.txt
flutter pub get
flutter test > baseline_test.txt 2>&1
flutter analyze lib/features lib/core lib/app lib/env lib/shared > baseline_analyze_active.txt 2>&1
git tag baseline-before-optimisation
```

### Evidence

- `baseline_doctor.txt`
- `baseline_test.txt`
- `baseline_analyze_active.txt`

### Acceptance Gate

- Branch exists.
- Baseline files exist and are readable.
- Known failures are documented (failures allowed in this phase).

---

## Phase 1 - Build Stability (Compile + Runtime Blockers)

### Objectives

- Eliminate compile/runtime blockers in active flow.
- Ensure tests execute.

### Commands

```bash
flutter clean
flutter pub get
flutter test
rg "_onAppStarted|refreshToken|getCurrentUser" lib/features/auth/bloc/auth_bloc.dart lib/features/auth/bloc/auth_repository.dart
rg "onError|AuthLogoutRequested|deleteTokens" lib/core/api/refresh_token_interceptor.dart
rg "teacherId" lib/features/session/bloc/session_repository.dart lib/features/session/bloc/session_event.dart lib/features/session/views/session_history_screen.dart
```

### Evidence

- Test output in terminal
- Ripgrep verification output in terminal

### Acceptance Gate

- `flutter test` passes.
- Auth startup restore logic present.
- Refresh failure logout behavior present.
- Session history includes `teacherId`.

---

## Phase 2 - Analyzer Cleanup (Active Code)

### Objectives

- Remove error-level analyzer issues in active code paths.

### Commands

```bash
flutter analyze lib/features lib/core lib/app lib/env lib/shared --fatal-infos
dart fix --apply
flutter analyze lib/features lib/core lib/app lib/env lib/shared --fatal-infos
```

### Evidence

- Analyzer output in terminal (before/after)

### Acceptance Gate

- Zero analyzer errors in active paths.
- No fatal infos in active paths.

---

## Phase 3 - Manual Core Smoke (Functional)

### Objectives

- Validate critical teacher workflow manually.

### Command

```bash
flutter run
```

### Checklist

- Login and app restart preserves session.
- Home sessions load.
- Session detail opens.
- Attendance carousel submits.
- Offline attendance saves.
- Online restore triggers sync.
- Calendar day sheet shows sessions.
- Student profile opens from session/attendance.
- Analytics range changes update visuals.
- Profile updates persist.
- Theme/language changes apply app-wide.

### Evidence

- Manual QA notes (create `manual_smoke_report.md`)

### Acceptance Gate

- All checklist flows pass or have tracked blockers.

---

## Phase 4 - Notifications + Offline Reliability

### Objectives

- Validate FCM and sync conflict behavior.

### Commands

```bash
rg "registerNotificationToken|onMessage|onMessageOpenedApp|getInitialMessage" lib/core/services/push_notification_service.dart
rg "syncPendingAttendance|retryCount|_backoffMinutes|timestamp|conflict" lib/core/services/sync_service.dart
```

### Device Validation

- Send test push from Firebase Console.
- Verify foreground notification appears.
- Verify tap navigates to session detail.
- Trigger sync conflict scenario and verify user-visible warning.

### Acceptance Gate

- Push + routing work on device.
- Offline sync + conflict handling are user-visible and stable.

---

## Phase 5 - Release Build & Validation

### Objectives

- Produce release artifacts and verify on real devices.

### Commands

```bash
flutter test
flutter analyze lib/features lib/core lib/app lib/env lib/shared --fatal-infos
flutter build apk --release --split-per-abi
flutter build ios --release
```

### Optional iOS prep

```bash
cd ios && pod install && cd ..
```

### Device Install

```bash
adb install build/app/outputs/apk/release/app-arm64-v8a-release.apk
```

### Evidence

- Build output paths
- Final device QA notes (`release_validation_report.md`)

### Acceptance Gate

- Release builds succeed.
- APK/IPA run on real devices.
- Critical flows pass on release builds.

---

## Final Exit Criteria

- `flutter test` green.
- Active-path analyze green (`--fatal-infos`).
- Manual smoke checklist passed.
- Push/offline validated.
- Release builds tested on real devices.

