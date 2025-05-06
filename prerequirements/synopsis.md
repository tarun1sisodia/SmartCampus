# Attendance Management System

## Abstract
The Attendance Management System is a cross-platform Flutter application designed to streamline the process of tracking student attendance in educational institutions. The system enables teachers to create and manage classes, organize them by courses and subjects, and efficiently record student attendance. Built with a modern tech stack including Flutter, GetX for state management, and Supabase for backend services, the application provides a responsive and intuitive interface for educational professionals to maintain accurate attendance records.

---

## Project Introduction

### Purpose
The Attendance Management System addresses the challenges faced by educational institutions in maintaining accurate and accessible attendance records. Traditional paper-based methods are prone to errors, difficult to analyze, and time-consuming. This digital solution aims to simplify the attendance tracking process while providing valuable insights through data visualization.

---

## Key Features
- **User authentication** with role-based access control
- **Class management** organized by courses and subjects
- **Student enrollment and management**
- **Real-time attendance tracking**
- **Course-specific subject filtering**
- **Cross-platform compatibility** (Windows, Linux, mobile)
- **Dark and light theme support**

---

## Technology Stack
- **Frontend**: Flutter framework with Dart programming language
- **State Management**: GetX for reactive state management
- **Backend**: Supabase (PostgreSQL database with RESTful API)
- **Authentication**: Supabase Auth with JWT tokens
- **UI Components**: Custom-designed widgets with theme support

---

## Data Flow Diagram (DFD)
```plaintext
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│             │         │             │         │             │
│    User     │◄────────│    UI       │◄────────│  GetX       │
│  Interface  │         │  Screens    │         │Controllers  │
│             │─────────►             │─────────►             │
└─────────────┘         └─────────────┘         └──────┬──────┘
                                                       │
                                                       │
                                                       ▼
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│             │         │             │         │             │
│  Supabase   │◄────────│  Service    │◄────────│  Model      │
│  Database   │         │  Layer      │         │  Classes    │
│             │─────────►             │─────────►             │
└─────────────┘         └─────────────┘         └─────────────┘
```

## Data Flow Description:
User Interface to UI Screens: User interactions (clicks, form inputs) are captured by UI components and passed to the appropriate screens.

UI Screens to GetX Controllers: Screen components use GetX controllers to manage state and trigger business logic operations.

Controllers to Models: Controllers process data through model classes which define the structure of the application data.

Controllers to Service Layer: Controllers call service methods to interact with the backend.

Service Layer to Supabase Database: Services make API calls to Supabase to perform CRUD operations on the database.

Reverse Flow: Data retrieved from the database flows back through the service layer, is processed by controllers, and displayed on the UI.

## Sign up & Login Architecture
The authentication system follows a secure and streamlined architecture:

```plaintext
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Login/     │     │  Auth       │     │  Supabase   │
│  Signup     │────►│  Controller │────►│  Auth       │
│  Screen     │     │             │     │  Service    │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │  JWT Token  │
                                        │  Generation │
                                        └──────┬──────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Role-based │     │  User       │     │  User Data  │
│  Dashboard  │◄────│  Session    │◄────│  Storage    │
│             │     │  Management │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

## Authentication Flow:
### User Registration:

- User enters email, password, and selects role (teacher/student)
- Form validation ensures data integrity
- Credentials are securely transmitted to Supabase Auth
- User record is created with appropriate role permissions

### User Login:

- User provides email and password
- Credentials are verified against Supabase Auth
- Upon successful authentication, JWT token is generated
- Token is stored securely for subsequent API requests

### Session Management:

- JWT token is used to maintain user session
- Token expiration is handled with automatic refresh
- User session persists across app restarts

### Authorization:

- Role-based access control determines available features
- Teachers access class management and attendance features
- Row-Level Security (RLS) in Supabase ensures data privacy

### Logout Process:

- User session is terminated
- JWT token is invalidated
- User is redirected to login screen

## References
- Flutter Documentation. https://docs.flutter.dev/
- GetX Package Documentation. https://pub.dev/packages/get
- Supabase Documentation. https://supabase.io/docs
- PostgreSQL Documentation. https://www.postgresql.org/docs/
- Flutter UI Best Practices. https://flutter.dev/docs/development/ui/layout
- Row-Level Security in PostgreSQL. https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- JWT Authentication Best Practices. https://auth0.com/blog/a-look-at-the-latest-draft-for-jwt-bcp/
- Material Design Guidelines. https://material.io/design
- Flutter State Management Comparison. https://flutter.dev/docs/development/data-and-backend/state-mgmt/options
- Cross-Platform Development with Flutter. https://flutter.dev/multi-platform