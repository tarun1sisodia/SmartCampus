# SmartCampus — Algorithm / Logic Files (whole repo)

Every source file in this repository has a twin in this folder that contains
**only the algorithm as comments** — no code, just 1-2 line pseudo-logic per
function/step, describing what the real file does.

| Real code | Logic twin | What it is |
|---|---|---|
| `frontend/lib/**` | `logic/**` (root of this folder) | Flutter teacher app (mobile) |
| `backend/**` | `logic/backend/**` | Node/Express API (MongoDB, Redis, Bull, Socket.IO, FCM) |
| `web/org-admin/**` | `logic/web/org-admin/**` | Organisation admin portal (Next.js, port 3000) |
| `web/super-admin/**` | `logic/web/super-admin/**` | Super-admin portal (Next.js, port 3001) |
| root `package.json`, `Makefile`, `scripts/`, `docker/` | `logic/` root | monorepo + ops files |

Skipped (no hand-written logic): generated code (`*.g.dart`), `.md` docs, `.gitignore`,
`.gitkeep` — each noted where relevant. Comment-only `.json` twins are marked as
"not valid JSON on purpose".

## Whole system in one page

1. **Teacher app (Flutter)** logs in → JWT access+refresh in secure storage → offline-first
   attendance (SQLite queue when offline) → swipe-carousel manual marking or QR.
   QR tokens rotate every 15 s (TOTP-style HMAC), scans are geofence-checked.
2. **Backend (Express)** boots only after env secret validation + dependency smoke test.
   Every route: helmet/CORS → rate limit (Redis, fail-open) → JWT auth → RBAC →
   organisation scope (multi-tenant) → zod validation → controller → service.
3. **Auth core**: refresh tokens stored sha256-hashed, rotated on every refresh,
   reuse of an old token revokes ALL sessions; passwords bcrypt-hashed once in a pre-save hook.
4. **Attendance write path**: manual `mark` / offline `sync` (server-wins by timestamp) →
   event `attendance.marked` → subscribers update the denormalised `AttendanceSummary`
   (CQRS read model), push a websocket event to the teacher and an FCM notification.
5. **Background**: Bull queues on Redis — daily 02:00 mongodump→S3 backup (distributed lock),
   Monday 08:00 low-attendance (<75%) reminders, email worker (SMTP).
6. **Web portals**: Redux Toolkit + react-query + axios client with the same 401-refresh-retry
   pattern; tokens in sessionStorage only, a non-sensitive `sc_session=1` cookie gates routes
   in Next.js middleware (real auth always enforced by the API).
7. **Ops**: npm-workspaces monorepo (`npm run dev` runs both portals); docker-compose
   dev (mongo+redis) / prod stacks; multi-stage non-root Dockerfile.

## Where to look (details)

- Flutter app flow: `logic/main.dart`, `logic/app/`, `logic/features/`, index at top of this file's history.
- Backend map: `logic/backend/README.md`
- Web portals map: `logic/web/README.md`
