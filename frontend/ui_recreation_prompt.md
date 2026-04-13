# SmartCampus UI Recreation Prompt

***

**System Role & Objective**
Act as an expert Flutter developer and UI/UX designer. Your objective is to build the complete frontend user interface for **SmartCampus**, a cross-platform Attendance Management System. The application must look modern, premium, and feature smooth micro-animations, glassmorphism elements, and fully responsive layouts that adapt to both dark and light modes. 

**Tech Stack Requirements**
1. **Framework:** Flutter (latest version)
2. **State Management:** GetX (Controllers, `Obx`, `Rx` wrappers)
3. **Backend/Database Integration Guidelines:** Use `supabase_flutter` for the data layer, but build the UI with mockup data first.
4. **Key UI/UX Packages:** 
   - `iconsax` for modern, clean iconography
   - `percent_indicator` for circular and linear progress bars
   - `table_calendar` for interactive calendar screens
   - `carousel_slider` for onboarding and dashboard highlights
   - `flutter_slidable` for swipe-to-delete/edit list items
   - `local_auth` for biometric auth overlays
   - `shimmer` for skeleton loading states

---

### Core App Features & Navigation Structure

**1. Onboarding & Authentication Flow**
*   **Splash Screen & Biometrics:** An initial screen that checks for biometric login (FaceID/Fingerprint) using `local_auth` layered over a blurred glassmorphism background.
*   **Login Screen:** Email/password and Google Sign-in buttons. Provide polished form validation, error states, and a clean "Forgot Password" flow.
*   **Onboarding Carousel:** A sleek `carousel_slider` with animated Lottie assets to introduce new users to features.

**2. Main Navigation (BottomNavigationBar)**
The main navigation is built using GetX to swap `Obx` screens. It should have a floating, blurred background effect with 4 main tabs:
*   **Home (Dashboard):** A quick overview of statistics.
*   **Classes:** A list of all courses the teacher manages.
*   **Sessions:** A chronological view of specific attendance sessions.
*   **Calendar:** A full month/week interactive calendar.

---

### Screen-by-Screen UI Requirements

#### 1. Dashboard Screen (Home)
*   **Silver AppBar:** A collapsible app bar that snaps on scroll. It should have dynamic animated transitions showing a circular Avatar, Greeting Text, and quick action icons.
*   **Search Bar:** A prominent rounded search input field.
*   **Stats Overview:** Row of `StatCard` widgets showing "Total Classes" and "Total Students".
*   **Average Attendance Chart:** A large animated `CircularPercentIndicator`.
*   **Recent Classes List:** A `ListView.builder` showing the latest 3 classes.

#### 2. Class List & Detail Screens
*   **Classes Tab:** Clean, scrollable list of active classes.
*   **Swipe Actions:** Use `flutter_slidable` for swipe-to-edit or swipe-to-delete.
*   **Class Detail View (Attendance Screen):** 
    *   Shows a grid or list of students.
    *   Buttons to mark Present / Absent / Late.
    *   Sticky bottom bar to "Save Attendance".

#### 3. Calendar Screen
*   **Table Calendar:** View historical attendance.
*   **Event Markers:** Show dots on days where sessions exist.
*   **Bottom Sheet:** Details slides up showing sessions on that date.

---

### State Management & Controllers Architecture
There are **19 specialized GetX Controllers** covering all backend interactions mapping to UI inputs. Below are the specific controller names along with the public methods (UI triggers) you must implement or bind to the UI:

#### Authentication & Onboarding (7 Controllers)
**1. `onboarding_controller.dart`** (Carousel and first-time user tutorial)
- `updatePageIndicator(index)`
- `dotNavigationClick(index)`
- `nextPage()`
- `skipPage()`
- `checkIfOnboardingCompleted()`

**2. `supabase_auth_controller.dart`** (Core global auth wrapper handling native sessions)
- `loadSavedCredentials()`
- `setRememberMe(bool value)`
- `Future<void> signInWithEmail() async`
- `Future<void> signUpWithEmail(String name, String phone) async`
- `Future<void> storeUserData() async`
- `Future<void> resendVerificationEmail(String email) async`
- `Future<bool> checkEmailVerified() async`
- `Future<void> resetPassword() async`
- `Future<bool> isSessionValid() async`
- `Future<void> signOut() async`

**3. `login_controller.dart`** (UI validation and triggers for login screen)
- `loadSavedCredentials()`
- `setRememberMe(bool value)`
- `togglePasswordVisibility()`
- `Future<void> signInWithGoogle() async`
- `bool isUserLoggedIn()`
- `void login() async`

**4. `signup_controller.dart`** (UI validation for registration)
- `togglePasswordVisibility()`
- `Future<void> signUpWithEmail() async`
- `Future<void> signUpWithGoogle() async`
- `Future<void> resendVerificationEmail() async`

**5. `forgot_password_controller.dart`** (Password recovery)
- `Future<void> resetPassword() async`

**6. `change_password_controller.dart`** (Changing password when logged in)
- `toggleCurrentPasswordVisibility()`
- `toggleNewPasswordVisibility()`
- `toggleConfirmPasswordVisibility()`
- `calculatePasswordStrength(String password)`
- `checkPasswordsMatch()`
- `bool validateFields()`
- `Future<void> changePassword() async`

**7. `oauth_consent_controller.dart`** (Third-party app auth context)
- `Future<void> fetchAuthorizationDetails() async`
- `Future<void> approve() async`
- `Future<void> deny() async`

#### Home & Navigation (2 Controllers)
**8. `dashboard_controller.dart`** (Home screen data, stats, classes, and auth prompt)
- `String getConnectionStatus()`
- `Future<void> reconnectRealtime() async`
- `Future<void> checkBiometricAuthentication() async`
- `initializeGreeting()`
- `resetGreetingAnimation()`
- `bool hasError()`
- `Future<void> loadDashboardData() async`
- `Future<void> initializeAfterSplash() async`
- `Future<void> createInitialData() async`
- `searchClasses(String query)`
- `Future<bool> authenticateWithBiometrics() async`

**9. `teacher_profile_controller.dart`** (Global profile stats binding)
- `Future<void> loadTeacherStats() async`
- `Future<void> refreshProfileData() async`
- `Future<void> loadUserData() async`
- `toggleEmailNotifications(bool value)`
- `toggleTheme()`
- `toggleEditMode()`
- `Future<void> toggleBiometric(bool value) async`
- `Future<void> updateProfile() async`
- `Future<void> logout() async`
- `Future<void> pickAndUploadImage() async`
- `Future<void> deleteAccount() async`
- `viewProfileImage()`

#### Classes & Students (3 Controllers)
**10. `class_controller.dart`** (Course/Class operations)
- `searchClasses(String query)`
- `Future<void> loadClasses() async`
- `Future<void> loadClassesPage()`
- `Future<void> loadMoreClasses() async`
- `Future<void> loadCoursesAndSubjects() async`
- `Future<void> createClass() async`
- `Future<void> updateClass(String classId) async`
- `Future<void> deleteClass(String classId) async`
- `Future<void> deleteSelectedClasses() async`
- `bool validateClassForm()`
- `loadClassForEditing(ClassModel classModel)`
- `toggleSelectionMode(String? initialClassId)`
- `toggleClassSelection(String classId)`
- `toggleSelectAll()`
- `clearSelections()`
- `String getConnectionStatus()`
- `Future<void> reconnectRealtime() async`

**11. `student_controller.dart`** (Lists of students for specific classes)
- `setSelectedClass(ClassModel classModel)`
- `Future<void> loadMoreStudents() async`
- `Future<void> pickImage(ImageSource source) async`
- `clearSelectedImage()`
- `Future<void> addStudentToClass() async`
- `toggleSelectionMode()`
- `toggleStudentSelection(String studentId)`
- `toggleSelectAll()`
- `Future<void> removeSelectedStudentsFromClass() async`
- `Future<void> updateStudentImage(String studentId, String rollNumber) async`
- `Future<void> fetchAvailableStudents() async`
- `selectStudent(StudentModel student)`
- `deselectStudent(StudentModel student)`
- `Future<void> importSelectedStudents() async`
- `sortAvailableStudents(String option)`
- `selectAllFilteredStudents(List<StudentModel> filteredStudents)`
- `deselectAllStudents()`

**12. `student_detail_controller.dart`** (Individual profile & history viewing)
- `setStudentAndClass(StudentModel studentModel, String classId)`
- `Future<void> loadStudentData([String? studentId, String? classId]) async`
- `Future<void> pickImage(ImageSource source) async`
- `Future<void> deleteStudentImage() async`
- `Future<void> updateStudentImage() async`

#### Attendance Management (4 Controllers)
**13. `attendance_controller.dart`** (Main attendance grid/list actions)
- `setSelectedClass(ClassModel classModel)`
- `Future<void> loadAttendanceSessions(String classId) async`
- `Future<void> loadMoreAttendanceSessions() async`
- `Future<void> loadMoreStudents() async`
- `Future<void> loadStudentsForClass()`
- `Future<void> loadStudentsForSession()`
- `updateStudentStatus(String studentId, String status)`
- `Future<void> submitAttendance() async`
- `Future<void> createAttendanceSession() async`
- `bool isSessionRunning(String sessionId)`

**14. `carousel_attendance_controller.dart`** (Alternative swipe-based attendance)
- `updateStatistics()`
- `markCurrentStudent(String status)`
- `moveToNextStudent()`
- `moveToPreviousStudent()`
- `Future<void> submitAttendance() async`

**15. `all_sessions_controller.dart`** (Chronological view of all class sessions)
- `Future<void> loadAllSessions()`
- `Future<void> loadMoreSessions() async`
- `Future<void> loadClasses() async`
- `filterSessions()`
- `resetFilters()`
- `Future<void> deleteSession(String sessionId) async`
- `bool isSessionClosed(AttendanceSessionWithClass session)`
- `bool isSessionRunning(AttendanceSessionWithClass session)`
- `Future<void> closeSession(String sessionId) async`
- `toggleSelectionMode(String? initialSessionId)`
- `toggleSessionSelection(String sessionId)`
- `toggleSelectAll()`
- `clearSelections()`
- `Future<void> deleteSelectedSessions() async`
- `Future<void> refreshData() async`

**16. `session_details_controller.dart`** (Viewing a past session's data)
- `Future<void> loadSessionDetails(String sessionId) async`
- `Future<void> loadAttendanceRecords(String sessionId) async`
- `Future<void> toggleAttendance(String recordId, bool isPresent) async`
- `bool isSessionActive()`
- `String formatDate(DateTime date)`
- `refreshData(String sessionId)`
- `generateQRCode()`
- `exportAttendanceData() async`
- `openManualAttendance()`
- `searchStudents()`
- `viewAllStudents()`

#### Reports & Utilities (3 Controllers)
**17. `attendance_reports_controller.dart`** (Aggregated stats, charts, and exports)
- `Future<void> loadMoreReportStudents() async`
- `updateSearchQuery(String query)`
- `Future<void> loadClasses() async`
- `Future<void> loadAttendanceData() async`
- `Future<void> updateSelectedClass(String classId) async`
- `navigateToStudentDetail(StudentModel student)`
- `Future<void> exportAttendanceReport() async`
- `String getConnectionStatus()`
- `Future<void> reconnectRealtime() async`
- `Future<void> refreshData() async`

**18. `calendar_controller.dart`** (Calendar dots rendering)
- `applyFilters()`
- `List<AttendanceSessionModel> getSessionsForDay(DateTime day)`
- `bool isSessionActive(AttendanceSessionModel session)`
- `refreshData()`
- `Future<void> fetchTeacherNames() async`
- `Future<void> loadData() async`
- `String getTeacherNameForSession(AttendanceSessionModel session)`

**19. `feedback_controller.dart`** (Reporting system bugs)
- `checkAndShowFeedback()`
- `showFeedbackDialog()`
- `setRating(int value)`
- `updateFeedbackText(String text)`
- `Future<void> submitFeedback() async`
- `dismissFeedback()`

---

### Design Aesthetics & Theming Requirements

1. **Light & Dark Mode Support:** All colors must be read dynamically from a theme configuration (`Theme.of(context)`). In Dark mode, use deep blacks, dark grays, and neon accents (like electric blue or vibrant yellow). In Light mode, use crisp whites, soft grays, and primary brand colors.
2. **Typography:** Use modern fonts (e.g., Poppins or Inter). Ensure a clear hierarchy (`headlineLarge`, `titleMedium`, `bodySmall`).
3. **Micro-animations:** 
    *   Use `AnimatedContainer` and `AnimatedCrossFade` for state transitions.
    *   Apply `Shimmer` effects for all loading states instead of basic circular progress indicators.
4. **Card Styling:** Utilize soft rounded corners (`BorderRadius.circular(16)`), subtle drop shadows for elevation, and optional gradient backgrounds for featured statistics.

**First Action Required by AI:** 
Please design the screens(UI) as per my controllers and their functions.(e.g,onboarding_controller.dart and this controller has functions like updatePageIndicator(index), dotNavigationClick(index),nextPage(),skipPage(),checkIfOnboardingCompleted(),, functions name are clearly tell what they do, so per this controllers create UI for each controller. and also use the same color scheme and design aesthetics as per the design_aesthetics.md file for whole app. )
