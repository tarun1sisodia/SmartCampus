# 🎓 SmartCampus - Attendance Management System

📌 **Live Project Overview (Design)** → [Canva Link](https://www.canva.com/design/DAGojAnLx0M/dpjM3UDwcl3N6ZpdzAaeYg/view?utm_content=DAGojAnLx0M&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h3436bd7f63)

---

## 📖 Project Overview

**SmartCampus** is a cross-platform web and mobile application designed to **digitize and streamline attendance tracking** in educational institutions.  

- **Admin**: Manages data, imports/exports, and analytics.  
- **Teacher**: Creates sessions, marks attendance using a carousel with student images, and uses a calendar feature.  

✅ Reduces manual work  
✅ Minimizes errors  
✅ Scales across institutions  
✅ Demonstrates **full-stack development**  

---

## ⚡ Tech Stack

- **Frontend**: Flutter (Dart, GetX, Material Design)  
- **Backend**: Supabase (Auth, DB, Storage)  
- **Database**: PostgreSQL  
- **Other Tools**: Git, VS Code, Android Studio  

---

## ✨ Key Features

1. **User Authentication** → Role-based access (JWT)  
2. **Class Management** → Courses, subjects, semesters, sections  
3. **Student Management** → Profiles, photos, roll numbers  
4. **Attendance Tracking** → Real-time marking with multiple statuses  
5. **Analytics & Reporting** → Comprehensive insights and performance metrics  
6. **User Interface** → Responsive, modern, theme-based  
7. **Data Management** → Import/export and backup  
8. **Multi-platform Support** → Mobile (Android/iOS) & Desktop (Linux/Windows/Mac)  
9. **Additional Features** → Multi-language support, real-time updates  

---

## 🎯 Objectives

- Digitize attendance processes  
- Enhance efficiency and data accuracy  
- Provide real-time analytics  
- Ensure secure authentication  
- Create a user-friendly UI  
- Support multiple languages  

---

## 🧩 Functional Modules

1. **Administrator Module** → Full control over users & data  
2. **Teacher Module** → Manages classes, sessions, and student attendance  
3. **Student Module** → Profiles, enrollment, and attendance records  
4. **Attendance Tracking Module** → Real-time, secure, session-based  
5. **Analytics Module** → Performance & attendance insights  
6. **Feedback Module** → Communication between users & admins  

---

## 🚀 Installation & Setup

### 🎯 Choose Your Setup Method

| Method | Time | Difficulty | Best For |
|--------|------|------------|----------|
| 🐳 **Docker** | 5 min | ⭐ Easy | Quick testing, deployment |
| 🤖 **Automated** | 10 min | ⭐⭐ Medium | Local development |
| 🔧 **Manual** | 15 min | ⭐⭐⭐ Advanced | Custom configurations |

📘 **New to Docker?** Check our [Quick Start Guide](./QUICKSTART.md)

---

### 🐳 Docker Setup (Recommended for quick start)

Deploy SmartCampus quickly using Docker - no manual Flutter installation needed!

1. **Setup environment file**
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

2. **Run with Docker Compose**
   ```bash
   docker-compose up -d smartcampus-web
   ```

3. **Access the application**
   
   Open browser at `http://localhost:8080`

📘 **For detailed Docker instructions, deployment options, and troubleshooting, see [DOCKER.md](./DOCKER.md)**

### 💻 Local Environment Setup

#### Automated Setup

**Windows**
Run the batch script to set up your environment automatically:
```cmd
setup_env.bat
```

**Linux / macOS**
Run the shell script to install dependencies and Flutter:
```bash
chmod +x setup_env.sh
./setup_env.sh
```

#### Manual Setup

If you prefer to set up manually or the scripts don't work for your OS:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/tarun1sisodia/smartcampus.git
   cd smartcampus
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   Create a file `lib/config.dart` and add your credentials:
   ```dart
   const String supabaseUrl = "YOUR_SUPABASE_URL";
   const String supabaseKey = "YOUR_SUPABASE_KEY";
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

### Node-Based Command Layer

This repository now includes a lightweight Node.js command runner so you can use `npm run ...` for Flutter and Android workflows from the project root.

1. **Use the pinned Node version**
   ```bash
   nvm use
   ```

2. **Verify the environment**
   ```bash
   npm run env:check
   npm run doctor
   ```

3. **Install Flutter dependencies**
   ```bash
   npm run deps
   ```

4. **Sync Android tooling**
   ```bash
   npm run android:sync
   ```

#### Common commands

```bash
# Development
npm run run
npm run run:android
npm run analyze
npm run test

# Android builds
npm run android:build           # release APK
npm run android:build:debug     # debug APK
npm run android:build:split     # split APKs by ABI
npm run android:bundle          # release AAB
npm run android:analyze-size

# Android / Gradle maintenance
npm run android:clean
npm run android:lint
npm run gradle:assemble:debug
npm run gradle:assemble:release
npm run gradle:bundle:release
npm run gradle:dependencies
npm run gradle:signing-report
```

#### Advanced usage

Use the pass-through commands when you want direct access to the underlying tools:

```bash
npm run flutter -- build apk --profile
npm run flutter -- pub outdated
npm run gradle -- app:assembleRelease --stacktrace
```

`npm run android:sync` runs `flutter pub get` and then the Android Gradle wrapper, which is the closest equivalent to a professional "sync project" command for this Flutter app.

#### Android signing setup

The release Gradle config already reads [android/key.properties](/home/shit/DFQ/SmartCampus/android/key.properties), so keep your real signing secrets there and keep the keystore file outside the repository.

1. Create the keystore:
   ```bash
   keytool -genkeypair -v \
     -keystore ~/secure/smartcampus-upload-keystore.jks \
     -keyalg RSA \
     -keysize 2048 \
     -validity 10000 \
     -alias upload
   ```

2. Create your local secrets file from [android/key.properties.example](/home/shit/DFQ/SmartCampus/android/key.properties.example):
   ```bash
   cp android/key.properties.example android/key.properties
   ```

3. Edit `android/key.properties` with your real values:
   ```properties
   storePassword=your-keystore-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=/home/your-user/secure/smartcampus-upload-keystore.jks
   ```

4. Build the signed app:
   ```bash
   npm run android:build
   npm run android:bundle
   ```

`android/key.properties` is ignored by git, and the template file stays committed so the setup is repeatable.

---

## 🧪 Testing

Run tests with:

```bash
flutter test
```

Testing includes:

* ✅ Unit Testing
* ✅ Integration Testing
* ✅ System & Regression Testing
* ✅ UI & Usability Testing
* ✅ Security & Compatibility Testing

---

## 📦 Release Process

1. Update `pubspec.yaml` version
2. Commit changes
3. Tag release:

   ```bash
   git tag vX.X.X
   git push origin vX.X.X
   ```
4. Create GitHub Release

---

## 🤝 Contributing

We ❤️ contributions!

### Steps:

1. **Fork the repository**
2. **Create a branch**

   ```bash
   git checkout -b feature/myFeature
   ```
3. **Commit your changes**

   ```bash
   git commit -m "Add: my new feature"
   ```
4. **Push the branch**

   ```bash
   git push origin feature/myFeature
   ```
5. **Open a Pull Request** 🎉

Please check `CONTRIBUTING.md` (coming soon) for detailed guidelines.

---

## 🔮 Future Scope

* Advanced biometric integration
* AI-powered analytics
* QR code & Geofencing attendance
* Parent/Guardian portal
* Blockchain verification
* LMS integration
* Gamification & Notifications
* Multi-institution support

---

## 🧑 Target Audience

* Educational institutions (schools, colleges, universities)
* Teachers & administrators
* Students & IT staff
* Parents/Guardians
* Education boards & regulatory bodies

---

## 🖥️ System Design

* **3-Tier Architecture**

  * Presentation: Flutter
  * Application: Supabase
  * Data: PostgreSQL

### Diagrams

* **Entity-Relationship Diagram (ERD)**
* **Data Flow Diagram (DFD)**

(*Add images/screenshots here if available*)

---

## 📸 Screenshots / Demo

(*Add screenshots or a demo video link here for better visualization*)

---

## 🛠️ System Requirements

**Software**

* Flutter SDK
* Dart
* Supabase Project
* VS Code / Android Studio

**Hardware**

* 4GB+ RAM
* Android/iOS device or emulator

---

## 🔒 Security

Please report security vulnerabilities by opening an issue or contacting maintainers via GitHub security advisories.

---

## 🧑‍💻 Contributors

Thanks to all contributors who help build SmartCampus 🚀

* [tarun1sisodia](https://github.com/tarun1sisodia)
* [tarun1kushwah](https://github.com/tarun1kushwah)
* [Dependabot](https://github.com/dependabot)

---

## 📜 License

This project is licensed under the **Apache-2.0 License**.

---

## 📚 References

* Flutter, GetX, Supabase Docs
* GetStorage, Cached Network Image, Iconsax packages
* Material Design Guidelines
* Tutorials on Supabase & Flutter

---
