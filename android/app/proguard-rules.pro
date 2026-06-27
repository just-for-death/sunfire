# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.catalyst.app.** { *; }

# Keep annotations / generics used by Gson, Retrofit-style plugins, and R8.
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Optional Play Core refs from Flutter deferred components (not bundled in release APK).
-dontwarn com.google.android.play.core.**

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Gson (used by several Android plugins)
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# OkHttp / networking
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Hive (graphql cache store)
-keep class hive.** { *; }
-keep class * extends hive.TypeAdapter { *; }

# Local notifications
-keep class com.dexterous.** { *; }
-keep class com.google.firebase.messaging.** { *; }

# dynamic_color / Material You
-keep class io.material.plugins.dynamic_color.** { *; }

# permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# path_provider / file access plugins
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
