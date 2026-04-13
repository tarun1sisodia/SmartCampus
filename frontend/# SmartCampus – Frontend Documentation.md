\# SmartCampus – Frontend Documentation

This document defines the \*\*complete frontend architecture\*\* for the SmartCampus ecosystem.    
We have \*\*three separate frontend applications\*\*:

| Application | Platform | Framework | Users |  
|-------------|----------|-----------|-------|  
| \*\*SuperAdmin Dashboard\*\* | Web | React / Next.js | Super Administrators (platform owners) |  
| \*\*Organization Dashboard\*\* | Web | React / Next.js | Org Admins (school/college administrators) |  
| \*\*Teacher App\*\* | Mobile | Flutter or React Native | Teachers (mark attendance, view analytics) |

All three consume the same \*\*backend API\*\* (documented separately) but have different feature sets, UI/UX, and permissions.

\---

\#\# Table of Contents

1\. \[Common Requirements (All Frontends)\](\#1-common-requirements-all-frontends)  
2\. \[SuperAdmin Dashboard (Web)\](\#2-superadmin-dashboard-web)  
3\. \[Organization Dashboard (Web)\](\#3-organization-dashboard-web)  
4\. \[Teacher Mobile App\](\#4-teacher-mobile-app)  
5\. \[Shared UI/UX Guidelines\](\#5-shared-uiux-guidelines)  
6\. \[State Management & API Integration\](\#6-state-management--api-integration)  
7\. \[Authentication & Session Handling\](\#7-authentication--session-handling)  
8\. \[Offline Support (Teacher App only)\](\#8-offline-support-teacher-app-only)  
9\. \[Push Notifications\](\#9-push-notifications)  
10\. \[Performance & Accessibility\](\#10-performance--accessibility)  
11\. \[Testing Strategy\](\#11-testing-strategy)  
12\. \[Deployment & Hosting\](\#12-deployment--hosting)  
13\. \[Folder Structure (Example)\](\#13-folder-structure-example)

\---

\#\# 1\. Common Requirements (All Frontends)

\#\#\# 1.1 Authentication Flow  
\- Login screen (email \+ password)  
\- JWT token storage (secure, httpOnly cookies recommended for web, secure storage for mobile)  
\- Refresh token mechanism (automatic silent refresh)  
\- Logout (clear tokens, redirect to login)  
\- Role‑based redirection after login:  
  \- SuperAdmin → SuperAdmin Dashboard  
  \- OrgAdmin → Organization Dashboard  
  \- Teacher → Teacher App (mobile)

\#\#\# 1.2 API Client  
\- Base URL configurable (dev/staging/prod)  
\- Axios (web) / http client (Flutter/RN)  
\- Automatic token injection in \`Authorization\` header  
\- Interceptor for 401 → refresh token or logout

\#\#\# 1.3 Error Handling  
\- Global error boundary (web) / error widget (mobile)  
\- User‑friendly error messages (non‑technical)  
\- Retry logic for network failures

\#\#\# 1.4 Multi‑language Support (i18n)  
\- Support for at least 2 languages (English \+ local language)  
\- Language selection in user profile  
\- Date/time formatting based on locale

\#\#\# 1.5 Theme Support  
\- Light / dark mode toggle  
\- Consistent color palette (primary, secondary, success, error, warning)  
\- Responsive design (web) / adaptive (mobile)

\#\#\# 1.6 Security  
\- XSS protection (React: automatic escaping, Flutter: text sanitization)  
\- CSRF protection (web: use cookies with SameSite)  
\- Prevent sensitive data in logs or URL params

\---

\#\# 2\. SuperAdmin Dashboard (Web)

\#\#\# 2.1 Target Users  
\- Platform owners (SmartCampus administrators)  
\- Manages all organisations (schools/colleges)  
\- No access to student/attendance data of individual orgs (only aggregated)

\#\#\# 2.2 Key Features

| Feature | Description |  
|---------|-------------|  
| \*\*Login\*\* | Only super admin credentials |  
| \*\*Organisation Management\*\* | Create, view, edit, suspend/activate schools/colleges |  
| \*\*User Management\*\* | View all org admins, reset passwords, deactivate |  
| \*\*Subscription Management\*\* | Upgrade/downgrade plans (basic/premium/enterprise), set max teachers/students, extend validity |  
| \*\*Analytics (Platform‑wide)\*\* | Total organisations, total active users, total students, attendance trends across all orgs |  
| \*\*Backup Management\*\* | Trigger manual backup, view backup history, restore from backup |  
| \*\*Audit Logs\*\* | View actions performed by any user across platform (filter by org, user, action) |  
| \*\*System Settings\*\* | Configure global limits, feature flags (enable/disable face recognition, etc.) |

\#\#\# 2.3 Pages & Routes

| Route | Page | Access |  
|-------|------|--------|  
| \`/login\` | Login | Public |  
| \`/dashboard\` | Overview (stats, recent orgs) | SuperAdmin |  
| \`/organisations\` | List all orgs (search, filter, paginate) | SuperAdmin |  
| \`/organisations/create\` | Create new org form | SuperAdmin |  
| \`/organisations/:id\` | Org details (edit, suspend, subscription) | SuperAdmin |  
| \`/users\` | List all org admins & super admins | SuperAdmin |  
| \`/backups\` | Backup management (list, create, restore) | SuperAdmin |  
| \`/audit-logs\` | Audit trail viewer | SuperAdmin |  
| \`/settings\` | System settings | SuperAdmin |

\#\#\# 2.4 API Endpoints Used (from backend)

| Endpoint | Method | Purpose |  
|----------|--------|---------|  
| \`/api/v1/auth/login\` | POST | Login |  
| \`/api/v1/orgs\` | GET, POST | List, create orgs |  
| \`/api/v1/orgs/:id\` | GET, PATCH | Get/update org |  
| \`/api/v1/users\` | GET | List all users (filter by role) |  
| \`/api/v1/users/:id/deactivate\` | DELETE | Deactivate user |  
| \`/api/v1/backup/create\` | POST | Manual backup |  
| \`/api/v1/backup/list\` | GET | List backups |  
| \`/api/v1/backup/restore/:id\` | POST | Restore |  
| \`/api/v1/analytics/platform\` | GET | Platform‑wide stats |  
| \`/api/v1/audit-logs\` | GET | Fetch audit logs |

\#\#\# 2.5 UI Components (Custom)  
\- Data table with sorting, filtering, pagination  
\- Organisation card (showing name, type, status, subscription)  
\- Subscription plan selector (basic/premium/enterprise)  
\- Confirmation modals for destructive actions (suspend, restore)  
\- Charts (using Recharts or Chart.js) for analytics

\#\#\# 2.6 State Management  
\- \*\*Global\*\*: Redux Toolkit or Zustand (for auth, org list, user list)  
\- \*\*Local\*\*: React hooks (useState, useReducer)

\---

\#\# 3\. Organization Dashboard (Web)

\#\#\# 3.1 Target Users  
\- Org Admins (principals, administrators of a specific school/college)  
\- Full control over their own organisation’s data (teachers, students, attendance, analytics)

\#\#\# 3.2 Key Features

| Feature | Description |  
|---------|-------------|  
| \*\*Login\*\* | Org admin email/password |  
| \*\*Dashboard\*\* | Overview: total students, teachers, today’s attendance %, recent sessions |  
| \*\*Teacher Management\*\* | Invite new teachers, view teacher list, deactivate teachers, reset passwords |  
| \*\*Student Management\*\* | Add/import (CSV) students, edit, delete, view student profiles with photos |  
| \*\*Course & Subject Management\*\* | Create courses, subjects, semesters, sections |  
| \*\*Session Management\*\* | View all sessions (filter by teacher, date, subject) |  
| \*\*Attendance Analytics\*\* | Class‑wise attendance %, student‑wise reports, export to CSV |  
| \*\*Reports\*\* | Generate and download attendance reports (PDF/Excel) |  
| \*\*Settings\*\* | Organisation profile (name, address, contact), change admin password |

\#\#\# 3.3 Pages & Routes

| Route | Page | Access |  
|-------|------|--------|  
| \`/login\` | Login | Public |  
| \`/dashboard\` | Org overview | OrgAdmin |  
| \`/teachers\` | List teachers, invite, deactivate | OrgAdmin |  
| \`/teachers/invite\` | Invite new teacher form | OrgAdmin |  
| \`/students\` | List students (search, filter by course/semester) | OrgAdmin |  
| \`/students/import\` | Bulk import CSV | OrgAdmin |  
| \`/students/:id\` | Student profile (edit, view attendance) | OrgAdmin |  
| \`/courses\` | Manage courses & subjects | OrgAdmin |  
| \`/sessions\` | View all sessions (calendar/list) | OrgAdmin |  
| \`/analytics\` | Attendance analytics dashboard | OrgAdmin |  
| \`/reports\` | Generate reports | OrgAdmin |  
| \`/settings\` | Organisation settings | OrgAdmin |

\#\#\# 3.4 API Endpoints Used

| Endpoint | Method | Purpose |  
|----------|--------|---------|  
| \`/api/v1/auth/login\` | POST | Login |  
| \`/api/v1/users/invite\` | POST | Invite teacher |  
| \`/api/v1/users/teachers\` | GET | List teachers |  
| \`/api/v1/users/:id/deactivate\` | DELETE | Deactivate teacher |  
| \`/api/v1/students\` | GET, POST | List, create student |  
| \`/api/v1/students/import\` | POST | Bulk import |  
| \`/api/v1/students/:id\` | GET, PUT, DELETE | CRUD student |  
| \`/api/v1/courses\` | CRUD | Course management |  
| \`/api/v1/sessions\` | GET | List sessions |  
| \`/api/v1/analytics/class/:courseId\` | GET | Class analytics |  
| \`/api/v1/analytics/student/:studentId\` | GET | Student report |

\#\#\# 3.5 UI Components  
\- Dashboard cards with KPI numbers  
\- Student carousel (optional – for quick view)  
\- Data tables with inline editing  
\- Drag‑and‑drop CSV upload  
\- Calendar view for sessions (FullCalendar or similar)  
\- Charts (attendance trends, subject‑wise percentages)

\---

\#\# 4\. Teacher Mobile App

\#\#\# 4.1 Target Users  
\- Teachers (assigned to courses/sections)  
\- Primary device: smartphone (iOS & Android)

\#\#\# 4.2 Framework Choice  
| Option | Pros | Cons |  
|--------|------|------|  
| \*\*Flutter\*\* | Single codebase, excellent performance, rich UI components | Larger app size, Dart language |  
| \*\*React Native\*\* | JavaScript ecosystem, hot reload, smaller community for complex UI | Bridge performance issues for heavy animations |

\*\*Recommendation:\*\* Flutter (because of the carousel with student images and smooth animations).

\#\#\# 4.3 Key Features

| Feature | Description |  
|---------|-------------|  
| \*\*Login\*\* | Teacher email/password (biometric optional) |  
| \*\*Today’s Sessions\*\* | List of sessions scheduled for today (subject, time, section) |  
| \*\*Mark Attendance\*\* | Carousel with student photos, swipe to mark present/absent/late, bulk actions |  
| \*\*Session History\*\* | Past sessions (last 7 days, filter by date) |  
| \*\*Student Profiles\*\* | View student details (name, roll number, parent contact) – read only |  
| \*\*Attendance Analytics\*\* | View own classes: attendance % per subject, per session |  
| \*\*Profile\*\* | View/edit own profile, change password, language/theme |  
| \*\*Offline Mode\*\* | Mark attendance without internet; sync when online |  
| \*\*Push Notifications\*\* | Reminder for upcoming sessions, low attendance alerts |

\#\#\# 4.4 Screens (Flutter / React Native)

| Screen | Description |  
|--------|-------------|  
| \`LoginScreen\` | Email \+ password, biometric option |  
| \`HomeScreen\` | Today’s sessions list, quick stats |  
| \`SessionDetailScreen\` | Show session info (subject, time, section) \+ button “Mark Attendance” |  
| \`AttendanceCarouselScreen\` | Carousel of student photos, each with status selector (present/absent/late) |  
| \`AttendanceSummaryScreen\` | After marking, show summary (present/absent counts) |  
| \`SessionHistoryScreen\` | List of past sessions (grouped by date) |  
| \`StudentProfileScreen\` | View student details (no edit) |  
| \`AnalyticsScreen\` | Charts: attendance % per subject, per month |  
| \`ProfileScreen\` | Edit name, password, language, theme, logout |

\#\#\# 4.5 API Endpoints Used (Mobile)

| Endpoint | Method | Purpose |  
|----------|--------|---------|  
| \`/api/v1/auth/login\` | POST | Login |  
| \`/api/v1/sessions?teacherId=...\&date=today\` | GET | Today’s sessions |  
| \`/api/v1/sessions?teacherId=...\&startDate=...\` | GET | Past sessions |  
| \`/api/v1/attendance/mark\` | POST | Mark attendance |  
| \`/api/v1/attendance/session/:sessionId\` | GET | Fetch attendance for a session (to edit) |  
| \`/api/v1/students?sessionId=...\` | GET | List students for a session (with photos) |  
| \`/api/v1/students/:id\` | GET | Student profile |  
| \`/api/v1/analytics/teacher/:teacherId\` | GET | Teacher’s attendance analytics |

\#\#\# 4.6 Offline Support (Critical)

\*\*Algorithm:\*\*  
1\. When marking attendance offline:  
   \- Store attendance data in local SQLite/Hive (key: sessionId \+ timestamp).  
   \- Show “Saved offline” indicator.  
2\. When internet is restored:  
   \- Sync local pending attendance records to backend.  
   \- Resolve conflicts (latest timestamp wins).  
3\. Sync strategy: background sync (WorkManager for Android, BGTask for iOS).

\#\#\# 4.7 Push Notifications  
\- Use Firebase Cloud Messaging (FCM) for both Flutter/RN.  
\- Notification types:  
  \- “Session starts in 15 minutes”  
  \- “Attendance marked successfully”  
  \- “Low attendance alert for student X”

\#\#\# 4.8 Student Photo Carousel – Technical Requirements  
\- Fetch student photos (stored as URLs from backend CDN).  
\- Cache images locally (using \`cached\_network\_image\` in Flutter).  
\- Swipe left/right to navigate students.  
\- Each student card displays:  
  \- Photo (circular)  
  \- Name, roll number  
  \- Status buttons (Present / Absent / Late) with color coding.  
\- Progress indicator: show how many marked out of total.

\---

\#\# 5\. Shared UI/UX Guidelines

\#\#\# 5.1 Design System  
\- \*\*Colors\*\*:  
  \- Primary: \`\#3B82F6\` (blue)  
  \- Secondary: \`\#10B981\` (green)  
  \- Danger: \`\#EF4444\` (red)  
  \- Warning: \`\#F59E0B\` (amber)  
  \- Background: light/dark variants  
\- \*\*Typography\*\*:  
  \- Sans‑serif font (Inter for web, Roboto for Android, SF Pro for iOS)  
  \- Hierarchy: headings (24px, 20px), body (14px), caption (12px)  
\- \*\*Spacing\*\*: 8px grid system.  
\- \*\*Icons\*\*: Lucide (web), Feather (mobile) or custom SVG.

\#\#\# 5.2 Responsive Breakpoints (Web)  
| Breakpoint | Target |  
|------------|--------|  
| \< 640px | Mobile (stacked layout) |  
| 640–1024px | Tablet (2 columns) |  
| \> 1024px | Desktop (full width) |

\#\#\# 5.3 Accessibility (WCAG 2.1 AA)  
\- Keyboard navigation (web)  
\- Screen reader support (ARIA labels)  
\- Minimum contrast ratio 4.5:1  
\- Touch targets at least 44x44pt (mobile)

\#\#\# 5.4 Loading States  
\- Skeleton screens for initial load  
\- Spinners for button actions  
\- Progress bar for file uploads

\---

\#\# 6\. State Management & API Integration

\#\#\# 6.1 Web (React)  
\- \*\*Global state\*\*: Redux Toolkit (auth, user, organisations, students, etc.)  
\- \*\*Server state\*\*: React Query (TanStack Query) – caching, background refetch  
\- \*\*Local state\*\*: useState / useReducer

\#\#\# 6.2 Mobile (Flutter)  
\- \*\*Global state\*\*: Provider / Riverpod / Bloc (recommended: Bloc for complex flows)  
\- \*\*Local persistence\*\*: Hive / SharedPreferences for auth token, SQLite for offline attendance  
\- \*\*API client\*\*: Dio with interceptors

\#\#\# 6.3 API Client Configuration

\*\*Web (Axios):\*\*  
\`\`\`javascript  
const api \= axios.create({  
  baseURL: process.env.NEXT\_PUBLIC\_API\_URL,  
  withCredentials: true, // for refresh cookie  
});  
api.interceptors.request.use((config) \=\> {  
  config.headers.Authorization \= \`Bearer ${getAccessToken()}\`;  
  return config;  
});  
\`\`\`

\*\*Mobile (Dio):\*\*  
\`\`\`dart  
final dio \= Dio(BaseOptions(baseUrl: env.apiUrl));  
dio.interceptors.add(InterceptorsWrapper(  
  onRequest: (options, handler) {  
    options.headers\['Authorization'\] \= 'Bearer $accessToken';  
    return handler.next(options);  
  },  
));  
\`\`\`

\---

\#\# 7\. Authentication & Session Handling

\#\#\# 7.1 Web  
\- On login, store access token in memory (or httpOnly cookie if backend sets it).  
\- Refresh token stored in httpOnly cookie (set by backend).  
\- Use \`setInterval\` to refresh token 1 minute before expiry.

\#\#\# 7.2 Mobile  
\- Store access token securely (Flutter: \`flutter\_secure\_storage\`, RN: \`react-native-keychain\`).  
\- Refresh token also stored securely.  
\- Implement token refresh interceptor: on 401, call refresh endpoint, retry original request.

\#\#\# 7.3 Logout  
\- Clear local tokens.  
\- Redirect to login screen.  
\- Call backend logout endpoint to invalidate refresh token.

\---

\#\# 8\. Offline Support (Teacher App only)

\#\#\# 8.1 Data to Cache Locally  
\- Student list for each session (with photo URLs)  
\- Session details (subject, time, section)  
\- Pending attendance marks

\#\#\# 8.2 Sync Algorithm  
1\. App starts: check for pending sync.  
2\. If online, send batch of pending attendance records to \`/attendance/mark\`.  
3\. On success, remove from local pending store.  
4\. On failure, keep and retry later (exponential backoff).

\#\#\# 8.3 Conflict Resolution  
\- If attendance already exists on server (e.g., marked by another teacher), newer timestamp wins.  
\- Show user a conflict dialog if necessary.

\---

\#\# 9\. Push Notifications

\#\#\# 9.1 Setup  
\- \*\*Web\*\*: Service workers \+ web push (optional)  
\- \*\*Mobile\*\*: FCM (Firebase Cloud Messaging)

\#\#\# 9.2 Notification Payload (from backend)  
\`\`\`json  
{  
  "title": "Upcoming Session",  
  "body": "Computer Science – Section A at 10:00 AM",  
  "data": {  
    "type": "session\_reminder",  
    "sessionId": "65a1b2c3..."  
  }  
}  
\`\`\`

\#\#\# 9.3 Handling on Mobile  
\- When notification tapped, navigate to relevant screen (e.g., SessionDetailScreen).

\---

\#\# 10\. Performance & Accessibility

\#\#\# 10.1 Web Performance  
\- Next.js (recommended) with static generation for public pages.  
\- Image optimization (next/image).  
\- Code splitting (dynamic imports).  
\- Lazy load heavy components (charts, tables).

\#\#\# 10.2 Mobile Performance  
\- Flutter: use \`const\` constructors, avoid unnecessary rebuilds, use \`ListView.builder\`.  
\- Image caching (\`cached\_network\_image\`).  
\- Minimise JSON serialisation overhead.

\#\#\# 10.3 Accessibility  
\- Semantic HTML (web)  
\- \`alt\` text for images  
\- \`aria-label\` for interactive elements  
\- Flutter: \`Semantics\` widget, \`excludeSemantics\` where needed.

\---

\#\# 11\. Testing Strategy

\#\#\# 11.1 Web (React/Next.js)  
| Test Type | Tool | Scope |  
|-----------|------|-------|  
| Unit | Jest \+ React Testing Library | Components, hooks, utils |  
| Integration | Jest \+ MSW (Mock Service Worker) | API integration, form submission |  
| E2E | Cypress or Playwright | Critical user flows (login, create org, invite teacher) |

\#\#\# 11.2 Mobile (Flutter)  
| Test Type | Tool | Scope |  
|-----------|------|-------|  
| Unit | \`test\` | Models, utilities, BLoC logic |  
| Widget | \`flutter\_test\` | UI components |  
| Integration | \`flutter\_driver\` or \`integration\_test\` | Full app flow (login, mark attendance) |

\---

\#\# 12\. Deployment & Hosting

\#\#\# 12.1 SuperAdmin & Organization Web  
\- \*\*Hosting\*\*: Vercel / Netlify / AWS S3 \+ CloudFront  
\- \*\*Domain\*\*: \`admin.smartcampus.com\` (SuperAdmin), \`app.smartcampus.com\` (Organization)  
\- \*\*Environment variables\*\*: API URL, Sentry DSN, etc.

\#\#\# 12.2 Teacher Mobile App  
\- \*\*iOS\*\*: App Store Connect  
\- \*\*Android\*\*: Google Play Console  
\- \*\*CI/CD\*\*: GitHub Actions \+ Fastlane (automated build & deploy)  
\- \*\*Over‑the‑air updates\*\*: Use Shorebird (Flutter) or CodePush (RN) for urgent fixes.

\---

\#\# 13\. Folder Structure (Example)

\#\#\# 13.1 Web (Next.js) – SuperAdmin & Organization

\`\`\`  
web/  
├── apps/  
│   ├── super-admin/  
│   │   ├── pages/  
│   │   ├── components/  
│   │   ├── hooks/  
│   │   ├── store/  
│   │   └── next.config.js  
│   └── org-admin/  
│       ├── pages/  
│       ├── components/  
│       ├── hooks/  
│       ├── store/  
│       └── next.config.js  
├── packages/  
│   ├── ui/               \# Shared UI components (button, card, table)  
│   ├── api/              \# Shared API client & types  
│   └── utils/            \# Shared helpers  
└── package.json  
\`\`\`

Or simpler: two separate Next.js projects in different folders.

\#\#\# 13.2 Mobile (Flutter)

\`\`\`  
teacher\_app/  
├── lib/  
│   ├── main.dart  
│   ├── app/  
│   │   ├── routes.dart  
│   │   └── theme.dart  
│   ├── features/  
│   │   ├── auth/  
│   │   ├── home/  
│   │   ├── session/  
│   │   ├── attendance/  
│   │   ├── analytics/  
│   │   └── profile/  
│   ├── core/  
│   │   ├── api/  
│   │   ├── storage/  
│   │   ├── utils/  
│   │   └── widgets/  
│   └── services/  
│       ├── notification\_service.dart  
│       └── sync\_service.dart  
├── assets/  
├── pubspec.yaml  
└── firebase\_options.dart  
\`\`\`

\---

\#\# Next Steps

1\. \*\*Choose frameworks\*\* (React/Next.js for web, Flutter for mobile).  
2\. \*\*Set up monorepo\*\* (or separate repos) – follow the repository structure from the previous answer.  
3\. \*\*Implement the backend first\*\* (or in parallel) – API endpoints as defined.  
4\. \*\*Create shared API client\*\* (OpenAPI / Swagger generator recommended).  
5\. \*\*Develop shared UI component library\*\* (for web) to ensure consistency.  
6\. \*\*Build each frontend incrementally\*\*, starting with authentication, then core features.

This document provides everything needed to start frontend development. Feed it to an AI code generator with the prompt: \*“Based on this SmartCampus frontend specification, generate the complete code for \[SuperAdmin Dashboard / Organization Dashboard / Teacher App\] following all guidelines.”\*  
