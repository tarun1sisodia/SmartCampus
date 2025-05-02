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
   git clone https://github.com/tarun1sisodia/smartcampus.git
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

import 'package:attedance__/models/student_model.dart';
import 'package:attedance__/common/utils/constants/colors.dart';
import 'package:attedance__/common/utils/constants/sized.dart';
import 'package:attedance__/common/utils/helpers/helper_function.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this package
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../controllers/student_detail_controller.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentModel student;
  final String classId;
  final studentDetailController = Get.put(StudentDetailController());

  StudentDetailScreen({
    super.key,
    required this.student,
    required this.classId,
  }) {
    print(
        'Initializing StudentDetailScreen with student: $student and classId: $classId');
    // Initialize controller with student and class data
    studentDetailController.setStudentAndClass(student, classId);
  }

  @override
  Widget build(BuildContext context) {
    print('Building StudentDetailScreen');
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: () {
              print('Refreshing student data');
              studentDetailController.loadStudentData();
            },
            icon: const Icon(Iconsax.refresh),
          ),
        ],
      ),
      body: Obx(() {
        print('StudentDetailController state updated');
        if (studentDetailController.isLoading.value) {
          print('Loading student data...');
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student profile card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Student image with edit option
                          GestureDetector(
                            onTap: () => _showImageOptions(context),
                            child: Stack(
                              children: [
                                // Student image or placeholder
                                Obx(() {
                                  final currentStudent = studentDetailController.student.value;
                                  final hasImage = currentStudent?.imageUrl != null && 
                                                  currentStudent!.imageUrl!.isNotEmpty;
                                  
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: dark ? TColors.darkerGrey : Colors.grey[200],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: dark ? TColors.yellow : TColors.deepPurple,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: hasImage
                                          ? CachedNetworkImage(
                                              imageUrl: currentStudent!.imageUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => 
                                                  const Center(child: CircularProgressIndicator()),
                                              errorWidget: (context, url, error) => 
                                                  Icon(
                                                    Iconsax.user,
                                                    size: 40,
                                                    color: dark ? TColors.yellow : TColors.deepPurple,
                                                  ),
                                            )
                                          : Icon(
                                              Iconsax.user,
                                              size: 40,
                                              color: dark ? TColors.yellow : TColors.deepPurple,
                                            ),
                                    ),
                                  );
                                }),
                                
                                // Edit icon overlay
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: dark ? TColors.yellow : TColors.deepPurple,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Iconsax.camera,
                                      size: 16,
                                      color: dark ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                                
                                // Loading indicator when uploading
                                if (studentDetailController.isImageUploading.value)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          
                          // Student info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentDetailController.student.value?.name ?? student.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: TSizes.xs),
                                Text(
                                  'Roll Number: ${studentDetailController.student.value?.rollNumber ?? student.rollNumber}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: TSizes.xs),
                                if (studentDetailController.classModel.value != null)
                                  Text(
                                    'Class: ${studentDetailController.classModel.value!.subjectName} - ${studentDetailController.classModel.value!.courseName} Semester ${studentDetailController.classModel.value!.semester}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Rest of the content remains the same...
              const SizedBox(height: TSizes.spaceBtwSections),

              // Attendance statistics
              Card(
                // ... existing attendance statistics card
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Attendance history
              Card(
                // ... existing attendance history card
              ),
            ],
          ),
        );
      }),
    );
  }

  // Method to show image options (take photo or choose from gallery)
  void _showImageOptions(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Student Photo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ListTile(
                leading: Icon(
                  Iconsax.camera,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                title: const Text('Take a Photo'),
                onTap: () {
                                Navigator.pop(context);
                  studentDetailController.pickImage(ImageSource.camera).then((_) {
                    if (studentDetailController.selectedImage.value != null) {
                      studentDetailController.updateStudentImage();
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(
                  Iconsax.gallery,
                  color: dark ? TColors.yellow : TColors.deepPurple,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  studentDetailController.pickImage(ImageSource.gallery).then((_) {
                    if (studentDetailController.selectedImage.value != null) {
                      studentDetailController.updateStudentImage();
                    }
                  });
                },
              ),
              if (studentDetailController.student.value?.imageUrl != null &&
                  studentDetailController.student.value!.imageUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Iconsax.trash,
                    color: Colors.red,
                  ),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    // Show confirmation dialog
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Remove Photo'),
                        content: const Text('Are you sure you want to remove this student\'s photo?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              // Update student with null image URL
                              studentDetailController.student.value = StudentModel(
                                id: studentDetailController.student.value!.id,
                                name: studentDetailController.student.value!.name,
                                rollNumber: studentDetailController.student.value!.rollNumber,
                                classId: studentDetailController.student.value!.classId,
                                imageUrl: null, // Remove image URL
                                createdAt: studentDetailController.student.value!.createdAt,
                                updatedAt: DateTime.now(),
                              );
                              // TODO: Implement method to remove image from storage and update DB
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: TSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? Colors.grey[800] : Colors.grey[200],
                    foregroundColor: dark ? Colors.white : Colors.black,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Other methods remain the same...
}
