# SmartCampus — Full-Stack Audit, Fixes & Completion Plan

> Audit date: 2026-08-28 · Branch: `arena/01a04934-smartcampus`
> Scope: Node.js/Express backend (`backend/`), Flutter teacher app (`frontend/`),
> Next.js portals (`web/org-admin`, `web/super-admin`).

---

## 1. How the app works (end-to-end flow)

```
┌────────────────────┐        ┌─────────────────────────────┐        ┌──────────────────┐
│ Flutter teacher app │  HTTPS │  Node/Express API  /api/v1  │        │  MongoDB         │
│ login → sessions →  ├───────►│  JWT access (15m) + refresh │───────►│  multi-tenant    │
│ carousel marking →  │        │  rotation (7d, hashed)      │        │  via `org` claim │
│ offline sqflite →   │        │  RBAC → orgScope → zod      │        └──────────────────┘
│ QR display/scanner  │        │  Redis: rate limits, Bull   │        ┌──────────────────┐
└────────────────────┘        │  Cloudinary, S3, FCM, SMTP  │───────►│  Redis / queues  │
┌────────────────────┐        └─────────────────────────────┘        └──────────────────┘
│ org-admin portal    │        Roles: super_admin (platform) → org_admin (tenant) →
│ super-admin portal  │        teacher (mobile app). Every query is filtered by
└────────────────────┘        `organisation` via orgScope middleware.
```

**Core journeys**
1. **Auth**: login → access JWT (role+org embedded) + rotating refresh token (stored SHA-256-hashed, httpOnly cookie on web / secure storage on mobile).
2. **Attendance**: teacher opens today's session → students list (`GET /students?sessionId=`) → carousel marking → `POST /attendance/mark` (online) or sqflite queue → `POST /attendance/sync` (offline, server-timestamp conflict resolution).
3. **QR attendance**: teacher displays rotating 15-second HMAC token QR (`sessionId:token`) → attendee scans → `POST /attendance/qr/verify` validates signature, session liveness, tenant, optional geofence → marks self present (`markedVia=qr`).
4. **Analytics**: `attendance.marked` event → CQRS materialised view (`AttendanceSummary`) → class/student/teacher reports.
5. **Admin portals**: org-admin manages teachers + CSV import; super-admin manages organisations, users, backups, audit logs.

---

## 2. Bugs found & fixed in this pass

Legend: 🔴 critical (broken feature or exploitable) · 🟠 high · 🟡 medium · ⚪ hardening

### Backend — functional breaks

| # | Sev | File | Defect → Fix |
|---|-----|------|--------------|
| 1 | 🔴 | `services/attendance.service.js` | Param typo `teaciherId` used as `teacherId` → **ReferenceError on every attendance mark**. Fixed + added owner/tenant checks. |
| 2 | 🔴 | `services/auth.service.js`, `services/user.service.js` | Password reset/change bcrypt-hashed the value, then the `User` pre-save hook **hashed it again** → permanent lockout. Fixed: assign plaintext, single canonical hash in hook. |
| 3 | 🔴 | `routes/v1/attendance.routes.js` | `/qr/verify` guarded by `rbac('student')` — role doesn't exist → always 403. Endpoint now validates properly (session liveness, tenant, geofence, self-marking) for the student role introduced by the student app; QR verify was otherwise dead code. |
| 4 | 🔴 | `models/User.model.js` | `toJSON()` didn't strip `resetPasswordToken` → **password-reset token leaked** in login/`/users/me`/teacher list responses. Fixed (also strips invite/fcm fields). |
| 5 | 🟠 | API surface | Endpoints the apps call but that didn't exist: `PATCH /users/me`, `GET /sessions/:id`, `GET /users` (super-admin), `PATCH /users/:id`, `POST /users/:id/reset-password`, `/users/:id/resend-invite` alias. All added. |
| 6 | 🟠 | `GET /sessions` | Calendar `?month=YYYY-MM` was ignored → unbounded unfiltered list. Now handled (validated, bounded). |
| 7 | 🟠 | `controllers/analytics.controller.js` | `.sort('date -1')` invalid → query error. Fixed to `.sort({date:-1})`. |
| 8 | 🟠 | `controllers/backup.controller.js` | Restore endpoint returned **fake success**. Now honest `501 Not Implemented`. |
| 9 | 🟡 | `services/notification.service.js` | `$addToSet` with `createdAt` grew `fcmTokens` unbounded. Now dedupes by token + caps at 10. |
| 10 | 🟡 | `package.json` | `@aws-sdk/client-s3@^3.0.0` floats to versions whose transitive `@aws-sdk/xml-builder`/`@smithy/*` were never in the lockfile → **runtime import crash**. Pinned explicitly. |

### Backend — security

| # | Sev | Area | Defect → Fix |
|---|-----|------|--------------|
| 11 | 🔴 | secrets | Hardcoded JWT/QR secret fallbacks (`'access-secret-key'`, `'super_secret_attendance_salt'`). Removed; `config/env.js` **fails fast in production** on missing/weak/default secrets. |
| 12 | 🔴 | `socket/index.js` | Handshake trusted any client-supplied `userId` → **impersonation of the realtime channel**. Now requires a signed access-token JWT. |
| 13 | 🔴 | invitations | org_admin could invite a **super_admin** (privilege escalation); resend-invite had **no tenant check** (cross-org IDOR). Role hierarchy enforced (`super_admin→org_admin/teacher`, `org_admin→teacher` only), tenant pinned, teacher-seat limit enforced. |
| 14 | 🔴 | `services/student.service.js` | Photo upload/delete targeted any student in any org by id (IDOR). Now org-scoped. |
| 15 | 🟠 | tokens | Refresh tokens: bcrypt-loop lookup O(n), reuse undetected, plaintext-equivalents recoverable. Now SHA-256-hashed with unique index (O(1) lookup), **reuse detection revokes all sessions**, rotation on every refresh, revocation on password change/reset/deactivation/role change. |
| 16 | 🟠 | `forgot-password` | User enumeration (distinguishable errors) + plaintext reset token stored. Uniform response, hashed token, `resetPasswordToken` lookups by hash. |
| 17 | 🟠 | rate limiting | Login-only limiting; forgot/reset/refresh/accept-invite were unbounded; Redis outage 500'd every request. New limiter tiers (`strict`/`sensitive`/`standard`) with **fail-open** Redis outage handling and correct proxy-aware IP keying (`trust proxy`). |
| 18 | 🟠 | mass assignment | `POST /attendance/sessions`, student create/update, org update spread `req.body` (could override `organisation`, `isActive`, `createdBy`, `status`…). Field whitelists everywhere. |
| 19 | 🟠 | uploads | Multer disk storage used raw `originalname` (path traversal / orphaned files) and trusted client mime types. Now **memory storage + magic-byte validation**, 2MB cap, single file. |
| 20 | 🟠 | errors | Global handler leaked internal error messages in production. Now masks 5xx, logs stack server-side, returns `requestId` for correlation. |
| 21 | 🟠 | ReDoS | Student search built `RegExp(userInput)` raw. Input escaped now. |
| 22 | 🟠 | backup | `exec()` with shell-interpolated `MONGO_URI` (injection surface). Now `execFile` (no shell) + job timeout + correct `AWS_BACKUP_BUCKET` env (was `AWS_BUCKET`, contradicting `.env.example`). |
| 23 | ⚪ | app.js | `trust proxy`, 1MB JSON cap, env-driven CORS (multi-origin), Swagger **disabled in production**, health checks skipped in access logs, morgan piped to winston in prod. |
| 24 | ⚪ | cookies | Refresh cookie now scoped `path=/api/v1/auth` (was site-wide). |
| 25 | ⚪ | QR | Token widened to 16 hex (64-bit), timing-safe compare, session-window enforcement (same day, start−10m…end+30m), tenant check on verify, optional campus geofence (`QR_GEOFENCE_*`) with distance rejection; device coordinates stored for audit. Consolidated duplicate logic into `services/qr.service.js`. |
| 26 | ⚪ | validation | Zod middleware supports body/query/params and returns flattened field errors; password policy (8+ chars, upper/lower/digit) on invite-accept/reset/change. |
| 27 | ⚪ | misc | CSV import capped (5MB / 5000 rows), email HTML-escaping (injection via inviter name), org suspension now deactivates tenant users, self-deactivation blocked, teachers-page rate limits, Swagger/`auth/register` stub removed. |

### Flutter app

| # | Sev | File | Defect → Fix |
|---|-----|------|--------------|
| 28 | 🔴 | `refresh_token_interceptor.dart` | Parallel 401s triggered concurrent refreshes → token-rotation race → **random forced logouts**. Now single-flight: one shared refresh future, all queued requests retry with the new token. |
| 29 | 🔴 | `AndroidManifest.xml` | `geolocator` used for geofenced QR but **no location permissions** → geofencing silently never worked; `POST_NOTIFICATIONS` missing for Android 13+. Both added. |
| 30 | 🟠 | `ios/Runner/Info.plist` | Missing `NSLocationWhenInUseUsageDescription`. Added. |
| 31 | 🟡 | `.env.example` | Stale Supabase variables from the removed backend. Replaced with current `BACKEND_BASE_URL`/`SOCKET_URL`/`SENTRY_DSN` + dart-define docs. |

### Web portals (org-admin & super-admin)

| # | Sev | Defect → Fix |
|---|-----|--------------|
| 32 | 🔴 | Tokens lived only in Redux memory → **every page reload logged the user out** (refresh interceptor had no token to use). Auth now persists to `sessionStorage` and hydrates the store on boot. |
| 33 | 🟠 | Raw access token mirrored into a JS-readable cookie for the middleware gate. Cookie now holds a **non-sensitive `sc_session` flag**; the API still enforces real auth per request. |
| 34 | 🟠 | Response-envelope mismatches (pages read fields the API never returns → blank/broken screens): teachers list (`items`), import result (`successCount` vs `succeeded`), users list, organisations list, invite payload (missing `role`). All mapped properly now. |
| 35 | 🟡 | `resend-invite` path mismatch (`/resend` vs `/resend-invite`) — backend now serves both aliases. |

### CI/CD (found broken, documented)

| # | Issue |
|---|-------|
| 36 | `.github/workflows/ci.yml`, `cd-backend-dev.yml`, `cd-backend-prod.yml`, `cd-frontend.yml` are **0-byte empty files**. `ci.yml` is filled in with lint+audit+typecheck in this pass. |
| 37 | Root `.eslintrc.json`, `.prettierrc`, `Makefile` are empty; `analysis_results.txt` refers to source files deleted long ago (stale). |

---

## 3. Verification performed

- `node --check` across all backend files — clean.
- Full module-graph import test (40+ modules) — clean.
- Regression harness (in-repo run): QR token gen/validate/reject, SHA-256 token hashing, password policy, zod middleware, `markBulk` (typo fix + owner/tenant enforcement), month parsing, ReDoS escape, **production boot refuses to start without secrets** — all green.
- Live-server smoke test: rate limiter fails open with Redis down (401 not 500/hang), health 200, 404 handler, Swagger dev-only — all green.
- `tsc --noEmit` on both portals — clean; `next build` (org-admin) — success.
- Dart changes hand-reviewed (Flutter SDK unavailable in sandbox); the single-flight refresh type mismatch was caught and fixed in review.

---

## 4. Completion plan (recommended order)

### Phase 0 — ship what's here (done)
All critical fixes above. **Migration note:** existing `RefreshToken` documents store bcrypt hashes in `token`; the new lookup uses `tokenHash` (SHA-256). Deploying invalidates all current sessions once (users just log in again) — acceptable for pre-GA; run `db.refreshtokens.deleteMany({})` after deploying.

### Phase 1 — close the remaining backend gaps (1–2 weeks)
1. **Student role app/flow** — QR verify is student-only by design; either ship the student app or expose a teacher flow that marks a scanned student present (`POST /attendance/qr/mark-student` with `{sessionId, token, studentId}` restricted to the session teacher).
2. **Session lifecycle** — add `status` (`scheduled/live/completed`) + cron to auto-complete; QR window then derives from `status` instead of clock math.
3. **Audit logging coverage** — log every mutating admin action (invites, role changes, org suspension, backups) — the `AuditLog` model exists but is barely written.
4. **Refresh-token cleanup job** — TTL index exists; add monitoring. Add per-account lockout (5 fails → 15 min) on top of IP limiting.
5. **Backups** — implement `restoreBackup` behind a confirmation token + change-window; add S3 retention policy; alert on job failure.
6. **Tests** — port the in-repo smoke harness into `backend/tests` (jest + mongodb-memory-server in CI), add supertest suites per route group, target the auth/tenant matrix (super_admin/org_admin/teacher × org A/B).

### Phase 2 — Flutter readiness (2–3 weeks)
1. Resolve the **QR product ambiguity**: the teacher app contains a *student-style* self-marking scanner. Decide: (a) teacher scans student ID-QRs, or (b) remove the scanner until the student app exists (backend already rejects teachers with a clear 403).
2. `flutter analyze --fatal-infos` in CI (the `flutter-ci.yml` workflow exists — keep it, add analyze job), integration test the offline-sync conflict path.
3. Certificate pinning for the production API host; ensure `API_BASE_URL` dart-define is injected from CI secrets, never committed.
4. Remove unused `get`/GetX + legacy `common/utils/http` layers to shrink attack/maintenance surface.

### Phase 3 — portals (1–2 weeks)
1. Implement the scaffolded pages against real endpoints: org-admin dashboard (`/analytics/organisation` — new endpoint), courses/sessions listing endpoints; super-admin audit-logs (`/audit-logs` — new read endpoint with filters + CSV export) and backups pages (wire `/backup/list` + `/backup/create`).
2. Move refresh tokens fully server-side for the web (httpOnly cookie already emitted by `/auth/login`; portals currently use the body variant) and add a CSRF strategy (double-submit token) for cookie-based refresh.
3. Add role gates in the portals (org-admin portal should refuse `super_admin` logins and vice versa — currently any role can log into any portal).

### Phase 4 — hardening & ops (ongoing)
1. **Secrets management** — move to a vault/SSM; rotate all JWT/QR secrets (they appear in historical commit `analysis_results.txt`-adjacent docs); add `git-secrets`/`trufflehog` to CI.
2. **Dependency policy** — dependabot is configured; add `npm audit --audit-level=high` gate (now in `ci.yml`), enable CodeQL for the JS/TS projects (workflow exists).
3. **Observability** — Sentry release tagging, 5xx alerting, Redis/Mongo/Cloudinary/S3 health dashboards (`/health` already reports them).
4. **Data protection** — encrypt Mongo at rest, TLS-only Redis (rediss), signed S3 URLs for backups, Cloudinary strict folder ACLs, GDPR/DPDP data-export & delete endpoints for students.
5. **Abuse controls** — per-org export throttling, anomaly alerts on mass exports, WAF/CloudFront in front of the API, request body schema validation at the edge.

---

## 5. New/changed configuration

```bash
# backend/.env (production) — server REFUSES to boot without these
JWT_ACCESS_SECRET=<openssl rand -hex 48>
JWT_REFRESH_SECRET=<openssl rand -hex 48>
QR_SECRET_KEY=<openssl rand -hex 32>
QR_GEOFENCE_LAT=            # optional campus fence (all 3 required to enforce)
QR_GEOFENCE_LON=
QR_GEOFENCE_RADIUS_METERS=
FRONTEND_URL=https://admin.example.com,https://super.example.com
AWS_BACKUP_BUCKET=smartcampus-backups
CSV_MAX_ROWS=5000
```

Mobile build: `flutter build apk --dart-define=API_BASE_URL=https://api.example.com/api/v1`
Portals: `NEXT_PUBLIC_API_URL=https://api.example.com/api/v1`
