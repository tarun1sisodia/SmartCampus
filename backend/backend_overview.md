# SmartCampus Backend: File-by-File Technical Overview

This document provides a granular breakdown of the backend files, the algorithms used within them, and the step-by-step logic they follow.

---

## 1. Core Entry Points

### `server.js`
*   **Purpose**: The main orchestration file that boots the system.
*   **Logic Steps**:
    1.  Loads environment variables (`env.js`).
    2.  Connects to MongoDB (`database.js`).
    3.  Starts the Express HTTP server.
    4.  Initializes **Socket.io** for real-time features.
    5.  Once the port is open, it boots background jobs and event subscribers (non-blocking).

### `src/app.js`
*   **Purpose**: Configures the Express application pipeline (middleware and routes).
*   **Key Logic**:
    1.  Attaches security headers (Helmet) and CORS.
    2.  Sets up request logging (Morgan) and parsing (JSON/Cookies).
    3.  Mounts all API routes under `/api/v1`.
    4.  Registers the global `errorHandler` to catch all process exceptions.
    5.  Mounts Swagger UI at `/api-docs`.

---

## 2. Configuration Layer (`src/config/`)

### `redis.js` (Algorithm: Intelligent Failover)
*   **Algo**: Dynamic Fallback Strategy.
*   **Steps**:
    1.  Attempts connection to the primary `REDIS_URL`.
    2.  On failure, it triggers a `retryStrategy`.
    3.  If it fails 3 times, it updates its internal config settings to use `REDIS_URL2`.
    4.  Instantly switches the host/port without crashing the app.

### `bull.js` (Purpose: Background Task Management)
*   **Algo**: Producer-Consumer Queue.
*   **Steps**:
    1.  Checks if the Redis URL requires TLS (`rediss://`).
    2.  Instantiates multiple queues (Email, Backup, Analytics).
    3.  Configures "Stalled Job" detection (ensures jobs don't hang if a worker dies).

---

## 3. Services & Algorithms (`src/services/`)

### `auth.service.js` (Algorithm: JWT Rotation)
*   **Algo**: Dual-Token Security.
*   **Steps**:
    1.  **Encrypt**: Hashes passwords using `bcrypt` with a salt factor of 10.
    2.  **Verify**: Compares incoming password with the hashed version.
    3.  **Issue**: Generates a 15-minute Access Token and a 7-day Refresh Token.
    4.  **Rotate**: When the Access token expires, the client sends the Refresh token to get a new pair, keeping the user logged in securely.

### `attendance.service.js` (Algorithm: CQRS Upsert)
*   **Algo**: Event-Driven State Update.
*   **Steps**:
    1.  Validates that the teacher is authorized for that specific session.
    2.  Atomically updates/marks the student's status in the `Attendance` collection.
    3.  **Algorithm Part**: Publishes an internal event `attendance.marked`.
    4.  Triggers subscribers to update analytics and send parent notifications asynchronously.

### `backup.service.js` (Algorithm: Lock-Protected Shell Exec)
*   **Algo**: Distributed Locking via Redis.
*   **Steps**:
    1.  Acquires a "mutex" lock in Redis to prevent multiple backups.
    2.  Spaws a `mongodump` child process via Linux shell.
    3.  Streams the resulting `.gz` file directly to Cloudinary/S3.
    4.  Deletes the temp file and releases the lock.

### `cloudinary.service.js` (Algorithm: Buffer Streaming)
*   **Algo**: Pass-through Memory Upload.
*   **Steps**:
    1.  Receives file buffer from Multer (RAM).
    2.  Opens a write-stream to Cloudinary.
    3.  Pipes the buffer directly into the stream (prevents writing to slow server disks).
    4.  Returns the secure HTTPS URL.

---

## 4. Middleware: The Gatekeepers (`src/middleware/`)

### `auth.middleware.js`
*   **Steps**:
    1.  Extracts token from `Authorization` header.
    2.  Verifies the JWT signature with the secret key.
    3.  Injects the `user` object into the request for subsequent functions to use.

### `rbac.middleware.js` (Role Based Access Control)
*   **Steps**:
    1.  Checks if the current user's role (SuperAdmin, Teacher, OrgAdmin) matches the required permission for that specific route.
    2.  Blocks the request with a 403 status if unauthorized.

---

## 5. Event Subscribers (`src/events/subscribers/`)

### `updateAnalytics.subscriber.js`
*   **Steps**:
    1.  Listens for `attendance.marked`.
    2.  **Algorithm**: Performs an Upsert into the `AttendanceSummary` collection.
    3.  Recalculates student attendance percentages in the background so the dashboard is always "pre-calculated".

---

## 6. Real-time Layer (`src/socket/index.js`)
*   **Algorithm**: Group-based Emitting.
*   **Steps**:
    1.  User connects and provides a JWT.
    2.  Server puts the user into a specific "Room" (e.g., `user:123` or `org:abc`).
    3.  When a notification is sent, the server emits only to that specific room, keeping data private and traffic low.

---

## 7. Data Models (`src/models/`)

*   **Organisations**: Base unit. All data is "Multi-tenant," meaning a Teacher from School A can never see Student data from School B.
*   **Sessions**: Connects a Teacher, a Subject, and a Section at a specific time.
*   **Attendance**: The core transaction record connecting Students to a Session with a status.

---

## Next Steps for Testing:
1.  **Unit Tests**: Run `npm run test:unit` to verify the logic in the services (Auth/Backup).
2.  **Smoke Tests**: Run `node scripts/smokeTest.js` to ensure the DB and Redis are actually talking to the code.
3.  **Supertest**: We should next build integration te  sts that mock a whole user flow (Login -> Mark Attendance -> Check Analytics).
