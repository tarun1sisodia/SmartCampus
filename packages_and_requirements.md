# 📋 SmartCampus: Dependency & Requirements Guide (2026)

This guide provides a comprehensive audit of the SmartCampus tech stack as of **March 2026**. It covers minimum requirements for Flutter, Android, and iOS, a full package health check, and a strategy for handling future updates.

---

## 🏗️ 1. The 2026 "Gold Standard" Stack (Android & iOS)

To ensure the app remains performant and eligible for the Play Store and App Store, your development environment should follow these baseline specifications:

### 🤖 Android Requirements
*   **Flutter SDK**: 3.41.x (Stable)
*   **Java SDK**: 17 (Required for AGP 8.x+)
*   **Android Gradle Plugin (AGP)**: **8.12.0**
    > [!NOTE]
    > SmartCampus is updated to **AGP 8.12.0**. This matches the modern Android toolchain and supports **Android API 36**.
*   **Gradle**: **8.13**
    > [!NOTE]
    > SmartCampus uses **Gradle 8.13** to match AGP 8.12.0 compatibility requirements.
*   **Kotlin**: 1.9.24 or 2.1.0 (recommended)
*   **Target SDK**: **36**
*   **Compile SDK**: **36**
*   **NDK**: **30.0.14904198** (or newer r28+)

### 🍎 iOS Requirements
*   **Xcode**: 17.x
*   **Deployment Target**: iOS 13.0 (Minimum), iOS 18 (Target)
*   **Dependency Manager**: Swift Package Manager (SPM)
    > [!TIP]
    > **SPM over CocoaPods**: Flutter is aggressively moving toward Swift Package Manager. For new plugins or updates, prioritize SPM to avoid "CocoaPods out of date" errors.
*   **Lifecycle**: `UIScene` (Now the standard over older `AppDelegate` methods).

---

## 📊 2. Dependency Health Audit

| Package | Current | Latest (Stable) | Requirements / Notes |
| :--- | :--- | :--- | :--- |
| `supabase_flutter` | `^2.10.3` | `2.12.0` | **Min Flutter 3.19.** Fixes various auth edge cases. |
| `get` | `^4.7.2` | `4.7.3` | **Stable.** Use 4.7.3 for better compatibility with Dart 3.x. |
| `share_plus` | `^12.0.1` | `12.1.2` | **iOS 18 Fixes.** Highly recommended for sharing features. |
| `image_picker` | `^1.2.1` | `1.3.0` | **Android 14+ permissions.** Matches Scoped Storage requirements. |
| `intl` | `^0.20.2` | `0.21.0` | **Dart 3.x Optimized.** Essential for localization logic. |
| `cached_network_image`| `^3.4.1` | `3.5.0` | **Engine Fixes.** Better performance on Flutter 3.41. |
| `local_auth` | `^3.0.0` | `3.1.5` | **Security.** Includes modern biometric API calls for Android 15. |
| `sqflite` | `^2.4.2` | `2.5.0` | **Sqlite 3.4x.** Improved transaction stability. |

---

## 🔄 3. Strategic Upgrade Protocol

When updating packages that introduce errors, follow this **"Safety-First"** protocol:

### Step 1: The Batch Upgrade
Run upgrades in functional groups (e.g., all Auth packages, then all UI packages) rather than all at once.
```bash
flutter pub upgrade --major-versions
```

### Step 2: Resolving "Dependency Hell"
If two packages require different versions of the same dependency (e.g., `crypto`), use a `dependency_override` temporarily:
```yaml
dependency_overrides:
  crypto: ^3.0.7
```

### Step 3: Handling Abandoned Packages
If a package (like many community UI libraries) hasn't been updated in 12+ months and causes compile errors:
1.  **Check Forks**: Look at the "Forks" tab on GitHub for a version updated to the latest Flutter SDK.
2.  **Use Git Points**: Source the package directly from a stable git commit if the pub version is broken.

### Step 4: Edge Case Logic
*   **WASM Compatibility**: If you plan to deploy to Web, ensure all packages support the new **Dart-to-WASM** compiler.
*   **Impeller Fixes**: If you see UI flickers, check package issues for "Impeller rendering" compatibility.

---

## 🛡️ 4. Future-Proofing Strategy
1.  **Strict Linting**: Use `flutter_lints` (currently 5.0.0) to catch deprecated API usage *before* you upgrade the SDK.
2.  **Selective Pinning**: Avoid `dependency: any`. Always use the caret (`^`) or exact versioning for critical storage packages like `sqflite` or `hive` to prevent data migration issues.
3.  **Regular Audits**: Run `flutter pub outdated` once a month to stay ahead of security patches.

---

⚡ *Document Prepared for SmartCampus Development Team*

---

## Android Version Lock For This Repo

Use this exact Android toolchain unless there is a deliberate upgrade task:

| Component | Locked Version | Source File |
| :--- | :--- | :--- |
| AGP | `8.12.0` | `android/settings.gradle.kts` |
| Gradle Wrapper | `8.13` | `android/gradle/wrapper/gradle-wrapper.properties` |
| Kotlin | `2.1.0` | `android/settings.gradle.kts` |
| Java | `17` | Android Studio Gradle JDK |
| Compile SDK | `36` | `android/app/build.gradle.kts` |
| Target SDK | `36` | `android/app/build.gradle.kts` |
| NDK | `30.0.14904198` | `android/app/build.gradle.kts` |

### Android Studio Setup

1. Open the project root folder, not just the Android module:
   `/home/shit/DFQ/SmartCampus`
2. Set **Gradle JDK** to **Java 17**.
3. In **SDK Manager**, install:
   * Android SDK Platform 36
   * Android SDK Build-Tools 35.0.0 or newer
   * NDK (Side by side) `30.0.14904198` or newer
   * Android SDK Command-line Tools (latest)
4. Sync the project.
5. Build with:
   `flutter build appbundle --release`
