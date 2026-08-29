# SmartCampus Teacher App — Algorithm / Logic Files

Every `.dart` file inside `frontend/lib/` has a twin in this folder that contains
**only the algorithm as comments** — no code, just 1-2 line pseudo-logic per
function/step, exactly describing what the real file does.

- Same folder structure as `frontend/lib/` (e.g. `logic/main.dart` = `frontend/lib/main.dart`).
- `user_model.g.dart` is skipped (generated JSON code, no hand-written logic — noted in `models/user_model.dart`).
- These files are NOT part of the Flutter build (folder lives outside `frontend/`).

## App in one page (how it flows)

1. `main.dart` — app loads: validate env → init DI (DB, Hive, services, repos, blocs) → runApp → after first frame start Firebase / background sync / push / Sentry (each try-catch + 4s timeout).
2. `app/app.dart` — AuthBloc fires AppStarted (auto-login check), SettingsBloc loads theme/language, MaterialApp.router + global bloc providers.
3. `app/routes.dart` — go_router: auth guard (not logged in → `/login`), bottom-nav shell (`/home /calendar /analytics /settings`) + full-screen detail routes.
4. `core/api/*` — one Dio client; TokenInterceptor adds JWT; RefreshTokenInterceptor auto-refreshes on 401 (single-flight) and retries; else logout.
5. `features/auth` — login → save tokens (secure storage) → authenticated; JWT `exp` checked at startup; forgot/reset password.
6. `features/home` — today's sessions, offline-first (Hive cache until midnight + fresh API fetch).
7. `features/attendance` —
   - manual marking: swipe carousel → draft statuses → submit; ONLINE → POST, OFFLINE → queue rows in SQLite `pending_attendance`.
   - QR: teacher generates rolling token (auto-refresh timer), student scans → verify with session token + GPS.
8. `core/services/sync_service.dart` — background sync of the offline queue: batches of 50, conflict = server-wins by timestamp, exponential backoff retry (max 8 tries), conflict warning snackbar.
9. `features/analytics / calendar / session / student / profile / settings` — read-only dashboards + profile edits, each with bloc → repository → API layering.

## File map

| Area | Folder |
|---|---|
| Entry point, DI, routing, theming | `main.dart`, `app/` |
| HTTP, tokens, endpoints | `core/api/` |
| SQLite + Hive storage | `core/database/`, `core/cache/` |
| Sync, background tasks, push, biometrics, connectivity | `core/services/` |
| Auth / Home / Attendance / QR | `features/auth`, `features/home`, `features/attendance` |
| Session history/detail, Student, Profile, Settings | `features/session`, `features/student`, `features/profile`, `features/settings` |
| Analytics, Calendar | `features/analytics`, `features/calendar` |
| Reusable widgets, shared models, utils | `shared/`, `common/` |
| Empty legacy placeholders | `hive/` |
