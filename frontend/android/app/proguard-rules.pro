# Proguard rules for SmartCampus
#
# Keep release shrinking conservative until the first release build is
# validated through device testing and Play Console pre-launch checks.

# Flutter specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase related rules
-keep class com.supabase.** { *; }
-keep class io.supabase.** { *; }
-keep class com.google.crypto.tink.** { *; }
-keep class org.bouncycastle.** { *; }
-keep class io.github.jan.supabase.** { *; }

-keep class com.hivedb.** { *; }

# General Android rules
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# For native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters in Views so that animations can still work
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

# For enumeration classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable implementations
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Google Play Core Tasks / Deferred Components
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.assetpacks.** { *; }
-keep class com.google.android.play.core.common.** { *; }
-keep class com.google.android.play.core.review.** { *; }

# Dontwarn for Google Play Core classes that may not exist
-dontwarn com.google.android.play.core.**

# Keep Google Play Services Tasks (used by Play Core)
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.tasks.**

# Keep all interfaces and listeners
-keep interface com.google.android.play.core.** { *; }
-keep interface com.google.android.gms.tasks.** { *; }
