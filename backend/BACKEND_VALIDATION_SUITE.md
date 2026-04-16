# Backend Validation Suite (Step-by-Step)

This document is the full operational checklist to validate the SmartCampus backend before release.

Use it when:
- onboarding new environments,
- verifying a staging deployment,
- running pre-release checks,
- debugging integration issues with the Flutter frontend.

---

## 0) Prerequisites

Ensure these are available:
- Docker + Docker Compose (if running local containers)
- Node.js (matching project version)
- `curl`
- `jq` (recommended for readable JSON output)
- Access to environment variables (`.env` or deployment secrets)

Optional but useful:
- Postman / Insomnia
- MongoDB Compass
- Redis CLI

---

## 1) Environment Sanity Check

### 1.1 Validate required env variables
Verify critical values are present and non-empty:
- `PORT`
- `MONGODB_URI`
- `REDIS_URL`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`
- `JWT_ACCESS_EXPIRES_IN`
- `JWT_REFRESH_EXPIRES_IN`
- `CORS_ORIGIN`
- `NODE_ENV`

### 1.2 Confirm API base route
Expected base path from docs:
- `/api/v1`

### 1.3 Confirm backend startup mode
Log should clearly indicate environment:
- `development` / `staging` / `production`

---

## 2) Service Health Validation

## 2.1 Start services
If using Docker:

```bash
docker compose up -d
```

### 2.2 Check container/process health

```bash
docker ps
docker logs <backend-container-name> --tail 200
```

### 2.3 Verify backend responds

```bash
curl -i http://localhost:5000/api/v1/health
```

Expected:
- HTTP `200`
- health payload includes app status

### 2.4 Verify Mongo connection
Backend logs should include successful DB connect line.

### 2.5 Verify Redis connection
Backend logs should include successful Redis connect line.

---

## 3) Seed and Baseline Data Validation

### 3.1 Run seed (if required in env)

```bash
npm run seed
```

or project-specific seed command.

### 3.2 Verify seeded entities
At minimum confirm:
- one super admin
- one org admin
- one teacher
- one organization
- test course/session/student data (if seed includes these)

### 3.3 Verify teacher can authenticate
Use seed credentials in login endpoint (step 4).

---

## 4) Authentication Lifecycle Validation

Set base URL:

```bash
export BASE_URL="http://localhost:5000/api/v1"
```

### 4.1 Login

```bash
curl -sS -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"<teacher-email>","password":"<teacher-password>"}' | jq
```

Capture:
- `accessToken`
- `refreshToken`
- `user.id`

### 4.2 Access protected route with access token

```bash
curl -sS "$BASE_URL/users/me" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- HTTP `200`
- teacher profile payload

### 4.3 Refresh token flow

```bash
curl -sS -X POST "$BASE_URL/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"<REFRESH_TOKEN>"}' | jq
```

Expected:
- new access token returned

### 4.4 Logout flow

```bash
curl -sS -X POST "$BASE_URL/auth/logout" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- success response
- refresh token invalidated server-side

### 4.5 Negative auth checks
- invalid password returns `401/400`
- malformed JWT returns `401`
- missing token on protected route returns `401`

---

## 5) Core API Smoke Tests (Teacher App Critical Path)

Use valid teacher `ACCESS_TOKEN`.

### 5.1 Sessions (today)

```bash
curl -sS "$BASE_URL/sessions?date=today" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- HTTP `200`
- session list (can be empty)

### 5.2 Session detail

```bash
curl -sS "$BASE_URL/sessions/<SESSION_ID>" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- HTTP `200`
- includes session metadata

### 5.3 Students by session

```bash
curl -sS "$BASE_URL/students?sessionId=<SESSION_ID>" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- HTTP `200`
- student list with IDs and display fields

### 5.4 Mark attendance (online path)

```bash
curl -sS -X POST "$BASE_URL/attendance/mark" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId":"<SESSION_ID>",
    "attendance":[
      {"studentId":"<STUDENT_ID_1>","status":"present","timestamp":"2026-01-01T10:00:00.000Z"},
      {"studentId":"<STUDENT_ID_2>","status":"absent","timestamp":"2026-01-01T10:00:05.000Z"}
    ]
  }' | jq
```

Expected:
- HTTP `200/201`
- update count/success payload

### 5.5 Attendance summary by student

```bash
curl -sS "$BASE_URL/attendance/student/<STUDENT_ID_1>" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- HTTP `200`
- present/absent/late summary fields

### 5.6 Sync endpoint (offline replay)

```bash
curl -sS -X POST "$BASE_URL/attendance/sync" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "records":[
      {"sessionId":"<SESSION_ID>","studentId":"<STUDENT_ID_1>","status":"late","timestamp":"2026-01-01T10:05:00.000Z"}
    ]
  }' | jq
```

Expected:
- HTTP `200/201`
- processed count/sync result

---

## 6) Analytics and Calendar Coverage

### 6.1 Teacher analytics endpoint

```bash
curl -sS "$BASE_URL/analytics/teacher/<TEACHER_ID>?startDate=2026-01-01&endDate=2026-01-31" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- HTTP `200`
- overall attendance + subject breakdown + trend fields

### 6.2 Month sessions for calendar

```bash
curl -sS "$BASE_URL/sessions?month=2026-01" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- HTTP `200`
- list grouped/filterable by month range

### 6.3 History range

```bash
curl -sS "$BASE_URL/sessions?startDate=2026-01-01&endDate=2026-01-31" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

Expected:
- HTTP `200`
- sessions in range

---

## 7) Profile and Settings Endpoints

### 7.1 Fetch profile

```bash
curl -sS "$BASE_URL/users/me" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" | jq
```

### 7.2 Update profile

```bash
curl -sS -X PATCH "$BASE_URL/users/me" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Teacher Updated","contact":"+911234567890"}' | jq
```

### 7.3 Change password

```bash
curl -sS -X POST "$BASE_URL/users/change-password" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"oldPassword":"<OLD>","newPassword":"<NEW>"}' | jq
```

### 7.4 Upload photo

```bash
curl -sS -X POST "$BASE_URL/users/me/photo" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -F "photo=@/absolute/path/to/photo.jpg" | jq
```

Expected:
- HTTP `200/201`
- updated profile photo URL in payload

---

## 8) Notification Registration Validation

### 8.1 Register FCM token

```bash
curl -sS -X POST "$BASE_URL/notifications/register-token" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"token":"test-token-123","platform":"mobile"}' | jq
```

Expected:
- HTTP success
- token stored/updated for user

### 8.2 Duplicate token registration
Re-send same token and confirm idempotent behavior (no duplicates or hard failure).

---

## 9) Offline/Conflict Behavior Validation (Backend Side)

### 9.1 Replay older timestamp
- send a sync record with older timestamp than server.
- expected: server should prefer newer server value (or return conflict metadata if supported).

### 9.2 Replay newer timestamp
- send same student/session with newer timestamp.
- expected: update accepted.

### 9.3 Duplicate records in same batch
- expected deterministic behavior (last-write-wins or reject duplicates with validation error).

Document whichever behavior backend currently enforces.

---

## 10) Security and Negative Tests

Validate:
- missing required fields -> `400`
- invalid IDs -> `400/404`
- teacher accessing unauthorized org data -> `403`
- malformed JSON -> `400`
- rate limit behavior on auth routes (if enabled)

---

## 11) Performance Smoke Targets

Quick checks:
- login response under ~500ms (local/staging baseline)
- sessions list under ~700ms
- attendance mark request under ~700ms for small payload
- analytics endpoint under ~1.5s

Record p50/p95 if you have APM logs.

---

## 12) Go/No-Go Release Criteria

Release is **GO** only if:
- all critical endpoints in sections 4–8 pass
- no auth or permission regressions
- no 5xx errors in smoke run
- seed + login flows validated
- frontend critical loop tested against this backend

If any critical check fails: **NO-GO**, fix and rerun full suite.

---

## 13) Quick Execution Script (Optional)

Create a shell script `scripts/backend_smoke.sh` and run all core `curl` calls with env vars.

Minimal env vars:
- `BASE_URL`
- `TEACHER_EMAIL`
- `TEACHER_PASSWORD`
- `SESSION_ID`
- `STUDENT_ID`

This reduces human error and makes reruns fast.

---

## 14) Validation Log Template

Use this per run:

- Date/Time:
- Environment:
- Backend commit/tag:
- Validator:
- Passed sections:
- Failed sections:
- Blocking issues:
- Decision: GO / NO-GO

