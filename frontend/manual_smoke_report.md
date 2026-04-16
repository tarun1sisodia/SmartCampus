# Phase 3 Manual Smoke Report

Date: 2026-04-14
Branch: `release/teacher-app-1.0`

## Environment Attempted

- `flutter run -d linux` -> blocked by missing native dependency:
  - `libsecret-1>=0.18.4` required by `flutter_secure_storage_linux`
- `flutter run -d chrome` -> launch started but debug service connection did not complete in this environment.

## Pre-Checks

- `flutter test` -> PASS (from Phase 1)
- `flutter analyze lib/features lib/core lib/app lib/env lib/shared --fatal-infos` -> PASS (from Phase 2)

## Manual Core Smoke Checklist

- [ ] Login and app restart preserves session
- [ ] Home sessions load
- [ ] Session detail opens
- [ ] Attendance carousel submit succeeds
- [ ] Offline attendance save shows expected message
- [ ] Online restore triggers sync
- [ ] Calendar day sheet shows sessions
- [ ] Student profile opens from session/attendance
- [ ] Analytics date range updates charts
- [ ] Profile update persists
- [ ] Theme/language applies app-wide instantly
- [ ] Push notification appears and tap navigates to session

## Notes for Local Execution

1. Install Linux dependency:
   - `sudo apt-get update && sudo apt-get install -y libsecret-1-dev`
2. Re-run app:
   - `flutter run -d linux`
3. Execute checklist and mark pass/fail above.

## Status

- Phase 3 started.
- Automated environment could not complete runtime launch for interactive verification.
- Checklist is ready for device/manual execution.
