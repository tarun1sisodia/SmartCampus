import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Simple keystore properties loading
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.smartcampus.attendance"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.smartcampus.attendance"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists() && 
            keystoreProperties["keyAlias"] != null &&
            keystoreProperties["keyPassword"] != null &&
            keystoreProperties["storeFile"] != null &&
            keystoreProperties["storePassword"] != null) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                
                // Resolve relative to the root (android/) or explicitly to app/
                val storeFileName = keystoreProperties["storeFile"] as String
                storeFile = rootProject.file("app/$storeFileName")
                
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            if (keystorePropertiesFile.exists() && 
                keystoreProperties["keyAlias"] != null &&
                keystoreProperties["keyPassword"] != null &&
                keystoreProperties["storeFile"] != null &&
                keystoreProperties["storePassword"] != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

dependencies {
    // Flutter's Android embedding can reference Play Feature Delivery classes
    // during release shrinking. Use modern split Play Core artifacts.
    // Needed for com.google.android.play.core.tasks.* referenced by Flutter deferred components
    implementation("com.google.android.play:feature-delivery:2.1.0")
    implementation("com.google.android.play:feature-delivery-ktx:2.1.0")
    implementation("com.google.android.play:app-update:2.1.0")
    implementation("com.google.android.play:app-update-ktx:2.1.0")
    implementation("com.google.android.play:review:2.0.1")
    implementation("com.google.android.play:review-ktx:2.0.1")
    implementation("com.google.android.play:core-common:2.0.4")
    
    // Explicitly add Google Play Services Tasks to ensure com.google.android.play.core.tasks.* compatibility
    implementation("com.google.android.gms:play-services-tasks:18.2.0")
    implementation("com.google.android.gms:play-services-basement:18.5.0")
}

flutter {
    source = "../.."
}
