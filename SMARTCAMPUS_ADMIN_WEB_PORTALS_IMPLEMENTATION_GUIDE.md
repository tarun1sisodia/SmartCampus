# SmartCampus Admin Web Portals - Algorithmic Implementation Guide

This document provides step-by-step algorithms (no code) for building the two admin web dashboards:

- SuperAdmin Dashboard - platform management
- Organization Dashboard - school/college management

Both follow professional design principles with distinct but cohesive color schemes.

---

## 1. Professional Color Schemes

### 1.1 SuperAdmin Dashboard (Platform Owners)

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Primary | Deep Indigo | `#4F46E5` | Buttons, active states, primary actions |
| Secondary | Slate | `#64748B` | Secondary buttons, icons |
| Success | Emerald | `#10B981` | Positive indicators, completed backups |
| Warning | Amber | `#F59E0B` | Warnings, expiring subscriptions |
| Danger | Rose | `#E11D48` | Destructive actions, suspensions |
| Background | Neutral | `#F8FAFC` | Main background |
| Surface | White | `#FFFFFF` | Cards, modals |
| Text Primary | Gray-900 | `#111827` | Headings, body text |
| Text Secondary | Gray-500 | `#6B7280` | Labels, helper text |

Theme concept: Authoritative, trustworthy, calm - suitable for platform governance.

### 1.2 Organization Dashboard (School/College Admins)

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Primary | Vibrant Blue | `#2563EB` | Buttons, active states, primary actions |
| Secondary | Teal | `#0D9488` | Secondary buttons, accents |
| Success | Green | `#22C55E` | Attendance above 75%, successful imports |
| Warning | Orange | `#F97316` | Attendance 50-75%, warnings |
| Danger | Red | `#EF4444` | Delete, deactivate, low attendance |
| Background | Cool Gray | `#F1F5F9` | Main background |
| Surface | White | `#FFFFFF` | Cards, modals |
| Text Primary | Slate-800 | `#1E293B` | Headings, body text |
| Text Secondary | Slate-500 | `#64748B` | Labels, helper text |

Theme concept: Energetic, approachable, educational - suitable for daily school operations.

Both dashboards support light/dark mode toggles with consistent mapping.

---

## 2. Project Folder Structure (Algorithms Only)

```text
smartcampus-web/
├── apps/
│   ├── super-admin/
│   │   ├── app/
│   │   │   ├── (auth)/login/page.tsx
│   │   │   ├── (auth)/forgot-password/page.tsx
│   │   │   ├── (dashboard)/dashboard/page.tsx
│   │   │   ├── (dashboard)/organisations/page.tsx
│   │   │   ├── (dashboard)/organisations/create/page.tsx
│   │   │   ├── (dashboard)/organisations/[id]/page.tsx
│   │   │   ├── (dashboard)/users/page.tsx
│   │   │   ├── (dashboard)/backups/page.tsx
│   │   │   ├── (dashboard)/audit-logs/page.tsx
│   │   │   ├── (dashboard)/settings/page.tsx
│   │   │   ├── layout.tsx
│   │   │   ├── middleware.ts
│   │   │   └── globals.css
│   │   ├── components/ui/
│   │   ├── components/layout/Sidebar.tsx
│   │   ├── components/layout/Header.tsx
│   │   ├── lib/api/axios-client.ts
│   │   ├── lib/api/endpoints/
│   │   ├── lib/hooks/useAuth.ts
│   │   ├── lib/hooks/useDebounce.ts
│   │   ├── lib/store/slices/authSlice.ts
│   │   ├── lib/utils/formatters.ts
│   │   ├── lib/validations/organisation.schema.ts
│   │   └── types/
│   └── org-admin/
│       ├── app/(dashboard)/
│       │   ├── dashboard/page.tsx
│       │   ├── teachers/page.tsx
│       │   ├── students/page.tsx
│       │   ├── students/import/page.tsx
│       │   ├── courses/page.tsx
│       │   ├── sessions/page.tsx
│       │   ├── analytics/page.tsx
│       │   └── settings/page.tsx
│       └── (same lib/components as super-admin)
└── packages/ (optional shared)
```

---

## 3. Core Algorithms (File by File)

### 3.1 Authentication and Session Handling

#### `app/middleware.ts`
1. Extract access token from cookies (httpOnly) or request headers.
2. If token is missing and requested path is not `/login` or `/forgot-password`, redirect to `/login`.
3. If token exists, optionally decode it and delegate full verification to API.
4. For `/api/*` routes, add token to `Authorization` header.
5. Allow public routes.

#### `lib/api/axios-client.ts`
1. Create axios instance with `baseURL` from environment.
2. Request interceptor:
   - Read access token from Redux or cookie.
   - Add `Authorization: Bearer <token>` when available.
3. Response interceptor:
   - On 401, check retry flag.
   - If not retried, call refresh endpoint with refresh token.
   - On success, update tokens and retry request.
   - On failure, clear auth state, delete cookies, redirect to `/login`.

#### `lib/store/slices/authSlice.ts`
- State: `user`, `accessToken`, `refreshToken`, `isAuthenticated`.
- Reducers:
  - `setCredentials`: stores tokens and user.
  - `clearCredentials`: logs out.
- Async thunk `login`: POST `/auth/login`, then dispatch `setCredentials`.
- Async thunk `logout`: POST `/auth/logout` (ignore errors), dispatch `clearCredentials`.

#### `lib/hooks/useAuth.ts`
- Read `isAuthenticated` and `user` from Redux selectors.
- Return `{ user, isAuthenticated, logout }`.

### 3.2 SuperAdmin Dashboard - Key Features

#### `app/(dashboard)/dashboard/page.tsx`
1. Fetch platform stats via React Query (`GET /analytics/platform`).
2. Show KPI cards:
   - total organisations
   - total users
   - total students
   - average attendance
3. Render 6-month attendance line chart.
4. Show latest 5 organisations table.
5. Include refresh button to invalidate query.

#### `app/(dashboard)/organisations/page.tsx`
1. Fetch organisations (`GET /orgs`).
2. Render table with name, type, status, subscription, actions.
3. Add debounced search and type filter.
4. Add server-side pagination.
5. Add "Create Organisation" navigation button.
6. Add row "Edit" navigation.
7. Add "Suspend/Activate" action via `PATCH /orgs/:id`.

#### `app/(dashboard)/organisations/create/page.tsx`
1. Use React Hook Form with Zod validation.
2. Fields: name, type, domain, contact email, address.
3. Include subscription selector with pricing display.
4. On submit call `POST /orgs`; redirect on success.
5. Show error toast on failure.

#### `app/(dashboard)/organisations/[id]/page.tsx`
1. Fetch org details (`GET /orgs/:id`).
2. Pre-fill editable form.
3. Update name, contact email, address, plan, status.
4. Fetch org admins list (`/users?organisationId=:id&role=org_admin`).
5. Add admin deactivate/reset-password actions.
6. Submit updates via `PATCH /orgs/:id`; show toast and refetch.

#### `app/(dashboard)/users/page.tsx`
1. Fetch users (`GET /users`).
2. Table columns: name, email, role, organisation, status, last login.
3. Add role filter.
4. Actions:
   - reset password
   - deactivate (`DELETE /users/:id`)
   - promote org admin to super admin
5. Confirm destructive actions with modal.

#### `app/(dashboard)/backups/page.tsx`
1. Fetch backups (`GET /backup/list`).
2. Table columns: date, type, size, status, actions.
3. "Create Backup" -> `POST /backup/create`.
4. "Restore" -> confirmation -> `POST /backup/restore/:id`.
5. Auto-refresh every 30 seconds.

#### `app/(dashboard)/audit-logs/page.tsx`
1. Fetch logs (`GET /audit-logs`) with filters and pagination.
2. Filters: organisation, user, action, date range.
3. Use server-side pagination or infinite scroll.
4. Table columns: timestamp, user, action, entity type, expandable details.
5. Export CSV via `GET /audit-logs/export`.

#### `app/(dashboard)/settings/page.tsx`
1. Render system settings form.
2. Fields:
   - face recognition enabled
   - CQRS materialized views enabled
   - max students per org
   - max teachers per org
3. Submit to `PATCH /settings`.
4. Show success/error toast.

### 3.3 Organization Dashboard - Key Features

#### `app/(dashboard)/dashboard/page.tsx`
1. Fetch org stats (`GET /analytics/organisation`).
2. KPI cards: students, teachers, today's attendance, monthly sessions.
3. Bar chart for attendance by subject (30 days).
4. Show latest 5 sessions with links.

#### `app/(dashboard)/teachers/page.tsx`
1. Fetch teachers (`GET /users/teachers`).
2. Table columns: name, email, status, last login, actions.
3. "Invite Teacher" modal -> `POST /users/invite`.
4. Actions: deactivate and resend invite.
5. Show pending invites (`isActive = false`).

#### `app/(dashboard)/students/page.tsx`
1. Fetch students (`GET /students`) with filters.
2. Table columns: photo, roll number, name, course, section, actions.
3. "Import Students" opens upload modal.
4. "Add Student" navigates to create form.
5. Actions: edit, delete with confirm modal.
6. "View Attendance" opens analytics modal.

#### `app/(dashboard)/students/import/page.tsx`
1. Drag-drop CSV/XLSX file input.
2. Parse file and preview first 5 rows.
3. Map CSV columns to required fields.
4. Submit to `POST /students/import`.
5. Show progress and final success/failure report.

#### `app/(dashboard)/courses/page.tsx`
1. Fetch courses (`GET /courses`).
2. Table columns: name, code, duration, subject count, actions.
3. "Create Course" modal for basic fields.
4. Expandable row to manage subjects.
5. Edit/delete via PATCH and DELETE endpoints.

#### `app/(dashboard)/sessions/page.tsx`
1. Render FullCalendar month view.
2. Fetch sessions (`GET /sessions?month=YYYY-MM`).
3. Click session -> modal with attendance details.
4. Filters by teacher, subject, date range.
5. Export to CSV.

#### `app/(dashboard)/analytics/page.tsx`
1. Fetch class attendance (`GET /analytics/class/:courseId`).
2. Render comparative course attendance chart.
3. Filters: semester and section.
4. Searchable/sortable student attendance table.
5. Export report via `POST /export/attendance/csv`.

---

## 4. Shared Components - Algorithms

### `components/ui/DataTable.tsx`
1. Accept `columns` and `data`.
2. Use TanStack `useReactTable` for sorting/filtering/pagination.
3. Render semantic table.
4. Add debounced global search.
5. Add sortable headers with indicators.
6. Add pagination controls and page-size selector.
7. Enable virtual scrolling when rows exceed 1000.

### `components/ui/Modal.tsx`
1. Accept `isOpen`, `onClose`, `title`, `children`.
2. Render using React Portal.
3. Close on Escape or overlay click.
4. Trap focus for accessibility.
5. Animate open/close transitions.

### `components/ui/Toast.tsx`
1. Manage toast queue via context provider.
2. `showToast(message, type)` enqueues toast.
3. Auto-dismiss after 5 seconds.
4. Render bottom-right fixed container.
5. Support success/error/warning/info variants.

---

## 5. API Integration Algorithms

Each endpoint module exports typed async functions using shared `axiosInstance`:

- `auth-api.ts`: login, logout, refreshToken, forgotPassword, resetPassword
- `org-api.ts`: getOrganisations, createOrganisation, updateOrganisation, deleteOrganisation
- `user-api.ts`: getUsers, inviteUser, deactivateUser, resendInvite
- `backup-api.ts`: getBackups, createBackup, restoreBackup
- `student-api.ts`: getStudents, createStudent, updateStudent, deleteStudent, importStudents
- `analytics-api.ts`: getPlatformStats, getOrganisationStats, getClassAttendance

---

## 6. Testing Algorithms (Smoke Tests)

### SuperAdmin
1. Login and verify redirect to dashboard.
2. Create organisation and verify list update.
3. Edit organisation and verify persisted change.
4. Suspend organisation and verify status.
5. Invite org admin and verify user appears.
6. Create backup and verify listing.
7. Restore backup and verify success feedback.

### Organization
1. Login and verify dashboard redirect.
2. Invite teacher and verify list entry.
3. Create course/subject/semester/section.
4. Add single student and verify list entry.
5. Import students and verify counts.
6. Create session and verify calendar entry.
7. Confirm attendance impacts analytics.

---

## 7. Deployment Algorithms

### Vercel
1. Set env vars:
   - `NEXT_PUBLIC_API_URL`
   - `NEXT_PUBLIC_SENTRY_DSN` (optional)
2. Run `vercel --prod` in each app directory.
3. Map domains:
   - `admin.smartcampus.com` -> super-admin
   - `org.smartcampus.com` -> org-admin

### AWS S3 + CloudFront (alternative)
1. Build each app.
2. Upload static output to S3.
3. Configure CloudFront with domain and SSL.
4. Invalidate cache after deployment.

---

## 8. Coverage Status

| Component | Status |
|-----------|--------|
| SuperAdmin dashboard - organisations CRUD | Complete (algorithm defined) |
| SuperAdmin - user management | Complete |
| SuperAdmin - backups and restore | Complete |
| SuperAdmin - audit logs | Complete |
| SuperAdmin - settings | Complete |
| Organization - teacher management | Complete |
| Organization - student management | Complete |
| Organization - course and subject management | Complete |
| Organization - sessions calendar | Complete |
| Organization - analytics and reports | Complete |
| Shared UI (DataTable, Modal, Toast) | Complete |
| Authentication and session handling | Complete |
| Professional color schemes | Complete |
| Dark/light mode support | Complete (implementation pending) |

All required features are covered algorithmically in this guide.
