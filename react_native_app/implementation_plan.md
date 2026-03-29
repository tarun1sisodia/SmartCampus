# SmartCampus React Native Migration Map (Branch: `feature/react-native-app`)

This document provides a detailed structural and logical breakdown of the existing Flutter-based SmartCampus app, refined with user feedback for the React Native implementation.

## 1. High-Level Architecture Mapping

| Feature | Flutter Implementation | React Native (User Selection) |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart) | React Native (Expo SDK 51+) |
| **State Management** | GetX (Controllers & Rx) | **Redux Toolkit (RTK) + RTK Query** |
| **Navigation** | GetX Navigation | React Navigation (Native Stack) |
| **Backend** | Supabase | `@supabase/supabase-js` |
| **Local Storage** | GetStorage / SharedPrefs | **WatermelonDB (Full Offline-First)** |
| **UI Kit** | Custom (Material based) | `react-native-paper` + `Tamagui` |
| **Icons** | Iconsax | `react-native-vector-icons` |
| **Biometrics** | `local_auth` | `expo-local-authentication` (Safe for Prod) |

---

## 2. Model Mapping (Data Structures)

The following TypeScript interfaces should be created to match the existing Flutter models:

### [NEW] `src/models/`
- **`UserModel`**: (From `lib/models/user_model.dart`) uid, email, role, fullName, department.
- **`StudentModel`**: (From `lib/models/student_model.dart`) id, name, rollNumber, classId, imageUrl, attendanceStatus.
- **`ClassModel`**: (From `lib/models/class_model.dart`) id, name, section, department.
- **`AttendanceSessionModel`**: (From `lib/models/attendance_session_model.dart`) id, classId, date, startTime, endTime, status.
- **`AttendanceRecordModel`**: (From `lib/models/attendance_record_model.dart`) id, sessionId, studentId, status, timestamp.

---

## 3. Service Mapping (Core Logic)

These services handle direct communication with Supabase and local storage.

### [NEW] `src/services/`
#### `SupabaseService.ts`
- Port logic from `lib/services/supabase_auth_controller.dart`.
- Handles `auth.signInWithPassword`, `auth.signUp`, `auth.signOut`.
#### `StudentService.ts`
- Port logic from `lib/services/student_service.dart`.
- `getStudentsForClass(classId: string)`
#### `AttendanceService.ts`
- Port logic from `lib/services/attendance_service.dart`.
- `createSession()`, `submitBulkAttendance()`, `getSessions()`.
#### `StorageService.ts`
- Port logic from `lib/services/storage_service.dart` (GetStorage).
- Handles theme persistence and user session caching.

---

## 4. Controller (Logic) Mapping

In React Native, business logic will reside in **Redux Slices** and **RTK Query API**.

### [NEW] `src/services/db/`
#### `schema.ts` & `models.ts` (WatermelonDB)
- Define `users`, `students`, `classes`, `sessions`, `attendance_records`.
- This ensures **Full Offline Support** as requested.

### [NEW] `src/store/`
#### `attendanceSlice.ts` (Logic from `AttendanceController.dart`)
- **State**: `isLoading`, `selectedClass`.
- **Thunks/Actions**:
    - `syncStudentsForClass(classId)`: Fetch from Supabase and sync to WatermelonDB.
    - `submitAttendance()`: Batch write to WatermelonDB, then sync to Supabase.
    - `checkSessionStatus(sessionId)`: Time-based logic for session validity.

#### `authSlice.ts` (Logic from `SupabaseAuthController.dart`)
- Handles user session, biometric tokens, and role-based access.

---

## 5. Design & Theming (Expanded)

### [NEW] `src/theme/colors.ts`
Existing primary colors will be maintained, with added depth for high-performance aesthetics:

| Token | Hex Code | Purpose |
| :--- | :--- | :--- |
| `primary` | `#3E69FF` | Main actions, branding |
| `primaryLight` | `#E8EFFF` | Button backgrounds, highlighting |
| `primaryDark` | `#1E3BB3` | Active states, headers |
| `success` | `#27C27D` | Present/Marked attendance |
| `error` | `#FF5C5C` | Absent/Error states |
| `warning` | `#FFB444` | Pending/Session ending soon |
| `background` | `#FFFFFF` | Main surface |
| `surface` | `#F8F9FE` | Card backgrounds |
| `neutral` | `#6B7280` | Subtitles, disabled states |
| `accent` | `#7C3AED` | Special teacher tools (Purple) |
| `graph` | `#06B6D4` | Analytics & Reports (Cyan) |

### [NEW] `src/navigation/`
#### `AppNavigator.tsx` (Logic from `lib/app/routes/app_routes.dart`)
- **Stack Navigator**: 
    - `Splash` -> `SplashScreen.tsx`
    - `Onboarding` -> `OnboardingScreen.tsx`
    - `Login` -> `LoginScreen.tsx`
    - `Home` (Bottom Tabs) -> `HomeTabs.tsx`
    - `AttendanceDetail` -> `AttendanceScreen.tsx`
    - `StudentDetail` -> `StudentDetailScreen.tsx`

### [NEW] `src/screens/`
| Screen | Logic Source | Key Features |
| :--- | :--- | :--- |
| **SplashScreen** | `splash_screen.dart` | Auth state check, redirection to Login or Home. |
| **LoginScreen** | `login.dart` | Form validation, social login icons. |
| **Dashboard** | `dashboard_controller.dart` | Class list, quick stats card. |
| **MarkAttendance** | `mark_attendance_screen.dart` | Swipeable student list, camera/barcode toggle. |
| **Reports** | `reports_screen.dart` | Calendar view, attendance percentage charts. |

---

## 6. Open Questions

> [!IMPORTANT]
> 1. **Biometrics**: The Flutter app mentions biometric verification. Should we use `expo-local-authentication` for React Native?
> 2. **Offline Support**: `offline_models.dart` suggests local SQLite usage. Do you want full offline-first support in RN using `WatermelonDB` or simple `AsyncStorage` caching?
> 3. **Theming**: Do we stick to the existing primary colors (`#3E69FF` etc.)?

## 7. Verification Plan

### Manual Verification
- Verify Supabase integration by attempting a login.
- Verify Navigation flow (Splash -> Login -> Home).
- Verify Data fetching (Student list for a class).
