# Attendance Management System

## Overview
The Attendance Management System is a cross-platform Flutter application designed to simplify and streamline the process of tracking student attendance in educational institutions. It provides teachers with tools to manage classes, record attendance, and analyze attendance data efficiently.

## Features
- **User Authentication**: Secure login and signup with role-based access control and JWT token-based authentication.
- **Auto-login Capability**: Remembers user credentials for seamless access.
- **Class Management**: Organize classes by courses, subjects, years, and sections.
- **Student Management**: Enroll and manage students for each class with detailed student profiles.
- **Attendance Tracking**: Real-time attendance marking with status options (present, absent, late, excused).
- **Session Timer**: Track session duration with start and end times.
- **Attendance Analytics**: View and analyze attendance statistics and reports.
- **Multi-language Support**: Integrated language service for internationalization.
- **Dark and Light Themes**: Support for both dark and light modes.
- **Cross-Platform Compatibility**: Works on mobile (iOS/Android), Windows, and Linux.

## Technology Stack
- **Frontend**: Flutter framework with Dart.
- **State Management**: GetX for reactive state management and dependency injection.
- **Local Storage**: GetStorage for persistent local data storage.
- **Backend**: Supabase (PostgreSQL database with RESTful API).
- **Authentication**: Supabase Auth with JWT tokens.
- **UI Components**: Custom-designed widgets with Material Design principles.
- **Plugins**: 
  - File selector for document handling
  - URL launcher for external links
  - Permission handler for system permissions
  - Share plus for content sharing

## Architecture
The application follows a clean architecture pattern with clear separation of concerns:

### Data Flow
- User Interface → UI Screens → GetX Controllers → Models → Service Layer → Supabase Database
- Data retrieved flows back through the service layer, is processed by controllers, and displayed on the UI.

### Authentication Flow
```
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

## Database Structure
The application uses a relational database with the following key views:

### Class Students View
Provides a comprehensive view of students enrolled in classes with related information:
- Student details (name, roll number, email)
- Class information (teacher, subject, course, year, section)
- Subject and course names

### Attendance Records View
Tracks attendance with detailed information:
- Attendance status and remarks
- Student information
- Session details (date, start/end times)
- Class, subject, and course information

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/tarun1sisodia/attendance__.git
   ```
2. Navigate to the project directory:
   ```bash
   cd smartcampus
   ```
3. Update Supabase secrets:
   Replace the placeholder Supabase URL and API key in the `lib/main.dart` file with your own.
   These can be found in your Supabase project settings.
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the application:
   ```bash
   flutter run
   ```

## Building for Production

### Android
1. Follow the signing instructions in the build guide:
   - Create a keystore file
   - Configure `key.properties`
   - Update `build.gradle`
2. Build the APK:
   ```bash
   flutter build apk --release
   ```
   
   For optimized APK size:
   ```bash
   flutter build apk --release --target-platform=android-arm,android-arm64 --split-per-abi
   ```

### iOS
1. Configure signing in Xcode
2. Build for release:
   ```bash
   flutter build ios --release
   ```
3. Create IPA file through Xcode Archive

### Windows/Linux
Build for desktop platforms:
```bash
flutter build windows --release
flutter build linux --release
```

## Usage
1. **Login/Signup**: Create an account or log in with your credentials.
2. **Select a Session**: Choose an attendance session to begin tracking.
3. **Mark Attendance**: Swipe through student cards to mark attendance as present, absent, late, or excused.
4. **Submit Attendance**: Submit the attendance for the session once completed.
5. **View Reports**: Analyze attendance patterns and generate reports.

## Screenshots
_Add screenshots of the app here to showcase its features._

## Troubleshooting

### Android Build Issues
- **Gradle Build Failures**: Update Gradle version or run `flutter clean`
- **Manifest Merge Issues**: Check for conflicting entries in `AndroidManifest.xml`
- **64K Method Limit**: Enable multidex in build.gradle

### iOS Build Issues
- **Signing Issues**: Verify Apple Developer account provisioning profiles
- **Pod Install Failures**: Run `cd ios && pod update`
- **Bitcode Compatibility**: Disable bitcode in Xcode if needed

## Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Commit your changes and push them to your fork.
4. Submit a pull request with a detailed description of your changes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## References
- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Package](https://pub.dev/packages/get)
- [Supabase Documentation](https://supabase.io/docs)
- [Material Design Guidelines](https://material.io/design)
