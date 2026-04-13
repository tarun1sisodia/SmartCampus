# SmartCampus Admin Portal Documentation

This document outlines the architecture and frontend design for the **SmartCampus Management Portal**. This web-based platform is designed specifically for school and college administrators to oversee teachers, students, and institutional data.

---

## 1. Core Technology Stack
We will use a modern, high-performance stack that prioritizes speed and security:

*   **Framework**: [Next.js 15+](https://nextjs.org/) (App Router)
*   **Language**: TypeScript (for strict type safety)
*   **Styling**: [Tailwind CSS](https://tailwindcss.com/)
*   **UI Components**: [shadcn/ui](https://ui.shadcn.com/) (Accessible, customizable components)
*   **Icons**: Lucide React
*   **Data Fetching**: React Server Components + [TanStack Query](https://tanstack.com/query/latest) (for client-side caching)
*   **Forms**: React Hook Form + Zod (for validation)

---

## 2. Frontend Architecture (Next.js App Router)

### Layout System
Next.js uses a nested layout system. We will have a primary `DashboardLayout` that persists the Sidebar and Top Navigation across all admin pages, preventing unnecessary re-renders.

### Key Route Structure
```text
/app
├── (auth)                # Login, Forgot Password
├── (dashboard)           # Protected Admin Area
│   ├── layout.tsx         # Sidebar & Header
│   ├── page.tsx           # Main Overview (Stats)
│   ├── teachers           # Teacher Management (CRUD)
│   ├── classes            # Class & Section Management
│   ├── attendance         # School-wide Attendance Reports
│   └── settings           # School Profile & Global Config
├── api                   # Secure Backend API Routes
├── components            # Reusable UI (Buttons, Tables, Modals)
└── lib                   # Utilities (Supabase Client, Helpers)
```

---

## 3. Core Frontend Features

### A. The Data-Dense Dashboard
The heart of the admin portal. It will use **Recharts** to visualize attendance trends, teacher activity, and student enrollment growth.

### B. Advanced Data Tables
Managing 100+ teachers requires more than a simple list. We will implement:
*   **Server-side Pagination**: Only load data as needed.
*   **Real-time Search**: Find any teacher or student instantly.
*   **Filtering**: Group by department, status, or grade level.

### C. Role-Based Route Protection
Using Next.js **Middleware**, we will intercept every request. If a user is not authenticated or does not have the `admin` role, they are instantly redirected to the login page before any sensitive UI is even rendered.

---

## 4. Why This Design?

### Performance
By using **React Server Components**, we fetch data on the server. This means the user's browser receives a pre-rendered page, making the dashboard feel "instant" compared to traditional React apps.

### Scalability
The "Feature-First" folder structure allows you to add new sections (like "Library Management" or "Fee Collection") without the codebase becoming a mess.

### User Experience (UX)
Admins aren't necessarily "tech-savvy." The UI will focus on **Clarity over Complexity**:
*   Large, readable fonts (Poppins).
*   High-contrast status indicators (Green for Present, Red for Absent).
*   Clean, professional "Corporate" aesthetic to match your Flutter app.

---

> [!IMPORTANT]
> **Mobile Responsiveness**: While optimized for desktop, the portal will be fully responsive. A principal should be able to check school stats on their tablet or phone while on the move.
