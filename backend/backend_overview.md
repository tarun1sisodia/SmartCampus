# SmartCampus Backend Architecture Overview

This document provides a comprehensive overview of the backend components (Models, Controllers, and Services) implemented in the SmartCampus project. The backend follows a modern layered Model-View-Controller (MVC) and Service-Oriented Architecture, utilizing Node.js, Express, and Mongoose for MongoDB.

## 🗄️ Models (`src/models`)
Models act as the data layer, defining schemas, types, validation, and relationships using Mongoose.

*   `User.model.js`: Mongoose schema for the system's users (super admins, org admins, teachers), handling authentication and hashing.
*   `Student.model.js`: Schema for representing students, their affiliations to organizations and enrollment details.
*   `Organisation.model.js`: Schema for educational organizations / campuses.
*   `Course.model.js`: Schema for representing educational courses inside an organization.
*   `Semester.model.js`: Schema mapping semesters to courses.
*   `Section.model.js`: Schema indicating specific sections/classes within semesters.
*   `Subject.model.js`: Schema indicating subjects taught in a given course/semester.
*   `Session.model.js`: Schema representing distinct academic sessions/years.
*   `Attendance.model.js`: Core schema recording individual student attendance.
*   `AttendanceSummary.model.js`: Pre-aggregated collections to optimize fetching attendance analytics and summaries.
*   `AuditLog.model.js`: System logs schema for tracking security, operations, and data modifications.
*   `BackupRecord.model.js`: Schema tracking status and details of database backups.
*   `RefreshToken.model.js`: Dedicated schema for securely storing JWT refresh tokens independently.

## ⚙️ Services (`src/services`)
The service layer serves as the core business logic handler. It isolates database queries and logic away from route handlers.

*   `auth.service.js`: Manages login operations, token generation (access + refresh validation), token rotation, and credential comparison.
*   `user.service.js`: Manages user lifecycles, profile updates, and role-based assignments.
*   `student.service.js`: Handles logic for student enrollment, retrieval, and mapping to organizations.
*   `organisation.service.js`: Coordinates the creation, activation, and management of educational organizations.
*   `attendance.service.js`: Complex logic covering attendance marking, leave applications, and daily presence calculations.
*   `analytics.service.js`: Fetches and aggregates insights, metrics, and trends for dashboards.
*   `backup.service.js`: Coordinates database dump executions, compressions, and storage retrieval.
*   `email.service.js`: Integrates tightly for dispatching transactional emails (welcome emails, alerts).
*   `invitation.service.js`: Handles secure invitation flow logic, token creation, and expiration for inviting new staff/teachers.
*   `eventBus.service.js`: Pub-Sub wrapper representing asynchronous event dispatches to keep modules decoupled (e.g., Audit Logging).

## 🎛️ Controllers (`src/controllers`)
Controllers sit between external routes and internal services. They extract request parameters, validate payloads (if not done in middleware), invoke the appropriate service, and format HTTP responses.

*   `auth.controller.js`: Exposes login, logout, and token refresh endpoints. Directly proxies input headers and cookies to `auth.service`.
*   `user.controller.js`: Route endpoints for managing individual users.
*   `student.controller.js`: Route endpoints representing CRUD operations for students.
*   `organisation.controller.js`: Routes mapped to organizational updates.
*   `attendance.controller.js`: Endpoints exposed to teachers and administrators for logging and retrieving attendance sheets.
*   `analytics.controller.js`: Routes for delivering chart data and application metrics back to the frontend dashboard.
*   `backup.controller.js`: Admin-only endpoints responsible for triggering on-demand backups or obtaining latest backup states.
*   `importExport.controller.js`: Handles bulk data ingestion and CSV/Excel parsing functionality without tightly coupling to lower data models.

---
*Generated based on an inspection of the `backend/src/` directory.*
