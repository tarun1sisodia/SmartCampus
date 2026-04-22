# SmartCampus Backend – Complete Production‑Ready Architecture

This document is the **single source of truth** for building, deploying, and scaling the SmartCampus backend. It covers:

- Multi‑tenant (schools/colleges) with roles: super_admin, org_admin, teacher  
- Full DevOps (Docker, GitHub Actions, Render, Railway, AWS, Vercel)  
- Branching strategy (dev → test → staging → prod)  
- Detailed algorithms for every controller & service  
- Advanced patterns: CQRS, Event Sourcing, Circuit Breaker, Publisher/Subscriber, Sharding, Leader Election, Ambassador  
- Caching (Redis), Async messaging (RabbitMQ / Bull), Security (JWT, RBAC, rate limiting, Helmet, CORS)  
- Testing (Jest, Supertest, E2E), Monitoring (Sentry, Prometheus)  
- Future AI/ML integration roadmap

---

## Table of Contents

1. [Technology Stack](#1-technology-stack)  
2. [Project Structure (Complete)](#2-project-structure-complete)  
3. [Branching & Environment Strategy](#3-branching--environment-strategy)  
4. [Configuration for Deployment Platforms](#4-configuration-for-deployment-platforms)  
   - Docker  
   - Render / Railway  
   - Vercel (Frontend + API routes)  
   - AWS (ECS, RDS, S3, CloudFront)  
5. [GitHub Actions CI/CD](#5-github-actions-cicd)  
6. [Data Models (Multi‑Tenant)](#6-data-models-multi-tenant)  
7. [Controllers & Services – Detailed Algorithms](#7-controllers--services--detailed-algorithms)  
   - Authentication & Invitation Flow  
   - Student Management  
   - Attendance Marking (Carousel)  
   - Analytics & Reporting  
   - Backup & Restore  
8. [API Routes (Complete Mapping)](#8-api-routes-complete-mapping)  
9. [Security & Middleware](#9-security--middleware)  
10. [Caching & Asynchronous Messaging](#10-caching--asynchronous-messaging)  
11. [Advanced Design Patterns](#11-advanced-design-patterns)  
    - CQRS (Command Query Responsibility Segregation)  
    - Event Sourcing (Audit Trail)  
    - Circuit Breaker  
    - Publisher/Subscriber (Redis Pub/Sub or RabbitMQ)  
    - Leader Election (for backup jobs)  
    - Ambassador Pattern (sidecar proxy)  
    - Sharding (database)  
12. [Testing Strategy](#12-testing-strategy)  
13. [Monitoring & Error Tracking (Sentry)](#13-monitoring--error-tracking-sentry)  
14. [Future AI/ML Integration Roadmap](#14-future-aiml-integration-roadmap)  
15. [.gitignore File](#15-gitignore-file)  
16. [Environment Variables (.env)](#16-environment-variables-env)  
17. [How to Use This Document for AI Code Generation](#17-how-to-use-this-document-for-ai-code-generation)

---

## 1. Technology Stack

| Layer               | Technology Choices (Production)                          |  
|---------------------|----------------------------------------------------------|  
| **Runtime**         | Node.js 20 LTS (with PM2 cluster or Docker)              |  
| **Framework**       | Express.js (or Fastify for higher performance)           |  
| **Database**        | MongoDB (Atlas or self‑hosted replica set)               |  
| **ODM**             | Mongoose (with plugins for soft delete, timestamps)      |  
| **Caching**         | Redis (Upstash / self‑managed)                           |  
| **Message Queue**   | Bull (Redis‑based) + optional RabbitMQ for heavy events  |  
| **Auth**            | JWT (access + refresh) with HTTP‑only cookie option      |  
| **Validation**      | Zod (better TypeScript support) or Joi                   |  
| **Logging**         | Winston + Morgan + Slack webhook for errors              |  
| **Testing**         | Jest, Supertest, MongoDB Memory Server                   |  
| **CI/CD**           | GitHub Actions                                           |  
| **Hosting**         | AWS (ECS Fargate, RDS, S3) OR Render/Railway (simpler)   |  
| **Monitoring**      | Sentry (errors), Prometheus + Grafana (metrics)          |  
| **Task Scheduling** | node-cron + Bull repeatable jobs                         |

---

## 2. Project Structure (Implemented)

```  
smartcampus-backend/  
├── .github/  
│   └── workflows/  
│       ├── ci.yml               # run tests on PR  
│       ├── cd-dev.yml           # deploy to dev on merge to dev  
│       ├── cd-staging.yml       # deploy to staging on merge to staging  
│       └── cd-prod.yml          # deploy to prod on tag  
├── src/  
│   ├── config/  
│   │   ├── database.js  
│   │   ├── redis.js  
│   │   ├── bull.js  
│   │   ├── multer.js  
│   │   └── logger.js  
│   ├── models/  
│   │   ├── Organisation.model.js  
│   │   ├── User.model.js  
│   │   ├── Student.model.js  
│   │   ├── Course.model.js  
│   │   ├── Subject.model.js  
│   │   ├── Semester.model.js  
│   │   ├── Section.model.js  
│   │   ├── Session.model.js  
│   │   ├── Attendance.model.js  
│   │   ├── RefreshToken.model.js  
│   │   ├── AuditLog.model.js  
│   │   └── BackupRecord.model.js  
│   ├── services/  
│   │   ├── auth.service.js  
│   │   ├── user.service.js  
│   │   ├── organisation.service.js  
│   │   ├── invitation.service.js  
│   │   ├── student.service.js  
│   │   ├── attendance.service.js  
│   │   ├── analytics.service.js (CQRS read side)  
│   │   ├── backup.service.js  
│   │   ├── email.service.js  
│   │   └── eventBus.service.js (pub/sub)  
│   ├── controllers/  
│   │   ├── auth.controller.js  
│   │   ├── user.controller.js  
│   │   ├── organisation.controller.js  
│   │   ├── student.controller.js  
│   │   ├── attendance.controller.js  
│   │   ├── analytics.controller.js  
│   │   ├── importExport.controller.js  
│   │   └── backup.controller.js  
│   ├── routes/  
│   │   ├── v1/  
│   │   │   ├── auth.routes.js  
│   │   │   ├── users.routes.js  
│   │   │   ├── orgs.routes.js  
│   │   │   ├── students.routes.js  
│   │   │   ├── attendance.routes.js  
│   │   │   ├── analytics.routes.js  
│   │   │   └── backup.routes.js  
│   │   └── index.js  
│   ├── middleware/  
│   │   ├── auth.middleware.js  
│   │   ├── rbac.middleware.js  
│   │   ├── orgScope.middleware.js  
│   │   ├── validation.middleware.js (Zod)  
│   │   ├── rateLimiter.js  
│   │   ├── circuitBreaker.js (for external services)  
│   │   ├── errorHandler.js  
│   │   └── requestId.js  
│   ├── validators/  
│   │   ├── auth.validator.js  
│   │   ├── student.validator.js  
│   │   ├── attendance.validator.js  
│   │   └── org.validator.js  
│   ├── utils/  
│   │   ├── apiResponse.js  
│   │   ├── generateToken.js  
│   │   ├── hashPassword.js  
│   │   ├── dateHelper.js  
│   │   ├── csvParser.js  
│   │   ├── s3Client.js  
│   │   └── sentry.js  
│   ├── jobs/  
│   │   ├── dailyBackup.job.js  
│   │   ├── sendReminders.job.js  
│   │   ├── materializedViewRefresh.job.js (CQRS)  
│   │   └── leaderElection.js (for backup)  
│   ├── events/  
│   │   ├── publishers/  
│   │   │   ├── attendanceMarked.publisher.js  
│   │   │   └── studentEnrolled.publisher.js  
│   │   └── subscribers/  
│   │       ├── updateAnalytics.subscriber.js  
│   │       └── sendNotification.subscriber.js  
│   ├── cqrs/  
│   │   ├── commands/  
│   │   │   ├── markAttendance.command.js  
│   │   │   └── importStudents.command.js  
│   │   ├── queries/  
│   │   │   ├── getAttendanceReport.query.js  
│   │   │   └── getStudentSummary.query.js  
│   │   └── materializedViews/  
│   │       └── attendanceSummary.view.js  
│   └── app.js  
├── tests/  
│   ├── unit/  
│   ├── integration/  
│   ├── e2e/  
│   └── fixtures/  
├── scripts/  
│   ├── seed.js  
│   ├── backupDB.js  
│   └── migrate.js  
├── docker/  
│   ├── Dockerfile  
│   ├── docker-compose.dev.yml  
│   └── docker-compose.prod.yml  
├── .env.example  
├── .gitignore  
├── package.json  
├── server.js  
├── README.md  
└── vercel.json (if using Vercel for API routes)  
```

---

## 3. Branching & Environment Strategy

We follow **GitHub Flow** with environment branches:

| Branch     | Purpose                                   | Deployed to      | Protection rules                          |  
|------------|-------------------------------------------|------------------|-------------------------------------------|  
| `dev`      | Active development, feature branches merge here | Render/Railway dev | Requires PR, 1 approval, all tests pass |  
| `test`     | Integration testing, manual QA            | Render test       | Merges from `dev` after QA sign‑off       |  
| `staging`  | Pre‑production, load testing, UAT         | AWS staging       | Merges from `test`, requires 2 approvals  |  
| `main`     | Production code (tagged releases)         | AWS prod          | Only from `staging` via PR, 3 approvals, full CI |

**Feature branches** (e.g., `feature/attendance-carousel`) branch from `dev` → PR to `dev`.

**Hotfix branches** branch from `main` → PR to `main` and backport to `dev`.

---

## 4. Configuration for Deployment Platforms

### 4.1 Docker (All environments)

**Dockerfile** (production):  
```dockerfile  
FROM node:20-alpine as builder  
WORKDIR /app  
COPY package*.json ./  
RUN npm ci --only=production

FROM node:20-alpine  
RUN apk add --no-cache tini  
WORKDIR /app  
COPY --from=builder /app/node_modules ./node_modules  
COPY . .  
EXPOSE 5000  
ENTRYPOINT ["/sbin/tini", "--"]  
CMD ["node", "server.js"]  
```

**docker-compose.dev.yml** (local dev with hot reload):  
```yaml  
version: '3.8'  
services:  
  backend:  
    build: .  
    ports:  
      - "5000:5000"  
    volumes:  
      - ./src:/app/src  
    environment:  
      - NODE_ENV=development  
      - MONGO_URI=mongodb://mongo:27017/smartcampus  
      - REDIS_URL=redis://redis:6379  
    depends_on:  
      - mongo  
      - redis  
  mongo:  
    image: mongo:6  
    ports:  
      - "27017:27017"  
    volumes:  
      - mongo_data:/data/db  
  redis:  
    image: redis:7-alpine  
    ports:  
      - "6379:6379"  
volumes:  
  mongo_data:  
```

### 4.2 Render / Railway

- **Render**: Use `render.yaml` blueprint.  
```yaml  
services:  
  - type: web  
    name: smartcampus-backend  
    runtime: node  
    plan: starter  
    envVars:  
      - key: NODE_ENV  
        value: production  
      - key: MONGO_URI  
        fromDatabase:  
          name: smartcampus-db  
          property: connectionString  
      - key: REDIS_URL  
        fromService:  
          type: redis  
          name: smartcampus-redis  
          property: connectionString  
    buildCommand: npm ci  
    startCommand: node server.js  
```  
- **Railway**: Connect GitHub repo, set `NODE_ENV`, `MONGO_URI`, `REDIS_URL` as variables. Railway automatically injects Redis and MongoDB if you add plugins.

### 4.3 Vercel (for API routes – optional)

If you want to deploy Express as serverless functions, create `vercel.json`:  
```json  
{  
  "functions": {  
    "api/*.js": {  
      "maxDuration": 10,  
      "memory": 1024  
    }  
  },  
  "rewrites": [{ "source": "/api/(.*)", "destination": "/api/$1" }]  
}  
```  
But Vercel is not ideal for WebSockets or long‑running background jobs. Use it only for lightweight endpoints.

### 4.4 AWS (Production)

- **Compute**: ECS Fargate (tasks) + Application Load Balancer.  
- **Database**: MongoDB Atlas (or self‑managed EC2 with replica set) / Amazon DocumentDB.  
- **Caching**: ElastiCache for Redis.  
- **Queue**: Amazon MQ (RabbitMQ) or SQS + Bull (with Redis).  
- **Storage**: S3 for student photos, backups.  
- **CDN**: CloudFront for static assets.  
- **Monitoring**: CloudWatch + Sentry.

**Sample ECS Task Definition** (JSON):  
```json  
{  
  "family": "smartcampus-backend",  
  "taskRoleArn": "arn:aws:iam::...",  
  "networkMode": "awsvpc",  
  "containerDefinitions": [{  
    "name": "backend",  
    "image": ".../smartcampus:latest",  
    "portMappings": [{ "containerPort": 5000 }],  
    "environment": [  
      { "name": "NODE_ENV", "value": "production" },  
      { "name": "MONGO_URI", "value": "mongodb://..." },  
      { "name": "REDIS_URL", "value": "redis://..." }  
    ]  
  }]  
}  
```

---

## 5. GitHub Actions CI/CD

Create `.github/workflows/ci.yml` (runs on all PRs to `dev`, `test`, `staging`, `main`):

```yaml  
name: CI  
on:  
  pull_request:  
    branches: [dev, test, staging, main]  
jobs:  
  test:  
    runs-on: ubuntu-latest  
    services:  
      mongo:  
        image: mongo:6  
        ports:  
          - 27017:27017  
      redis:  
        image: redis:7  
        ports:  
          - 6379:6379  
    steps:  
      - uses: actions/checkout@v4  
      - uses: actions/setup-node@v4  
        with:  
          node-version: 20  
      - run: npm ci  
      - run: npm run test:unit  
      - run: npm run test:integration  
      - run: npm run lint  
```

Create `.github/workflows/cd-dev.yml` (deploy to Render on merge to `dev`):

```yaml  
name: Deploy to Dev  
on:  
  push:  
    branches: [dev]  
jobs:  
  deploy:  
    runs-on: ubuntu-latest  
    steps:  
      - uses: actions/checkout@v4  
      - name: Deploy to Render  
        uses: johnbeynon/render-deploy-action@v0.0.8  
        with:  
          service-id: ${{ secrets.RENDER_DEV_SERVICE_ID }}  
          api-key: ${{ secrets.RENDER_API_KEY }}  
```

Similarly for `cd-staging.yml` and `cd-prod.yml` (AWS ECS deploy using `aws-actions/amazon-ecs-deploy-task-definition`).

---

## 6. Data Models (Multi‑Tenant – Recap & Enhancements)

All models include `organisation` field (except `Organisation` itself).    
Add `AuditLog` and `BackupRecord`.

**AuditLog.model.js**:  
```javascript  
{  
  organisation: { type: ObjectId, ref: 'Organisation' },  
  user: { type: ObjectId, ref: 'User' },  
  action: String,          // e.g., "DELETE_STUDENT", "MARK_ATTENDANCE"  
  entityType: String,      // "Student", "Attendance", etc.  
  entityId: ObjectId,  
  oldValues: Object,  
  newValues: Object,  
  ip: String,  
  userAgent: String,  
  timestamp: Date  
}  
```

**BackupRecord.model.js**:  
```javascript  
{  
  organisation: { type: ObjectId, ref: 'Organisation' }, // null = global  
  backupType: { type: String, enum: ['full', 'incremental'] },  
  status: { type: String, enum: ['pending', 'completed', 'failed'] },  
  s3Key: String,  
  sizeBytes: Number,  
  startedAt: Date,  
  completedAt: Date,  
  triggeredBy: { type: ObjectId, ref: 'User' }  
}  
```

---

## 7. Controllers & Services – Detailed Algorithms

We separate **commands** (writes) from **queries** (reads) using CQRS pattern (see section 11). Below is the flow for each major feature.

### 7.1 Authentication & Invitation Flow (Implemented)

**Controller**: `auth.controller.js`    
**Services**: `auth.service.js`, `invitation.service.js`, `email.service.js`

#### Algorithm – Invite Teacher (Org Admin)  
```  
1. Org admin POST /api/v1/users/invite with { email, role: "teacher", name }  
2. Controller:  
   - Validate input (Zod)  
   - Check that requester.role === 'org_admin' AND requester.organisation exists  
3. invitationService.createInvite(inviter, targetEmail, role, organisationId):  
   - Check if user with email already exists AND is active → throw error  
   - Generate inviteToken = crypto.randomBytes(32).toString('hex')  
   - Create User record with:  
        name, email, role='teacher', organisation, invitedBy=inviter._id,  
        isActive=false, inviteToken, inviteExpires = now + 7 days  
   - Save to DB  
   - Trigger event 'user.invited' (pub/sub)  
4. emailService.sendInviteEmail(targetEmail, inviteToken, inviter.name)  
5. Return { message: "Invitation sent", userId }  
```

#### Algorithm – Accept Invite  
```  
1. Teacher clicks link: GET /api/v1/users/accept-invite?token=xxx  
   (Renders a password set form – frontend handles)  
2. POST /api/v1/users/accept-invite with { token, password, confirmPassword }  
3. Controller:  
   - Find user with inviteToken, isActive=false, inviteExpires > now  
   - Hash password, clear inviteToken, set isActive=true, set lastLogin  
   - Generate access+refresh tokens  
   - Return tokens + user info  
```

### 7.2 Student Management (Implemented)

**Controller**: `student.controller.js`    
**Service**: `student.service.js`

#### Algorithm – Bulk Import Students (CSV/JSON)  
```  
1. Org admin uploads CSV via POST /api/v1/students/import  
2. Controller:  
   - Validate file (multer)  
   - Parse CSV -> array of student objects (csvParser util)  
3. studentService.bulkImport(studentsArray, organisationId, requesterId):  
   - Begin transaction (MongoDB session)  
   - For each student:  
        - Validate required fields (rollNumber, name, course, semester, section)  
        - Check if rollNumber already exists in same organisation -> skip or update (configurable)  
        - Create Student record with organisationId  
   - Commit transaction  
   - Publish event 'students.imported' with summary  
4. Return { total: X, succeeded: Y, failed: Z, errors: [...] }  
```

### 7.3 Attendance Marking (Carousel) (Implemented)

**Controller**: `attendance.controller.js`    
**Service**: `attendance.service.js`    
**Pattern**: Command + Event sourcing

#### Algorithm – Mark Attendance for a Session  
```  
1. Teacher POST /api/v1/attendance/mark  
   Body: { sessionId, attendance: [{ studentId, status, remarks }] }  
2. Controller:  
   - Validate session exists and teacher has permission (teacher.organisation == session.organisation)  
   - Check that session.date is today (or within allowed past days)  
3. attendanceService.markBulk(sessionId, attendanceArray, teacherId):  
   - For each entry:  
        - Find or create Attendance record (session+student)  
        - Store old status (for audit)  
        - Update status, markedBy, timestamp  
        - Save  
   - Publish event 'attendance.marked' (studentId, sessionId, newStatus, oldStatus)  
4. Event subscriber (updateAnalytics.subscriber.js):  
   - Recompute attendance summary for that student/session and store in materialized view (CQRS read model)  
5. Return { updatedCount: X }  
```

### 7.4 Analytics & Reporting (CQRS Read Side) (Implemented)

**Controller**: `analytics.controller.js`    
**Query Service**: `analytics.service.js` (reads from materialized views)

#### Algorithm – Get Attendance Percentage by Class  
```  
1. GET /api/v1/analytics/class/:courseId?semester=xxx\&section=yyy  
2. Controller:  
   - Verify user has access to that course's organisation  
3. analyticsService.getClassAttendance(courseId, semester, section):  
   - Query materialized view `AttendanceSummary` (pre‑aggregated table)  
        db.attendanceSummary.aggregate([  
          { $match: { course: courseId, semester, section } },  
          { $group: { _id: "$student", presentCount: { $sum: "$present" }, total: { $sum: 1 } } }  
        ])  
   - Compute percentages  
   - Return { overall: 84.5%, studentList: [...] }  
```

### 7.5 Backup & Restore (Leader Election)

**Controller**: `backup.controller.js`    
**Service**: `backup.service.js`    
**Pattern**: Leader election (only one instance runs scheduled backup)

#### Algorithm – Scheduled Daily Backup (Leader only)  
```  
1. On startup, each instance attempts to become leader for backup job using Redis distributed lock (SETNX with TTL).  
2. The leader registers a cron job (node-cron) for 2 AM.  
3. At 2 AM:  
   - backupService.createFullBackup():  
        - Generate timestamp  
        - Run `mongodump --archive=/tmp/backup_$timestamp.gz --gzip --db=smartcampus`  
        - Upload to S3 (key: `backups/full_$timestamp.gz`)  
        - Save BackupRecord in DB  
        - Delete local file  
   - If organisation‑specific backups required: loop over organisations and dump each with query filter.  
4. On leader failure, another instance takes over (lock expires).  
```

---

## 8. API Routes (Implemented)

All routes under `/api/v1`.    
Full list with method, path, middleware, controller, and description.

| Method | Path | Middleware | Controller | Description |  
|--------|------|------------|------------|-------------|  
| **Auth** |||||  
| POST | `/auth/login` | rateLimit(5) | auth.login | Email/password → tokens |  
| POST | `/auth/register` | superAdminOnly | auth.registerSuperAdmin | Create first super admin (seed) |  
| POST | `/auth/refresh` | - | auth.refresh | New access token from refresh token |  
| POST | `/auth/logout` | auth | auth.logout | Invalidate refresh token |  
| **Organisations** |||||  
| POST | `/orgs` | superAdminOnly | organisation.create | Create school/college |  
| GET | `/orgs` | superAdminOnly | organisation.list | List all orgs |  
| GET | `/orgs/:orgId` | superAdminOnly | organisation.get | Get org details |  
| PATCH | `/orgs/:orgId` | superAdminOnly | organisation.update | Update subscription, status |  
| **Users & Invitations** |||||  
| POST | `/users/invite` | auth+orgAdmin | invitation.sendInvite | Invite teacher/org_admin |  
| POST | `/users/accept-invite` | public | invitation.accept | Activate account |  
| POST | `/users/:userId/resend` | auth+orgAdmin | invitation.resend | Resend invite email |  
| GET | `/users/teachers` | auth+orgAdmin | user.listTeachers | Teachers in my org |  
| DELETE | `/users/:userId` | auth+orgAdmin | user.deactivate | Soft deactivate teacher |  
| **Students** |||||  
| GET | `/students` | auth | student.list | Paginated, filter by course/semester |  
| POST | `/students` | auth+orgAdmin | student.create | Add single student |  
| POST | `/students/import` | auth+orgAdmin | student.bulkImport | Upload CSV/JSON |  
| GET | `/students/:id` | auth | student.getById | Student details + photo |  
| PUT | `/students/:id` | auth+orgAdmin | student.update | Update student |  
| DELETE | `/students/:id` | auth+orgAdmin | student.delete | Soft delete |  
| **Attendance & Sessions** |||||  
| POST | `/sessions` | auth+teacherOnly | attendance.createSession | Create lecture session |  
| GET | `/sessions` | auth | attendance.listSessions | Filter by date, teacher, subject |  
| POST | `/attendance/mark` | auth+teacherOnly | attendance.markBulk | Mark attendance for session |  
| GET | `/attendance/session/:sessionId` | auth | attendance.getBySession | List attendance of one session |  
| GET | `/attendance/student/:studentId` | auth | attendance.studentSummary | Summary per subject |  
| **Analytics** |||||  
| GET | `/analytics/class/:courseId` | auth | analytics.classReport | % per subject/student |  
| GET | `/analytics/student/:studentId` | auth | analytics.studentTrend | Attendance over time |  
| GET | `/analytics/teacher/:teacherId` | auth+orgAdmin | analytics.teacherPerformance | Teacher's session stats |  
| **Backup** |||||  
| POST | `/backup/create` | superAdminOnly | backup.create | Trigger manual full backup |  
| GET | `/backup/list` | superAdminOnly | backup.list | List backups with S3 links |  
| POST | `/backup/restore/:backupId` | superAdminOnly | backup.restore | Restore from backup |

---

## 9. Security & Middleware

### 9.1 Authentication Middleware (`auth.middleware.js`)  
```javascript  
const jwt = require('jsonwebtoken');  
module.exports = (req, res, next) => {  
  const token = req.headers.authorization?.split(' ')[1];  
  if (!token) return res.status(401).json({ error: 'No token' });  
  try {  
    const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET);  
    req.user = { id: decoded.sub, role: decoded.role, organisation: decoded.org };  
    next();  
  } catch { res.status(401).json({ error: 'Invalid token' }); }  
};  
```

### 9.2 Organisation Scope Middleware  
```javascript  
module.exports = (req, res, next) => {  
  if (req.user.role === 'super_admin') {  
    req.scope = { isSuperAdmin: true };  
    return next();  
  }  
  if (!req.user.organisation) return res.status(403).json({ error: 'No organisation' });  
  req.scope = { organisationId: req.user.organisation, isSuperAdmin: false };  
  next();  
};  
```

### 9.3 Rate Limiting (Redis‑based)  
```javascript  
const rateLimit = require('express-rate-limit');  
const RedisStore = require('rate-limit-redis');  
const limiter = rateLimit({  
  store: new RedisStore({ client: redisClient }),  
  windowMs: 15 * 60 * 1000,  
  max: 100,  
  keyGenerator: (req) => req.user?.id || req.ip  
});  
```

### 9.4 Circuit Breaker (for external services like S3, email)  
Use `opossum` library. Example for S3 upload:  
```javascript  
const breaker = new CircuitBreaker(s3UploadFunction, {  
  timeout: 5000,  
  errorThresholdPercentage: 50,  
  resetTimeout: 30000  
});  
breaker.fire(file).catch(() => { /* fallback to local storage */ });  
```

---

## 10. Caching & Asynchronous Messaging

### 10.1 Caching Strategy (Redis)

| Cache Key Pattern | TTL | Invalidation |  
|------------------|-----|---------------|  
| `student:list:org:${orgId}:page:${page}` | 5 min | On student create/update/delete |  
| `attendance:student:${studentId}:semester:${sem}` | 1 hour | On attendance.marked event |  
| `session:today:teacher:${teacherId}` | 15 min | On new session creation |

### 10.2 Asynchronous Messaging – Bull (Redis Queue)

**Queue Definition** (`jobs/emailQueue.js`):  
```javascript  
const Queue = require('bull');  
const emailQueue = new Queue('email', process.env.REDIS_URL);  
emailQueue.process(async (job) => {  
  const { to, subject, html } = job.data;  
  await sendEmail(to, subject, html);  
});  
```

**Publish event** (e.g., after invite):  
```javascript  
await emailQueue.add({ to: 'teacher@example.com', subject: 'Invite', html: '...' });  
```

### 10.3 Publisher/Subscriber (Redis Pub/Sub) for Real‑Time Updates

**Publisher** (after marking attendance):  
```javascript  
const redisPub = redisClient.duplicate();  
await redisPub.publish('attendance-updates', JSON.stringify({ sessionId, studentId, status }));  
```

**Subscriber** (WebSocket server or another microservice):  
```javascript  
redisSub.subscribe('attendance-updates', (message) => {  
  // push to connected clients via Socket.io  
});  
```

---

## 11. Advanced Design Patterns

### 11.1 CQRS (Command Query Responsibility Segregation)

- **Command** (write) side: `attendance.service.js` updates the `Attendance` collection (normalised).  
- **Query** (read) side: `analytics.service.js` reads from denormalised materialized views (e.g., `AttendanceSummary`).  
- **Materialized view refresh**: triggered by `attendance.marked` event (subscriber updates the view).

**Materialized View Schema** (`AttendanceSummary`):  
```javascript  
{  
  student: ObjectId,  
  session: ObjectId,  
  course: ObjectId,  
  subject: ObjectId,  
  semester: ObjectId,  
  date: Date,  
  status: String,  
  // pre‑joined fields for fast query  
  studentName: String,  
  rollNumber: String  
}  
```

### 11.2 Event Sourcing (Audit Trail)

Instead of only storing current state, we store **events** for every state change.    
Use `AuditLog` model as event store. For critical aggregates (e.g., student enrollment), we can rebuild state by replaying events.

**Example** – Student transfer to another section:  
- Event: `{ type: "STUDENT_SECTION_CHANGED", studentId, oldSection, newSection, timestamp }`  
- Projector updates current `Student` record.

### 11.3 Circuit Breaker (already covered)

### 11.4 Publisher/Subscriber (already covered)

### 11.5 Leader Election

Use `redis-lock` or `bull`’s `repeatable` jobs with a dedicated queue that only one worker processes.

**Implementation**:  
```javascript  
const backupQueue = new Queue('backup', { redis: redisClient });  
backupQueue.process(async (job) => {  
  if (job.name === 'daily-backup') {  
    await backupService.runFullBackup();  
  }  
});  
// Only one instance will process because Bull uses Redis for locking.  
backupQueue.add('daily-backup', {}, { repeat: { cron: '0 2 * * *' } });  
```

### 11.6 Ambassador Pattern (Sidecar Proxy)

For each backend service, run an **Envoy** or **NGINX** sidecar that handles:  
- TLS termination  
- Rate limiting  
- Request logging  
- Circuit breaking to downstream services (database, Redis)

In Kubernetes, this is a sidecar container in the same pod.

### 11.7 Sharding (Database)

If one organisation grows extremely large (> 1M students), we can shard by `organisation` field using MongoDB sharding:

```javascript  
sh.shardCollection("smartcampus.students", { "organisation": "hashed" });  
sh.shardCollection("smartcampus.attendance", { "organisation": 1, "session": 1 });  
```

This distributes data across multiple clusters.

---

## 12. Testing Strategy

### 12.1 Unit Tests (Jest)  
Test each service in isolation (mock models).    
Example: `auth.service.test.js` – test `createInvite()` logic.

### 12.2 Integration Tests (Supertest + MongoDB Memory Server)  
Spin up an in‑memory MongoDB, run API tests.    
Example: `attendance.integration.test.js` – test marking attendance end‑to‑end.

### 12.3 End‑to‑End Tests (Cypress or Playwright)  
Run against a real staging environment. Test teacher login → create session → mark attendance → view analytics.

### 12.4 Load Testing (Artillery)  
Simulate 500 teachers marking attendance simultaneously on a session.

**artillery.yml**:  
```yaml  
config:  
  target: "https://staging.smartcampus.com"  
  phases:  
    - duration: 60  
      arrivalRate: 100  
scenarios:  
  - flow:  
      - post:  
          url: "/api/v1/auth/login"  
          json: { email: "teacher@test.com", password: "[REDACTED]" }  
          capture: { json: "$.accessToken", as: "token" }  
      - post:  
          url: "/api/v1/attendance/mark"  
          headers: { Authorization: "Bearer {{ token }}" }  
          json: { sessionId: "...", attendance: [...] }  
```

### 12.5 Keep Test Scripts Up to Date  
- Run `npm run test` on every PR (GitHub Action).  
- Use `jest --coverage` to enforce >80% coverage.  
- Regularly update test fixtures when models change.

---

## 13. Monitoring & Error Tracking (Sentry)

### 13.1 Sentry Integration  
```javascript  
const Sentry = require('@sentry/node');  
Sentry.init({ dsn: process.env.SENTRY_DSN, environment: process.env.NODE_ENV });  
// In error handler:  
app.use(Sentry.Handlers.errorHandler());  
```

### 13.2 Custom Alerts  
- Winston logs to Slack webhook for `error` level.  
- Prometheus metrics: `attendance_marking_duration_seconds`, `db_query_errors_total`.  
- Grafana dashboard for CPU, memory, request rate, error rate.

### 13.3 Health Check Endpoint  
`GET /health` → returns `{ status: "ok", uptime, mongo: "connected", redis: "connected" }`.    
Used by load balancer and Kubernetes liveness probes.

---

## 14. Future AI/ML Integration Roadmap

We will introduce a **separate microservice** (Python FastAPI) for AI/ML tasks, communicating via REST or message queue.

### Phase 1 – Face Recognition for Auto‑Attendance (6‑12 months)  
- Store face embeddings for each student (in a vector DB like Pinecone or PostgreSQL pgvector).  
- Teacher captures a group photo → service detects faces → matches embeddings → marks attendance automatically.  
- **Backend changes**:  
  - New model `FaceEmbedding` (studentId, embedding vector).  
  - New endpoint `POST /ai/recognize` that accepts image and returns student IDs.  
  - Use Bull queue to process images asynchronously.

### Phase 2 – Predictive Analytics (dropout risk, attendance trends)  
- Train a model (XGBoost/LightGBM) on historical attendance, grades, demographics.  
- Expose `GET /ai/predict/student/:studentId` that returns risk score.  
- Schedule nightly feature extraction job (Node.js service that dumps data to CSV for model training).

### Phase 3 – Intelligent Timetable Scheduling  
- Use constraint satisfaction / genetic algorithm to generate optimal timetables.  
- Admin provides constraints → AI service returns suggested schedule.

### Infrastructure for AI/ML  
- Deploy Python microservice on AWS ECS (GPU instances if needed).  
- Use Redis Streams to pass messages between Node.js and Python.  
- Store models in S3, load on startup.

---

## 15. .gitignore File

```gitignore  
# Dependencies  
node_modules/  
package-lock.json  
yarn.lock

# Environment  
.env  
.env.local  
.env.*.local

# Logs  
logs/  
*.log  
npm-debug.log*

# Database dumps  
*.gz  
dump/  
backups/

# Uploads (student photos)  
uploads/  
temp/

# Coverage  
coverage/  
.nyc_output/

# IDE  
.vscode/  
.idea/  
*.swp  
*.swo

# OS  
.DS_Store  
Thumbs.db

# Build  
dist/  
build/

# Secrets  
*.pem  
*.key  
*.cert  
```

---

## 16. Environment Variables (.env)

```env  
# Server  
NODE_ENV=production  
PORT=5000  
HOST=0.0.0.0

# Database  
MONGO_URI=mongodb://localhost:27017/smartcampus?replicaSet=rs0  
MONGO_DB_NAME=smartcampus

# Redis  
REDIS_URL=redis://localhost:6379  
REDIS_PASSWORD=

# JWT  
JWT_ACCESS_SECRET=your-very-long-secret-min-32-chars  
JWT_REFRESH_SECRET=another-long-secret  
ACCESS_TOKEN_EXPIRY=15m  
REFRESH_TOKEN_EXPIRY=7d

# AWS (S3, SES)  
AWS_REGION=us-east-1  
AWS_ACCESS_KEY_ID=AKIA...  
AWS_SECRET_ACCESS_KEY=...  
S3_BACKUP_BUCKET=smartcampus-backups  
S3_PHOTO_BUCKET=smartcampus-photos

# Email (SMTP fallback)  
SMTP_HOST=smtp.sendgrid.net  
SMTP_PORT=587  
SMTP_USER=apikey  
SMTP_PASS=your-sendgrid-key

# Sentry  
SENTRY_DSN=https://...

# Super Admin (seed)  
SUPER_ADMIN_EMAIL=super@smartcampus.com  
SUPER_ADMIN_PASSWORD=[REDACTED]

# Feature flags  
ENABLE_AI_FACE_RECOGNITION=false  
ENABLE_CQRS_MATERIALIZED_VIEWS=true  
```

---

## 17. How to Use This Document for AI Code Generation

1. **Prompt the AI** with:    
   *“*Based on the SmartCampus backend specification below, generate the complete code for every file described. Follow all algorithms, patterns, and folder structure. Start with the configuration files, then models, services, controllers, routes, middleware, validators, utils, jobs, events, CQRS components, entry points, tests, and scripts. Produce the code file by file.”**  
2. **Iterate** – generate one folder at a time (models → services → controllers → routes → middleware).  
3. **Run the seed script** to create the initial super admin.  
4. **Deploy** using the provided Dockerfiles and GitHub Actions.  
5. **Monitor** with Sentry and Prometheus.

This document is **complete and executable** –  
---  
# SmartCampus Backend – Complete Algorithmic Specification

This document provides **step‑by‑step algorithms** for every file in the project structure described earlier.  

All algorithms follow the multi‑tenant architecture (organisations, roles: super_admin, org_admin, teacher), CQRS, event sourcing, caching, and security patterns.

---

## Table of Contents

1. [Configuration Files](#1-configuration-files)  
2. [Models (Mongoose Schemas)](#2-models-mongoose-schemas)  
3. [Services (Business Logic)](#3-services-business-logic)  
4. [Controllers (Request Handlers)](#4-controllers-request-handlers)  
5. [Routes](#5-routes)  
6. [Middleware](#6-middleware)  
7. [Validators](#7-validators)  
8. [Utils (Helpers)](#8-utils-helpers)  
9. [Jobs (Background Tasks)](#9-jobs-background-tasks)  
10. [Events (Pub/Sub)](#10-events-pubsub)  
11. [CQRS Components](#11-cqrs-components)  
12. [Entry Points (app.js, server.js)](#12-entry-points-appjs-serverjs)  
13. [Test Scripts](#13-test-scripts)  
14. [Scripts (Seed, Backup, Migrate)](#14-scripts-seed-backup-migrate)

---

## 1. Configuration Files

### 1.1 `config/database.js`  
**Algorithm:**  
1. Import mongoose.  
2. Read `MONGO_URI` from environment.  
3. Set mongoose options: `useNewUrlParser`, `useUnifiedTopology`.  
4. Define `connectDB` function:  
   - Try to await `mongoose.connect(uri, options)`.  
   - If success, log “MongoDB connected” and emit event.  
   - If error, log error and exit process with code 1.  
5. Export `connectDB`.

### 1.2 `config/redis.js`  
**Algorithm:**  
1. Import Redis (`ioredis` or `redis` package).  
2. Read `REDIS_URL` from env.  
3. Create a new Redis client with the URL.  
4. Add event listeners: `connect` (log), `error` (log and maybe retry).  
5. Export the client.

### 1.3 `config/bull.js`  
**Algorithm:**  
1. Import `Bull` and the Redis client.  
2. Create a default queue (e.g., `emailQueue`) using the same Redis connection.  
3. Set default job options (attempts, backoff, removeOnComplete).  
4. Export queues: `emailQueue`, `backupQueue`, `analyticsQueue`.

### 1.4 `config/multer.js`  
**Algorithm:**  
1. Import `multer` and `path`.  
2. Define storage: diskStorage or memoryStorage.  
   - For disk: set destination = `uploads/`, filename = `Date.now() + originalname`.  
3. Define fileFilter: accept only images (jpg, jpeg, png), max size 2MB.  
4. Export multer instance with `{ storage, limits, fileFilter }`.

### 1.5 `config/logger.js` (Winston)  
**Algorithm:**  
1. Import `winston`.  
2. Define custom format: combine timestamp, json, colorize for console.  
3. Create logger with two transports:  
   - Console (level: debug in dev, info in prod)  
   - File (level: error, filename: `logs/error.log`)  
4. Export logger.

---

## 2. Models (Mongoose Schemas)

Each model file follows: define schema, add pre/post hooks, create indexes, export model.

### 2.1 `models/Organisation.model.js`  
**Schema fields:** name, type (school/college), domain, address, contactEmail, contactPhone, subscription (plan, validUntil, maxTeachers, maxStudents), status (active/suspended/trial), createdBy (ref User), timestamps.  
**Hooks:** pre‑save update `updatedAt`.  
**Indexes:** unique on `domain` (sparse), `status`.

### 2.2 `models/User.model.js`  
**Fields:** name, email (unique), password (hashed, select: false), role (super_admin/org_admin/teacher), organisation (ref Organisation), invitedBy (ref User), inviteToken, inviteExpires, isActive, lastLogin, permissions (array of strings), timestamps.  
**Pre‑save:** hash password if modified.  
**Methods:** `toJSON()` to remove password, inviteToken.  
**Indexes:** email unique, compound `{ organisation:1, role:1 }`.

### 2.3 `models/Student.model.js`  
**Fields:** rollNumber (unique within organisation), name, email, photo (string), course, semester, section (all refs), organisation (ref, required), enrollmentYear, contact, parentContact, address, isActive, timestamps.  
**Indexes:** compound unique `{ organisation:1, rollNumber:1 }`, `{ organisation:1, course:1 }`.

### 2.4 `models/Course.model.js`  
**Fields:** name, code (unique within organisation), organisation (ref, required), durationYears, subjects (array of refs), timestamps.  
**Indexes:** compound unique `{ organisation:1, code:1 }`.

### 2.5 `models/Subject.model.js`  
**Fields:** name, code (unique within organisation), credits, course (ref), semester (number), organisation (ref), timestamps.

### 2.6 `models/Semester.model.js`  
**Fields:** name, startDate, endDate, isActive, organisation (ref).

### 2.7 `models/Section.model.js`  
**Fields:** name, course (ref), semester (ref), classTeacher (ref User), organisation (ref).

### 2.8 `models/Session.model.js`  
**Fields:** subject, course, semester, section, teacher (ref User), date, startTime, endTime, topic, isHoliday, organisation (ref), createdAt.

### 2.9 `models/Attendance.model.js`  
**Fields:** session (ref), student (ref), status (present/absent/late/excused), markedBy (ref User), remarks, organisation (ref), timestamp.  
**Indexes:** compound `{ session:1, student:1 }` unique, `{ organisation:1, student:1 }`.

### 2.10 `models/RefreshToken.model.js`  
**Fields:** token (hashed string), user (ref), expiresAt.  
**TTL index:** `expiresAt` with `expireAfterSeconds: 0`.

### 2.11 `models/AuditLog.model.js`  
**Fields:** organisation (ref), user (ref), action (string), entityType, entityId, oldValues (object), newValues (object), ip, userAgent, timestamp (default now).

### 2.12 `models/BackupRecord.model.js`  
**Fields:** organisation (ref, nullable), backupType (full/incremental), status (pending/completed/failed), s3Key, sizeBytes, startedAt, completedAt, triggeredBy (ref User).

### 2.13 `models/AttendanceSummary.model.js` (CQRS read model)  
**Fields:** session (ref), student (ref), status, date, subject, course, semester, organisation, studentName, rollNumber (denormalised).  
**Indexes:** `{ organisation:1, student:1, semester:1 }`.

---

## 3. Services (Business Logic)

Each service exports functions that implement core algorithms.

### 3.1 `services/auth.service.js`  
**Algorithm – `login(email, password)`:**  
1. Find active user by email, include password field.  
2. If not found → throw “Invalid credentials”.  
3. Compare provided password with stored hash using bcrypt.  
4. If mismatch → throw error.  
5. Generate access token (JWT) with payload: `{ sub: user._id, role: user.role, org: user.organisation }`, expiry 15m.  
6. Generate refresh token (JWT) with same sub, expiry 7d.  
7. Hash the refresh token and store in `RefreshToken` model with user ID and expiry.  
8. Update user’s `lastLogin` to now.  
9. Return `{ accessToken, refreshToken, user }` (user without password).

**Algorithm – `refreshAccessToken(oldRefreshToken)`:**  
1. Decode oldRefreshToken without verification to get user ID (or verify with secret).  
2. Find `RefreshToken` record for that user where token matches (bcrypt compare).  
3. If not found or expired → throw error.  
4. Verify oldRefreshToken signature with JWT refresh secret.  
5. Find user by ID.  
6. Generate new access token and new refresh token.  
7. Hash new refresh token and replace in database (rotate).  
8. Return new tokens.

**Algorithm – `logout(refreshToken)`:**  
1. Decode refreshToken to get user ID.  
2. Delete all `RefreshToken` documents for that user (or the specific token).

### 3.2 `services/user.service.js`  
**Algorithm – `listTeachers(organisationId, page, limit, isSuperAdmin)`:**  
1. Build query: `{ role: 'teacher' }`.  
2. If not superAdmin, add `{ organisation: organisationId }`.  
3. Paginate: `skip((page-1)*limit).limit(limit).sort('name')`.  
4. Return `{ data, total, page, limit }`.

**Algorithm – `deactivateUser(userId, requesterOrgId, isSuperAdmin)`:**  
1. Find user by ID.  
2. If not superAdmin and user.organisation != requesterOrgId → throw error.  
3. Set `isActive = false`.  
4. Save user.  
5. Create audit log entry.  
6. Return updated user.

### 3.3 `services/organisation.service.js`  
**Algorithm – `createOrganisation(data, superAdminId)`:**  
1. Validate required fields (name, type).  
2. Check if organisation with same domain already exists.  
3. Create organisation document.  
4. Return created organisation.

**Algorithm – `listOrganisations(filters, page, limit)`:**  
1. Apply filters (status, type).  
2. Paginate.  
3. Return organisations.

**Algorithm – `suspendOrganisation(orgId)`:**  
1. Find organisation and set status = 'suspended'.  
2. Optionally deactivate all users in that organisation (batch update).  
3. Return updated organisation.

### 3.4 `services/invitation.service.js`  
**Algorithm – `createInvite(inviter, targetEmail, role, organisationId, name)`:**  
1. Check if user with targetEmail already exists and is active → throw error.  
2. Generate random invite token (32 bytes hex).  
3. Set expiry = now + 7 days.  
4. If user exists but inactive, update fields (inviteToken, inviteExpires, invitedBy, role, organisation). Otherwise create new user with `isActive: false`.  
5. Save user.  
6. Trigger email sending (asynchronous via Bull queue).  
7. Return user.

**Algorithm – `acceptInvite(token, password, name)`:**  
1. Find user with matching inviteToken, isActive false, inviteExpires > now.  
2. If not found → throw “Invalid or expired token”.  
3. Hash password and assign to user.  
4. Set `isActive = true`, clear inviteToken and inviteExpires.  
5. Save user.  
6. Generate access & refresh tokens.  
7. Return tokens and user.

### 3.5 `services/student.service.js`  
**Algorithm – `bulkImport(studentsArray, organisationId, requesterId)`:**  
1. Start MongoDB session for transaction.  
2. For each student in array:  
   - Validate required fields (rollNumber, name, course, semester, section).  
   - Check if rollNumber already exists in this organisation (query with organisation + rollNumber).  
   - If exists and overwrite flag true → update; else skip or collect error.  
   - Create/update student record with organisationId.  
3. Commit transaction.  
4. Publish event `students.imported` with summary.  
5. Return `{ total, succeeded, failed, errors }`.

**Algorithm – `listStudents(filters, organisationId, isSuperAdmin, page, limit)`:**  
1. Build query from filters (course, semester, section, search by name/roll).  
2. If not superAdmin, add `{ organisation: organisationId }`.  
3. Execute paginated query, populate course/semester/section.  
4. Cache result in Redis for 5 minutes (key includes filters and page).  
5. Return result.

### 3.6 `services/attendance.service.js` (detailed in previous answer but here algorithm only)  
**Algorithm – `markBulk(sessionId, attendanceArray, teacherId, organisationId, isSuperAdmin)`:**  
1. Fetch session, verify organisation matches.  
2. For each item in attendanceArray:  
   - Validate student exists in same organisation.  
   - Find or create attendance record.  
   - Store old status.  
   - Update status, markedBy, timestamp.  
   - Save.  
   - Publish event `attendance.marked` to event bus.  
3. Return summary.

**Algorithm – `getStudentSummary(studentId, organisationId, isSuperAdmin, semesterId)`:**  
1. Check cache for key `attendance:student:${studentId}:semester:${semesterId}`.  
2. If cache hit, return cached.  
3. Build aggregation pipeline to group by status.  
4. Compute percentages.  
5. Store in cache with TTL 1 hour.  
6. Return summary.

### 3.7 `services/analytics.service.js` (CQRS read side)  
**Algorithm – `getClassAttendance(courseId, semesterId, sectionId, organisationId, isSuperAdmin)`:**  
1. Query `AttendanceSummary` materialized view with filters.  
2. Group by student, compute present count and total sessions.  
3. Calculate percentage.  
4. Return overall percentage and per‑student list.

### 3.8 `services/backup.service.js`  
**Algorithm – `createFullBackup(triggeredBy, organisationId = null)`:**  
1. Generate timestamp and filename.  
2. If organisationId provided, construct `mongodump` query with `--query` filter for organisation.  
3. Execute `mongodump --archive=/tmp/backup.gz --gzip --db=smartcampus`.  
4. Upload to S3 bucket using AWS SDK.  
5. Create `BackupRecord` in database with status ‘completed’.  
6. Delete local file.  
7. If error, record failure and notify admins.

**Algorithm – `restoreBackup(backupId)`:**  
1. Find BackupRecord by ID, get s3Key.  
2. Download from S3 to temporary file.  
3. Run `mongorestore --gzip --archive=file.gz --drop`.  
4. Update backup record status.  
5. Optionally trigger re‑indexing.

### 3.9 `services/email.service.js`  
**Algorithm – `sendInviteEmail(to, token, inviterName)`:**  
1. Construct HTML email with accept‑invite link: `https://app.smartcampus.com/accept-invite?token=${token}`.  
2. Add email to Bull queue (emailQueue) to be processed asynchronously.  
3. Return job ID.

**Algorithm – `sendBulkEmail(recipients, subject, html)`:**  
1. For each recipient, create queue job.  
2. Use rate limiting to avoid SMTP throttling.

### 3.10 `services/eventBus.service.js` (already described as pub/sub)  
**Algorithm – `publish(channel, message)`:**  
1. Stringify message.  
2. Redis publish.

**Algorithm – `registerHandler(eventName, handler)`:**  
1. If no handler list for eventName, create and subscribe to Redis channel.  
2. Push handler to list.  
3. On message, call all handlers.

---

## 4. Controllers (Request Handlers)

Each controller calls services and sends standard response using `utils/apiResponse.js`.

### 4.1 `controllers/auth.controller.js`  
**Algorithm – `login`:**  
1. Extract email, password from body.  
2. Call `authService.login`.  
3. Set refresh token as HTTP‑only cookie (secure, sameSite strict).  
4. Return JSON with accessToken and user.

**Algorithm – `refresh`:**  
1. Get refresh token from cookie or body.  
2. Call `authService.refreshAccessToken`.  
3. Set new refresh token cookie.  
4. Return new access token.

**Algorithm – `logout`:**  
1. Get refresh token from cookie/body.  
2. Call `authService.logout`.  
3. Clear refresh token cookie.  
4. Return success.

### 4.2 `controllers/organisation.controller.js`  
**Algorithm – `create`:**  
1. Validate body (Zod).  
2. Call `organisationService.createOrganisation` with req.user.id (super admin).  
3. Return 201 with organisation.

**Algorithm – `list`:**  
1. Parse query parameters (page, limit, status).  
2. Call `organisationService.listOrganisations`.  
3. Return paginated result.

### 4.3 `controllers/user.controller.js`  
**Algorithm – `listTeachers`:**  
1. Extract page, limit from query.  
2. Call `userService.listTeachers(req.scope.organisationId, page, limit, req.user.role === 'super_admin')`.  
3. Return result.

**Algorithm – `deactivateUser`:**  
1. Get userId from params.  
2. Call `userService.deactivateUser(userId, req.scope.organisationId, req.user.role === 'super_admin')`.  
3. Return success message.

### 4.4 `controllers/student.controller.js`  
**Algorithm – `bulkImport`:**  
1. Get uploaded file from `req.file`.  
2. Parse CSV/JSON using `utils/csvParser`.  
3. Call `studentService.bulkImport(parsedData, req.scope.organisationId, req.user.id)`.  
4. Return import summary.

**Algorithm – `list`:**  
1. Extract filters from query (course, semester, section, search).  
2. Call `studentService.listStudents` with pagination.  
3. Return paginated list.

### 4.5 `controllers/attendance.controller.js`  
**Algorithm – `markBulk`:**  
1. Get sessionId, attendance array from body.  
2. Call `attendanceService.markBulk(sessionId, attendanceArray, req.user.id, req.scope.organisationId, req.user.role === 'super_admin')`.  
3. Return updated count.

**Algorithm – `getStudentSummary`:**  
1. Get studentId from params.  
2. Optionally get semesterId from query.  
3. Call `attendanceService.getStudentSummary`.  
4. Return summary.

### 4.6 `controllers/analytics.controller.js`  
**Algorithm – `classReport`:**  
1. Get courseId, semesterId, sectionId from query/params.  
2. Call `analyticsService.getClassAttendance`.  
3. Return report.

### 4.7 `controllers/backup.controller.js`  
**Algorithm – `create`:**  
1. Only super admin allowed.  
2. Call `backupService.createFullBackup(req.user.id, req.body.organisationId)`.  
3. Return backup record ID.

**Algorithm – `list`:**  
1. Call `BackupRecord.find()` paginated.  
2. Return list.

---

## 5. Routes

Each route file defines endpoints and attaches middleware.

### 5.1 `routes/v1/auth.routes.js`  
- `POST /login` → validation, rateLimit, `auth.login`  
- `POST /register` → superAdminOnly (seed only)  
- `POST /refresh` → `auth.refresh`  
- `POST /logout` → authMiddleware, `auth.logout`

### 5.2 `routes/v1/orgs.routes.js`  
- `POST /` → superAdminOnly, validation, `organisation.create`  
- `GET /` → superAdminOnly, `organisation.list`  
- `GET /:orgId` → superAdminOnly, `organisation.get`  
- `PATCH /:orgId` → superAdminOnly, `organisation.update`

### 5.3 `routes/v1/users.routes.js`  
- `POST /invite` → authMiddleware, roleOrgAdmin, validation, `invitation.sendInvite`  
- `POST /accept-invite` → public, validation, `auth.acceptInvite`  
- `GET /teachers` → authMiddleware, roleOrgAdmin, `user.listTeachers`  
- `DELETE /:userId` → authMiddleware, roleOrgAdmin, `user.deactivate`

### 5.4 `routes/v1/students.routes.js`  
- `GET /` → authMiddleware, `student.list`  
- `POST /` → authMiddleware, roleOrgAdmin, `student.create`  
- `POST /import` → authMiddleware, roleOrgAdmin, upload.single('file'), `student.bulkImport`  
- `GET /:id` → authMiddleware, `student.getById`  
- `PUT /:id` → authMiddleware, roleOrgAdmin, `student.update`  
- `DELETE /:id` → authMiddleware, roleOrgAdmin, `student.delete`

### 5.5 `routes/v1/attendance.routes.js`  
- `POST /sessions` → authMiddleware, teacherOnly, `attendance.createSession`  
- `GET /sessions` → authMiddleware, `attendance.listSessions`  
- `POST /mark` → authMiddleware, teacherOnly, `attendance.markBulk`  
- `GET /session/:sessionId` → authMiddleware, `attendance.getBySession`  
- `GET /student/:studentId` → authMiddleware, `attendance.studentSummary`

### 5.6 `routes/v1/analytics.routes.js`  
- `GET /class/:courseId` → authMiddleware, `analytics.classReport`  
- `GET /student/:studentId` → authMiddleware, `analytics.studentTrend`

### 5.7 `routes/v1/backup.routes.js`  
- `POST /create` → superAdminOnly, `backup.create`  
- `GET /list` → superAdminOnly, `backup.list`  
- `POST /restore/:backupId` → superAdminOnly, `backup.restore`

---

## 6. Middleware

### 6.1 `middleware/auth.middleware.js`  
**Algorithm:**  
1. Extract `Authorization` header, split to get token after "Bearer".  
2. If no token → 401.  
3. Verify token with JWT_ACCESS_SECRET.  
4. Attach `req.user = { id: decoded.sub, role: decoded.role, organisation: decoded.org }`.  
5. Call next.

### 6.2 `middleware/rbac.middleware.js`  
**Algorithm – `requireRole(...allowedRoles)`:**  
1. Return a function that checks `req.user.role` is in allowedRoles.  
2. If not → 403 Forbidden.

### 6.3 `middleware/orgScope.middleware.js`  
**Algorithm:**  
1. If `req.user.role === 'super_admin'`, set `req.scope = { isSuperAdmin: true }`.  
2. Else if `req.user.organisation` exists, set `req.scope = { organisationId: req.user.organisation, isSuperAdmin: false }`.  
3. Else → 403.

### 6.4 `middleware/validation.middleware.js` (using Zod)  
**Algorithm:**  
1. Accept a Zod schema.  
2. Return a function that validates `req.body`, `req.params`, `req.query` against schema.  
3. If validation fails, return 400 with formatted errors.  
4. Else call next.

### 6.5 `middleware/rateLimiter.js`  
**Algorithm:**  
1. Use `express-rate-limit` with Redis store.  
2. Define different limiters: `strictLimiter` (5 per 15 min for login), `standardLimiter` (100 per 15 min for general).  
3. Export limiters.

### 6.6 `middleware/circuitBreaker.js` (for external calls)  
**Algorithm:**  
1. Create a circuit breaker using `opossum` for a specific function (e.g., S3 upload, email send).  
2. Provide fallback function.  
3. Export breaker instance.

### 6.7 `middleware/errorHandler.js`  
**Algorithm:**  
1. Catch any error passed to `next(err)`.  
2. Log error using Winston.  
3. Send to Sentry.  
4. Respond with `{ success: false, message: err.message, code: err.status || 500 }`.

### 6.8 `middleware/requestId.js`  
**Algorithm:**  
1. Generate UUID (or use `req.headers['x-request-id']`).  
2. Attach to `req.id`.  
3. Add to response header `X-Request-Id`.

---

## 7. Validators (Zod Schemas)

Each validator exports a schema for a specific entity.

### 7.1 `validators/auth.validator.js`  
- `loginSchema`: email (email), password (string min 6).  
- `inviteSchema`: email, role (enum), name (optional).

### 7.2 `validators/student.validator.js`  
- `createStudentSchema`: rollNumber (string), name (string), courseId (ObjectId), semesterId, sectionId, email (optional email).

### 7.3 `validators/attendance.validator.js`  
- `markAttendanceSchema`: sessionId (ObjectId), attendance (array of objects with studentId, status enum, remarks optional).

### 7.4 `validators/org.validator.js`  
- `createOrgSchema`: name (string), type (enum), domain (optional), contactEmail (email).

---

## 8. Utils (Helpers)

### 8.1 `utils/apiResponse.js`  
**Algorithm:**  
- `sendSuccess(res, data, status=200)`: res.status(status).json({ success: true, data })  
- `sendError(res, message, status=500)`: res.status(status).json({ success: false, message })

### 8.2 `utils/generateToken.js`  
**Algorithm – `generateAccessToken(user)`:**  
1. Payload: `{ sub: user._id, role: user.role, org: user.organisation }`.  
2. Sign with JWT_ACCESS_SECRET, expiresIn ACCESS_TOKEN_EXPIRY.  
3. Return token.

**Algorithm – `generateRefreshToken(user)`:**  
1. Payload: `{ sub: user._id }`.  
2. Sign with JWT_REFRESH_SECRET, expiresIn REFRESH_TOKEN_EXPIRY.  
3. Return token.

### 8.3 `utils/hashPassword.js`  
**Algorithm – `hashPassword(plain)`:**  
1. Use `bcrypt.hash(plain, 10)`.  
2. Return hash.

**Algorithm – `comparePassword(plain, hash)`:**  
1. Return `bcrypt.compare(plain, hash)`.

### 8.4 `utils/dateHelper.js`  
- `formatDate(date)`: return YYYY-MM-DD.  
- `getCurrentSemester(date)`: logic to find active semester based on dates.

### 8.5 `utils/csvParser.js`  
**Algorithm – `parseCSV(buffer)`:**  
1. Use `csv-parser` library.  
2. Convert buffer to stream.  
3. Return array of objects.

### 8.6 `utils/s3Client.js`  
**Algorithm:**  
1. Import AWS SDK v3.  
2. Configure with region, access key, secret.  
3. Export `s3Client`, `uploadFile`, `downloadFile` functions.

### 8.7 `utils/sentry.js`  
**Algorithm:**  
1. Import `@sentry/node`.  
2. Initialize with DSN and environment.  
3. Export `Sentry`.

---

## 9. Jobs (Background Tasks)

### 9.1 `jobs/dailyBackup.job.js`  
**Algorithm:**  
1. Use Bull queue `backupQueue` with repeatable cron `0 2 * * *`.  
2. Process function:  
   - Acquire distributed lock (Redis SETNX) to ensure only one instance runs.  
   - Call `backupService.createFullBackup()`.  
   - Release lock.

### 9.2 `jobs/sendReminders.job.js`  
**Algorithm:**  
1. Repeatable cron `0 8 * * 1` (every Monday 8 AM).  
2. For each organisation, find students with attendance \< 75% last week.  
3. Send email to parents/teachers.

### 9.3 `jobs/materializedViewRefresh.job.js` (already described in CQRS)  
**Algorithm:**  
1. Listen to `attendance.marked` event.  
2. Update `AttendanceSummary` collection.

### 9.4 `jobs/leaderElection.js`  
**Algorithm:**  
1. On worker start, attempt to set a key `leader:backup` with TTL 60s using Redis `SETNX`.  
2. If successful, this instance is leader and schedules jobs.  
3. Periodically (every 30s) refresh the lock.  
4. If lock lost, stop scheduling.

---

## 10. Events (Pub/Sub)

### 10.1 `events/publishers/attendanceMarked.publisher.js`  
**Algorithm:**  
1. Accept event data (sessionId, studentId, newStatus, oldStatus).  
2. Call `eventBus.publish('attendance.marked', data)`.

### 10.2 `events/publishers/studentEnrolled.publisher.js`  
**Algorithm:**  
1. Accept student data.  
2. Publish to `student.enrolled`.

### 10.3 `events/subscribers/updateAnalytics.subscriber.js`  
**Algorithm:**  
1. Register handler for `attendance.marked`.  
2. On event, update the materialized view (upsert into AttendanceSummary).

### 10.4 `events/subscribers/sendNotification.subscriber.js`  
**Algorithm:**  
1. Register handler for `attendance.marked`.  
2. If status changed from absent to present, optionally send push notification (if integrated).

---

## 11. CQRS Components

### 11.1 `cqrs/commands/markAttendance.command.js`  
**Algorithm:**  
1. Command object: `{ sessionId, studentId, status, teacherId }`.  
2. Handler: calls `attendanceService.markBulk` for a single student.  
3. Returns command result.

### 11.2 `cqrs/queries/getAttendanceReport.query.js`  
**Algorithm:**  
1. Query object: `{ courseId, semesterId, sectionId, startDate, endDate }`.  
2. Handler: reads from `AttendanceSummary` view.  
3. Returns denormalised report.

### 11.3 `cqrs/materializedViews/attendanceSummary.view.js`  
**Algorithm (refresh):**  
1. On `attendance.marked` event, compute latest attendance record.  
2. Upsert into `AttendanceSummary` with denormalised student name, roll number.

---

## 12. Entry Points (app.js, server.js)

### 12.1 `app.js`  
**Algorithm:**  
1. Import express, helmet, cors, morgan, cookieParser.  
2. Create express app.  
3. Apply global middleware: helmet, cors (with allowed origins), express.json, cookieParser, morgan, requestId.  
4. Import routes and mount under `/api/v1`.  
5. Apply 404 handler for unmatched routes.  
6. Apply global error handler (Sentry + custom).  
7. Export app.

### 12.2 `server.js`  
**Algorithm:**  
1. Import `app` and `connectDB`, `logger`.  
2. Connect to MongoDB.  
3. Connect to Redis.  
4. Start Bull queues.  
5. Start event bus subscribers.  
6. Start cron jobs (or rely on Bull repeatable).  
7. Listen on PORT.  
8. Handle graceful shutdown: close DB, Redis, Bull, then exit.

---

## 13. Test Scripts

### 13.1 `tests/unit/auth.service.test.js`  
**Algorithm:**  
1. Mock User model and RefreshToken model.  
2. Test `login` with correct credentials → returns tokens.  
3. Test `login` with wrong password → throws error.

### 13.2 `tests/integration/attendance.api.test.js`  
**Algorithm:**  
1. Use supertest to call login, get token.  
2. Create session via API.  
3. Mark attendance via API.  
4. Verify attendance is saved.

### 13.3 `tests/e2e/teacher-flow.test.js`  
**Algorithm:**  
1. Spin up test environment (Docker compose).  
2. Seed organisation, admin, teacher, students.  
3. Simulate teacher login → create session → mark attendance → view analytics.  
4. Assert expected data.

---

## 14. Scripts (Seed, Backup, Migrate)

### 14.1 `scripts/seed.js`  
**Algorithm:**  
1. Connect to database.  
2. Check if super admin exists; if not, create from env SUPER_ADMIN_EMAIL/PASSWORD.  
3. Optionally create a demo organisation and demo teachers/students.  
4. Disconnect.

### 14.2 `scripts/backupDB.js`  
**Algorithm:**  
1. Parse command line arguments (organisation, full/incremental).  
2. Call `backupService.createFullBackup` or incremental.  
3. Output result.

### 14.3 `scripts/migrate.js`  
**Algorithm:**  
1. Read migration files from `migrations/` folder.  
2. Apply each migration in order using a `migrations` collection to track applied versions.  
3. Run up/down based on command.

---

This document contains **every algorithm** needed to implement the SmartCampus backend.

**End of Document**  
