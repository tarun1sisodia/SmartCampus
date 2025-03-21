# Flutter App Build Guide

This guide provides commands and setup instructions for building and deploying Flutter apps for both Android and iOS platforms.

---

## Prerequisites
- **Flutter SDK** installed and configured
- **Android Studio** (for Android builds)
- **Xcode** (for iOS builds, macOS only)
- A physical device or emulator/simulator for testing

---

## Environment Setup

### Check Flutter Installation
```bash
flutter doctor
```
Fix any issues reported by the `flutter doctor` command before proceeding.

### Update Flutter
```bash
flutter upgrade
```

---

## Android Build Instructions

### Debug Build
#### Generate Debug APK
```bash
flutter build apk --debug
```
The debug APK will be located at: `build/app/outputs/flutter-apk/app-debug.apk`

#### Install Debug APK on Connected Device
```bash
flutter install
```

### Release Build
#### Generate Release APK
```bash
flutter build apk --release
```
The release APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

#### Generate Split APKs (Per Architecture)
```bash
flutter build apk --split-per-abi
```
This creates separate APKs for different CPU architectures (e.g., `arm64-v8a`, `armeabi-v7a`, `x86_64`), resulting in smaller APK sizes.

#### Generate App Bundle (Recommended for Play Store)
```bash
flutter build appbundle
```
The app bundle will be located at: `build/app/outputs/bundle/release/app-release.aab`

### Signing the Android App
1. **Create a keystore file**:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create a `key.properties` file** in the `android` directory:
   ```
   storePassword=<password from previous step>
   keyPassword=<password from previous step>
   keyAlias=upload
   storeFile=<location of the keystore file, e.g., /Users/username/upload-keystore.jks>
   ```

3. **Configure signing in `android/app/build.gradle`**:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

---

## iOS Build Instructions

### Setup
1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Configure signing in Xcode:
   - Select the **Runner** project in the left sidebar.
   - Select the **Runner** target.
   - Go to the **Signing & Capabilities** tab.
   - Select your team and update the bundle identifier if needed.

### Debug Build
```bash
flutter build ios --debug
```

### Release Build
```bash
flutter build ios --release
```

### Create IPA File
1. Build the app in Xcode:
   - Select **Product > Archive**.
   - Once archiving is complete, the Organizer window will appear.
   - Click **Distribute App**.
   - Choose the distribution method (e.g., Ad Hoc, App Store).
   - Follow the prompts to create the IPA.

2. **TestFlight Distribution**:
   - Create an app record in **App Store Connect**.
   - Archive your app in Xcode.
   - Select **App Store Connect** as the distribution method.
   - Upload the build.
   - Once processing is complete, add the build to TestFlight.

---

## Common Build Issues and Solutions

### Android Build Issues

#### Gradle Build Failures
- Update Gradle version in `android/gradle/wrapper/gradle-wrapper.properties`.
- Run `flutter clean` and try again.

#### Manifest Merge Issues
- Check for conflicting entries in `AndroidManifest.xml` files.
- Resolve conflicts using `tools:replace` attributes.

#### 64K Method Limit
1. Enable multidex in `android/app/build.gradle`:
   ```gradle
   defaultConfig {
       // ...existing code...
       multiDexEnabled true
   }
   ```

2. Add multidex dependency:
   ```gradle
   dependencies {
       implementation 'androidx.multidex:multidex:2.0.1'
   }
   ```

### iOS Build Issues

#### Signing Issues
- Ensure your Apple Developer account has the correct provisioning profiles.
- Update the team ID in Xcode project settings.

#### Pod Install Failures
- Run `cd ios && pod update` to update CocoaPods dependencies.
- Delete `Podfile.lock` and run `pod install` again.

#### Bitcode Compatibility
- If you encounter bitcode issues, disable bitcode in Xcode build settings.

---

## Performance Optimization

### Reduce APK Size
```bash
flutter build apk --release --target-platform=android-arm,android-arm64 --split-per-abi
```

### Analyze App Size
```bash
flutter build apk --analyze-size
```

### Enable Obfuscation
In `pubspec.yaml`:
```yaml
flutter:
  uses-material-design: true
  
  # Add this section
  obfuscate: true
  split-debug-info: /path/to/debug/symbols
```

---

## Continuous Integration

### GitHub Actions Example
Create `.github/workflows/build.yml`:
```yaml
name: Build and Release

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## Useful Commands

### Clean Build
```bash
flutter clean
```

### Run Flutter Analyzer
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Generate Native Splash Screen
1. Add dependency:
   ```bash
   flutter pub add flutter_native_splash
   ```

2. Configure in `pubspec.yaml`:
   ```yaml
   flutter_native_splash:
     color: "#ffffff"
     image: assets/splash.png
   ```

3. Generate:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

### Generate App Icons
1. Add dependency:
   ```bash
   flutter pub add flutter_launcher_icons
   ```

2. Configure in `pubspec.yaml`:
   ```yaml
   flutter_icons:
     android: "launcher_icon"
     ios: true
     image_path: "assets/icon/icon.png"
   ```

3. Generate:
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```