# SmartCampus Issue Audit

Audited: 2026-09-08
Branch: `arena/01a07f22-smartcampus`
Scope: backend (`Node/Express/Mongo`), Flutter teacher app, `web/org-admin` and `web/super-admin` Next.js portals.

Severity legend:
- `P0` Blocks build/startup or completely breaks a flow.
- `P1` Makes a major feature unusable in production.
- `P2` Minor functional/UX/data-integrity issue.
- `P3` Dead code, duplication, config/cleanup.

---

## Fixes applied in this branch

The following were implemented while auditing:

- **21st.dev/shadcn-style light+dark theming** for `web/org-admin` and `web/super-admin`:
  - CSS variable tokens in `globals.css` with `.dark` class.
  - `ThemeProvider` + `ThemeToggle` with `localStorage` persistence and no-flash inline script.
  - Semantic Tailwind colors (`background`, `foreground`, `card`, `border`, `input`, `primary`, …) and theme-aware layouts/components.
- **Flutter teacher app** now uses the curated `TAppTheme` with 21st.dev-inspired light (`shadcn neutral`) and dark (`shadcn slate + cyan`) palettes. Core cards/home screens now read colors from `Theme.of(context)`.
- **Build blocker fixed:** super-admin `organisations/[id]` uses `useParams()` instead of a stale `params` prop.
- **API contract fixes:** web API clients unwrap `{ success, data }` envelopes and normalize backend `data/total/page/limit` shapes into frontend `items/totalPages/totalItems` shapes; teachers/orgs/users entities are mapped from Mongo `_id`/`isActive`/`subscription.plan` to the frontend types.
- **Org-admin invite fixed:** sends `role: 'teacher'`, and `resendInvite` uses the correct `/users/:id/resend` path.
- **Logout fixed:** frontends now send the refresh token to the backend so refresh tokens are actually revoked.
- **Missing backend endpoints added:** `GET /users`, `PATCH /users/:id`, `POST /users/:id/reset-password`, `PATCH /users/me`, `GET /sessions/:id` (session detail). `org.update` now returns 404 for unknown ids.
- **Flutter data fixes:** attendance student-list envelope unwrapping, calendar month endpoint (`/attendance/sessions/month`) + date/time parsing, analytics `subjectWise` normalization, session detail backend + repository contract, secure storage token-only deletion, QR refresh timing.
- **Platform config:** Android location permissions and debug/profile cleartext HTTP; iOS location usage text and corrected app display name; `.env.example` updated for the new env vars.
- **Startup reliability:** `server.js` no longer runs the external smoke-test during normal startup.

---

## 1. Build / startup blockers

### 1.1 (P0) `web/super-admin` fails production build
- **File:** `web/super-admin/app/(dashboard)/organisations/[id]/page.tsx`
- **Symptom:** `next build` fails with:
  ```
  Type 'Props' does not satisfy the constraint 'PageProps'.
  Types of property 'params' are incompatible. Type '{ id: string; }' is missing ... Promise<any>
  ```
- **Root cause:** Next.js 15 passes dynamic segment `params` as a Promise; a client page must not declare it as a plain object prop.
- **Fix:** Use `useParams()` from `next/navigation` inside the client component.

### 1.2 (P0) Flutter app uses `EnvConfig.apiBaseUrl` (compile-time `localhost`) but mobile can't reach it
- **Files:** `frontend/lib/env/env_config.dart`, `frontend/lib/core/api/api_client.dart`, `frontend/lib/common/utils/constants/api_constants.dart`
- **Problem:** `ApiClient` hits `EnvConfig.apiBaseUrl` which defaults to `http://localhost:5000/api/v1`. On Android emulator/physical device `localhost` is the device itself. `ApiConstants.backendBaseUrl` still uses `http://10.0.2.2:5000/api/v1`, creating two competing config sources. `.env` is never loaded, and `.env.example` still contains Supabase keys.
- **Fix:** Load `.env` with `flutter_dotenv` before DI, keep a single source (`EnvConfig` resolved from `dotenv`/`--dart-define`), and set `API_BASE_URL=http://10.0.2.2:5000/api/v1` for Android emulator.

### 1.3 (P0) Android blocks cleartext HTTP while the app talks to `http://` dev backend
- **Files:** `frontend/android/app/src/main/AndroidManifest.xml`, `frontend/android/app/src/debug/AndroidManifest.xml`
- **Problem:** `android:usesCleartextTraffic="false"` in the main manifest prevents local/dev `http://` API calls. The debug manifest does not override it.
- **Fix:** Keep `false` for release; add `<application android:usesCleartextTraffic="true" tools:replace="android:usesCleartextTraffic"/>` in the debug (and profile) manifests.

### 1.4 (P1) Server startup can block/behave badly because `server.js` runs `verifyExternalConnections()` and connects twice
- **Files:** `backend/server.js`, `backend/scripts/smokeTest.js`
- **Problem:** `server.js` imports the smoke test module and calls `verifyExternalConnections()` before `connectDB()`. It connects Mongo itself and pings Redis/S3/Cloudinary. Any external service being down produces noisy errors, only logs and continues. The smoke test also constructs an S3/R2 client even when no R2 URL is configured.
- **Fix:** Don't import the smoke-test runner into `server.js`; keep startup to `connectDB()` + background jobs. Move external checks behind `npm run smoke`/CI.

---

## 2. Backend correctness / security

### 2.1 (P1) QR verification does not enforce geofencing or store location
- **Files:** `backend/src/controllers/attendanceQr.controller.js`, `frontend/lib/core/api/endpoints.dart`, `frontend/lib/features/attendance/repositories/attendance_repository.dart`
- **Problem:** `verifyQrAttendance` accepts `lat`/`lon` from the client but ignores them. `backend/src/utils/geoUtils.js` (haversine) exists but is unused. Students can verify from anywhere. The created `Attendance` record also omits `markedVia: 'qr'`, `qrTokenUsed`, and `locationData`.
- **Fix:** Add optional `location` fields to `Session`/`Attendance`; validate the scanned student within a radius (`calculateDistance`), reject if missing/outside; persist `markedVia`, `qrTokenUsed`, `locationData`. Add a `verifyQrSchema` with required `sessionId`, `token`, optional `lat`/`lon` and use `validate()` on the route.

### 2.2 (P1) No `GET /users` list endpoint for super-admin
- **Files:** `backend/src/routes/v1/users.routes.js`, `web/super-admin/lib/api/endpoints/user-api.ts`, `web/super-admin/app/(dashboard)/users/page.tsx`
- **Problem:** Super-admin Users page calls `GET /users`, but the backend only exposes `/users/invite`, `/users/teachers`, `/users/:userId`, `/users/me`, `/users/change-password`. The page always receives 404.
- **Fix:** Add `GET /users` with `rbac('super_admin')` that returns `{ data, total, page, limit }` (and a `role` filter).

### 2.3 (P1) No promote/reset-password endpoints used by super-admin
- **Files:** `backend/src/routes/v1/users.routes.js`, `web/super-admin/lib/api/endpoints/user-api.ts`
- **Problem:** `promoteToSuperAdmin` calls `PATCH /users/:id` and `resetPassword` calls `POST /users/:id/reset-password`; neither route exists.
- **Fix:** Add `PATCH /users/:userId` (super-admin only, update role/status) and `POST /users/:userId/reset-password` (generate a reset token and send email). The existing public `POST /auth/reset-password` already accepts the token.

### 2.4 (P1) Profile update endpoint missing
- **Files:** `backend/src/routes/v1/users.routes.js`, `frontend/lib/features/profile/repositories/profile_repository.dart`
- **Problem:** Flutter profile screen sends `PATCH /users/me`; backend has no such route.
- **Fix:** Add `PATCH /users/me` with an `auth` guard and a whitelist of editable `User` fields (`name`, `avatar`, `contact`) plus an option naming convention mapping `photoUrl`/`avatarUrl` to `avatar`.

### 2.5 (P1) Session detail endpoint missing
- **Files:** `backend/src/routes/v1/session.routes.js`, `frontend/lib/features/session/repositories/session_repository.dart`
- **Problem:** Flutter `fetchSessionDetails` calls `GET /sessions/:id`. Only `GET /sessions` exists. Session detail screen always errors.
- **Fix:** Add `GET /sessions/:sessionId` (auth + orgScope) returning the session populated with subject/course/semester/section/teacher plus attendance records.

### 2.6 (P1) `logout` does not revoke server-side refresh token
- **Files:** `backend/src/controllers/auth.controller.js`, `web/*/lib/api/endpoints/auth-api.ts`, `web/*/lib/utils/authCookies.ts`
- **Problem:** Web frontends store `refreshToken` in Redux/local storage but `logoutApi()` doesn't send the refresh token. Backend `/auth/logout` reads `req.cookies.refreshToken || req.body.refreshToken`; neither is present, so the refresh token stays valid.
- **Fix:** Pass `{ refreshToken }` to `/auth/logout` and clear the `accessToken` cookie + Redux state on any 401-refresh failure.

### 2.7 (P1) Wrong Cloudinary public ID on delete
- **Files:** `backend/src/services/student.service.js`, `backend/src/services/user.service.js`
- **Problem:** Upload uses `publicId: students/${studentId}/photo` under folder `smartcampus/students`, but delete uses `smartcampus/students/students/${studentId}/photo`. Same pattern in profile photos (`smartcampus/profiles/users/...`). Deletes never remove the upload.
- **Fix:** Build the delete public id with the same pattern `smartcampus/<folder>/<publicId>` used on upload.

### 2.8 (P1) `organisations` update returns 200 with null when id is not found
- **Files:** `backend/src/controllers/organisation.controller.js`
- **Problem:** Normal update uses `findByIdAndUpdate` without existence check; non-existent org returns `sendSuccess(res, null)` (200).
- **Fix:** Check if `org` is null and throw `{ status: 404 }` before responding.

### 2.9 (P1) `resendInvite` throws generic 500 and bypasses org scope
- **Files:** `backend/src/controllers/user.controller.js`
- **Problem:** `resendInvite` finds user by id without verifying the requester's organisation, so org admins can resend invites for another org's users. It also `throw new Error(...)` (500) instead of a 4xx.
- **Fix:** Add org-scope check and return `{ status: 404 }` / `{ status: 400 }`.

### 2.10 (P2) `listTeachers`, `listOrganisations`, `listStudents` response shape mismatch vs web frontends
- **Files:** `backend/src/services/user.service.js`, `backend/src/services/organisation.service.js`, `backend/src/services/student.service.js`
- **Backend:** `{ data, total, page, limit }`
- **Web frontends:** expect `{ items, page, totalPages, totalItems }`
- **Fix:** Normalize in the API client layer (map `data`→`items`, `total`→`totalItems`, compute `totalPages`) so the backend remains backwards-compatible.

### 2.11 (P2) Duplicate/inconsistent S3 utilities
- **Files:** `backend/src/utils/s3Client.js`, `backend/src/utils/s3.util.js`
- **Problem:** Two S3 wrapper files, one imports and uses S3 even without config (fake creds), the other guards with a mock. Which is used depends on which file a service imports.
- **Fix:** Consolidate into one module with a clean `if (!configured) return mock` guard.

### 2.12 (P2) `.env` loading is environment-suffix only
- **Files:** `backend/src/config/env.js`, `backend/package.json`
- **Problem:** `NODE_ENV=development` loads `.env.development`, not `.env`. Users following `.env.example` (`.env`) get no config, so secrets silently fall back to defaults.
- **Fix:** Always load `.env`, then overlay `.env.${NODE_ENV}` if present.

### 2.13 (P2) `changePassword` dereferences possibly-null user and returns 500 on bad password
- **Files:** `backend/src/services/user.service.js`
- **Problem:** `user.password` without checking `user`; `bcrypt.compare` with undefined may crash. Error semantics also leak internal messages as 500.
- **Fix:** Guard `if (!user) throw { status: 404 }`, wrap bcrypt compare errors, map wrong password to 400.

---

## 3. Web portals

### 3.1 (P1) API responses not unwrapped
- **Files:** `web/org-admin/lib/api/endpoints/user-api.ts`, `web/org-admin/lib/api/endpoints/student-api.ts`, `web/super-admin/lib/api/endpoints/org-api.ts`, `web/super-admin/lib/api/endpoints/user-api.ts`
- **Problem:** Backend wraps all success responses as `{ success: true, data }`. The API modules return `data` directly (the wrapper), so React Query gets `{ success, data: {...} }` and every UI reads `data.items` as `undefined`.
- **Fix:** Return `data.data` and normalize list shapes.

### 3.2 (P1) `inviteTeacher` omits required `role`
- **Files:** `web/org-admin/app/(dashboard)/teachers/page.tsx`, `backend/src/validators/auth.validator.js`
- **Problem:** Frontend sends `{ name, email }`; backend Zod `inviteSchema` requires `role`. Every invite returns 400.
- **Fix:** Send `{ name, email, role: 'teacher' }` (or default role server-side).

### 3.3 (P1) `resendInvite` uses wrong path
- **Files:** `web/org-admin/lib/api/endpoints/user-api.ts`, `backend/src/routes/v1/users.routes.js`
- **Problem:** Frontend calls `/users/${userId}/resend-invite`; backend route is `/users/${userId}/resend`.
- **Fix:** Align the frontend path to the backend (`/resend`).

### 3.4 (P1) Users page depends on missing backend endpoints
- **Files:** `web/super-admin/app/(dashboard)/users/page.tsx`, `web/super-admin/lib/api/endpoints/user-api.ts`
- See backend issues 2.2/2.3.

### 3.5 (P1) Post-Next-15 dynamic params in client page
- **Files:** `web/super-admin/app/(dashboard)/organisations/[id]/page.tsx`
- See build blocker 1.1.

### 3.6 (P2) No dark theme / system theme
- **Files:** all `web/*/app/globals.css`, `web/*/tailwind.config.ts`, `web/*/app/layout.tsx`, layouts/components
- **Problem:** Tailwind config has `darkMode: "class"` but no `.dark` tokens, no theme provider, no toggle. Many components hard-code `bg-white`, `border-slate-200`, etc., so dark mode is impossible.
- **Possible solution (implemented in this branch):** shadcn/21st.dev-style CSS variable tokens in `globals.css`, `ThemeProvider` that toggles `.dark` on `<html>` and persists to `localStorage`, plus a `ThemeToggle` in the sidebar/header. Update core components to use semantic classes (`bg-background`, `bg-card`, `border-border`, `text-foreground`).

### 3.7 (P2) Toast component is not theme-aware
- **Files:** `web/*/components/ui/Toast.tsx`
- **Fix:** Use `bg-popover text-popover-foreground border-border` or `bg-secondary text-secondary-foreground` classes.

### 3.8 (P2) `middleware.ts` only checks cookie existence, not expiry/validity
- **Files:** `web/*/middleware.ts`
- **Problem:** An expired `accessToken` cookie still allows rendering protected pages; APIs then 401 and the stored cookie is not cleared.
- **Fix:** On 401 (or a shared `auth/refresh` helper), clear the cookie and redirect to login; optionally decode JWT expiry in middleware.

### 3.9 (P2) `loginApi`/refresh correctly unwrap but `logout` doesn't send refresh token
- See backend issue 2.6.

---

## 4. Flutter teacher app

### 4.1 (P1) `fetchStudentsForSession` casts the backend envelope Map to List
- **File:** `frontend/lib/features/attendance/repositories/attendance_repository.dart`
- **Problem:** `payload['data']` is a Map (`{ data: [...], total, page, limit }`), but the code does `payload['data'] as List<dynamic>`, which throws at runtime.
- **Fix:** Read `payload['data']['data']` (also accept `payload['students']` / bare list).

### 4.2 (P1) Calendar month request hits wrong endpoint and parses times incorrectly
- **File:** `frontend/lib/features/calendar/repositories/calendar_repository.dart`, `frontend/lib/features/calendar/models/calendar_session_model.dart`
- **Problem:** It calls `GET /sessions?month=...`; the backend only supports `GET /attendance/sessions/month?month=...`. `CalendarSessionModel` also parses `startTime` (backend format `"09:00"`) as a full ISO date, producing `DateTime.now()` for every session.
- **Fix:** Use `/attendance/sessions/month` and combine session `date` + `startTime` like `SessionModel` does.

### 4.3 (P1) Session detail screen always errors
- **Files:** `frontend/lib/features/session/repositories/session_repository.dart`, backend `session.routes.js`
- See backend issue 2.5.

### 4.4 (P1) Analytics model doesn't match backend response
- **File:** `frontend/lib/features/analytics/models/teacher_stats_model.dart`
- **Backend returns:** `{ overallAttendance, subjectWise: [{ subject, avgAttendance }], totalSessions }`
- **Frontend expects:** `{ overallAttendance, subjectBreakdown: [{ subjectName, attendance }], trend: [{date, attendance}] }`
- **Fix:** Normalize `subjectWise` into `subjectBreakdown` and derive `trend` as empty (or add a backend trend endpoint).

### 4.5 (P1) `listSessions` doesn't return student counts, so dashboard shows 0 students/attendance
- **Files:** `backend/src/services/attendance.service.js`, `frontend/lib/features/home/models/session_model.dart`
- **Fix:** In `listSessions`, after fetching sessions compute `totalStudents` and `presentCount` per session (or add another analytics endpoint).

### 4.6 (P1) Session/course/section fields from backend don't map cleanly to `SessionModel`
- **Files:** `frontend/lib/features/home/models/session_model.dart`
- **Problem:** Backend populates `course`, `semester`, `section` as objects and stores `startTime` as `"HH:mm"`. Model normalisation handles most cases but `courseId` uses `json['course']?['id']` before `_id`, which is wrong for Mongoose (returns `_id`), and `totalStudents`/`presentCount` default to 0/null.

### 4.7 (P1) Profile change password route is fine but update profile missing
- See backend issue 2.4.

### 4.8 (P1) QR scanner never buffers/uses the location from the backend (see backend 2.1)
- **File:** `frontend/lib/features/attendance/repositories/location_service.dart`
- **Also:** Android/iOS manifests lack location permissions (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `NSLocationWhenInUseUsageDescription`), so geofencing cannot work at runtime.

### 4.9 (P1) Theme system has two copies and the curated one is unused
- **Files:** `frontend/lib/app/theme.dart` (uses `AppTheme`, static blue `TColors`), `frontend/lib/app/theme/theme.dart` (defines `TAppTheme` with `createTheme` + curated `AppThemes`), `frontend/lib/app/theme/theme_configs.dart`
- **Problem:** `app.dart` uses `AppTheme.light/dark`; `TAppTheme` (which supports 15+ curated themes and custom component themes) is dead code. Views also hard-code `Colors.white`, `TColors.slate...`, `TColors.primary`, so dark mode is only partly themed.
- **Fix:** Use `TAppTheme.lightTheme`/`darkTheme` in `app.dart` and route all colors through `Theme.of(context)` where feasible.

### 4.10 (P2) 21st.dev-style theme request isn't reflected in configs
- **Files:** `frontend/lib/app/theme/theme_configs.dart`
- **Fix:** Add 21st.dev/shadcn-inspired "minimal shadcn neutral" and "shadcn slate+cyan" palettes, wire them as defaults.

### 4.11 (P2) `SecureStorageService.deleteTokens` deletes all secure storage keys
- **File:** `frontend/lib/core/services/secure_storage_service.dart`
- **Problem:** `deleteAll()` can wipe unrelated secrets (biometric, tokens from other features).
- **Fix:** Delete only `access_token`/`refresh_token` keys.

### 4.12 (P2) `AuthBloc` imports itself
- **File:** `frontend/lib/features/auth/bloc/auth_bloc.dart`
- **Problem:** `import 'auth_bloc.dart';` inside `auth_bloc.dart` is redundant/noisy.
- **Fix:** Remove self-import.

### 4.13 (P2) `AuthUserChanged` event has no handler
- **File:** `frontend/lib/features/auth/bloc/auth_bloc.dart`, `auth_event.dart`
- **Fix:** Register `on<AuthUserChanged>` (or remove the event).

### 4.14 (P2) `.env.example` / environment docs are stale (Supabase leftovers)
- **File:** `frontend/.env.example`
- **Fix:** Replace with `API_BASE_URL`, `BACKEND_BASE_URL`, `SOCKET_URL`, `SENTRY_DSN`, and document `--dart-define` usage.

### 4.15 (P2) iOS display name typo and missing location usage description
- **File:** `frontend/ios/Runner/Info.plist`
- **Problem:** `CFBundleDisplayName` is `"Attedance"`; no `NSLocationWhenInUseUsageDescription`.
- **Fix:** Set display name to `SmartCampus` and add location usage description.

### 4.16 (P2) QR generator timer schedules at `expiresIn` seconds instead of just before expiry
- **File:** `frontend/lib/features/attendance/bloc/qr_generator_bloc.dart`
- **Problem:** It refreshes exactly when the token expires; a student scanning near the boundary can get a stale/expired token.
- **Fix:** Schedule at `max(1, expiresIn - 2)` seconds.

### 4.17 (P2) `Attendance` state navigation pushes summary on offline save too
- **File:** `frontend/lib/features/attendance/views/carousel_attendance_screen.dart`
- **Problem:** Listener treats `AttendanceMarked` the same after offline save. That's acceptable but the snackbar + navigation ordering can be confusing; consider only navigating after a successful server sync.

---

## 5. Tests / CI / cleanup

- **P3:** `backend/scripts/smokeTest.js` default super-admin password **does not match** `.env.example` (`SuperSecret123` vs `securepassword123`); update or remove defaults.
- **P3:** `backend/src/controllers/student.controller.js` `bulkImport` is dead (real route uses `importExportController.bulkImportStudents`).
- **P3:** `backend/src/controllers/attendanceQr.controller.js` duplicates `QR` logic from `backend/src/services/qr.service.js`.
- **P3:** Flutter `frontend/lib/common/utils/constants/theme.dart` defines a legacy `appTheme` that is unused.
- **P3:** No ESLint config in either web app (`next lint` warns "No ESLint configuration detected"); `.eslintrc.json` at repo root is empty.
- **P3:** Root `package.json` lists `frontend` as a workspace (`@smartcampus` frontend has no `package.json` for npm), so root `npm install` includes a non-npm workspace.
- **P3:** `web/org-admin/app/(dashboard)/login/page.tsx` is empty/misplaced; the real login is in `(auth)/login`.

---

## 6. Recommended short-term fix order

1. Fix the super-admin Next build (1.1).
2. Wire the curated Flutter theme (`TAppTheme`) and add 21st.dev/shadcn-inspired light+dark tokens to both web portals.
3. Fix API client envelope unwrapping in all four API layer files (3.1) plus `resend`/`role` (3.2/3.3).
4. Add missing backend routes (`GET /users`, `PATCH /users/:id`, `POST /users/:id/reset-password`, `PATCH /users/me`, `GET /sessions/:id`).
5. Fix Flutter attendance list envelope (4.1), calendar endpoint/parsing (4.2), analytics mapping (4.4), session detail (4.3).
6. Add Android/iOS location permissions and debug cleartext HTTP (1.3, 4.8).
7. Implement server-side geofencing/QR validation (2.1).
8. Clean up duplication/S3/env loading (2.11–2.13).
