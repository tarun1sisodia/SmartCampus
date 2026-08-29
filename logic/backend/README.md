// =============================================================
// backend/ folder map  ->  ALGORITHM ONLY
// =============================================================

// server.js + src/app.js       -> boot + express pipeline (helmet, cors, limits, logging, swagger)
// src/config                   -> env fail-fast, mongo, redis failover, bull queues, multer, winston
// src/middleware               -> auth(JWT), rbac, orgScope(multi-tenant), rate limiters, zod validate,
//                                 request id, error handler, circuit breaker
// src/models                   -> 15 mongoose schemas (User, Organisation, Session, Attendance,
//                                 AttendanceSummary(CQRS), Student, Course, Subject, Semester, Section,
//                                 RefreshToken(hashed+TTL), QrLog, AuditLog, BackupRecord, Feedback)
// src/routes/v1                -> /api/v1 routers (auth, users, students, attendance, session,
//                                 analytics, orgs, notifications, feedback, backup, health)
// src/controllers              -> thin HTTP layer -> services
// src/services                 -> business logic: auth(rotation+reuse detection), attendance(mark/sync/
//                                 conflicts), analytics, users, students(CSV txn), invites, qr(HMAC 15s),
//                                 email(queue), notifications(FCM), backup(mongodump->S3), cloudinary
// src/cqrs + src/events        -> commands/queries + materialized view + pub/sub subscribers
// src/jobs + src/workers       -> daily backup (redis lock), leader election, monday reminders, email worker
// src/socket                   -> Socket.IO with JWT handshake + per-user rooms
// src/validators + src/utils   -> zod schemas + jwt/bcrypt/csv/geo/s3/log helpers
// scripts + tests              -> seeds, smoke/load tests, backup cli; unit + integration + e2e tests
// (.gitignore / fixtures/.keep / *.md contain no logic — no twins)
