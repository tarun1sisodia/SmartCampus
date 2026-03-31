# Proguard rules for SmartCampus
#
# Keep release shrinking conservative until the first release build is
# validated through device testing and Play Console pre-launch checks.

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

-keep class com.supabase.** { *; }
-keep class io.supabase.** { *; }

-keep class com.hivedb.** { *; }

# Google Play Core Tasks / Deferred Components
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.assetpacks.** { *; }
-keep class com.google.android.play.core.common.** { *; }
-keep class com.google.android.play.core.review.** { *; }
