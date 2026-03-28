# Proguard rules for SmartCampus

# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /path/to/android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools-proguard.html

# Flutter specific rules (usually handled by the engine, but good to have)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase and other dependencies
-keep class com.supabase.** { *; }
-keep class io.supabase.** { *; }

# Hive
-keep class com.hivedb.** { *; }

# GetX
-keep class com.getx.** { *; }
