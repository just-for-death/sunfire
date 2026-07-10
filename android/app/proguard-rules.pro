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

# Android 12+ splash screen
-keep class androidx.core.splashscreen.** { *; }

# flutter_native_splash
-keep class net.jonhanson.flutter_native_splash.** { *; }

# app_links / deep linking
-keep class com.llfbandit.app_links.** { *; }

# volume key plugin
-keep class dev.darttools.flutter_android_volume_keydown.** { *; }

# cached_network_image / flutter_cache_manager
-keep class com.github.bluefireteam.** { *; }
-dontwarn com.github.bluefireteam.**

# wakelock
-keep class dev.fluttercommunity.plus.wakelock.** { *; }
