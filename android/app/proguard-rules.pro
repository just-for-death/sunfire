# Sunfire R8 rules (IMP-051, 2026-10-14). Referenced from android/app/build.gradle
# (release: proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro').
# Pruned stale rules for packages that are no longer dependencies (the old graphql
# cache store, permission handler, volume-keydown, cached-network-image, an old JS
# engine, dart jni, native splash). Each block below maps to a current plugin
# (see .flutter-plugins-dependencies).

# ── Flutter embedding + app ────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.sunfire.app.** { *; }
# Optional Play Core refs from Flutter deferred components (not bundled).
-dontwarn com.google.android.play.core.**

# Attributes needed by reflection users (Gson generics, annotations).
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# JNI: native methods must keep their names (R8 docs: keepclasseswithmembernames).
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# ── QuickJS (flutter_qjs): JNI callbacks from native code into Java ───────
-keep class soko.ekibun.flutter_qjs.** { *; }

# ── Isar (isar_community_flutter_libs): FFI library loader ────────────────
-keep class dev.isar.** { *; }

# ── ML Kit text recognition (google_mlkit_text_recognition / _commons) ────
# The plugin compiles against the CJK/Devanagari recognisers as compileOnly;
# they are not bundled, so R8 must not fail on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google_mlkit_text_recognition.** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }

# ── flutter_local_notifications: Gson + RuntimeTypeAdapterFactory (reflection) ─
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# ── workmanager: workers are instantiated by class name ───────────────────
-keep class dev.fluttercommunity.workmanager.** { *; }
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# ── flutter_foreground_task: service declared in the manifest ─────────────
-keep class com.pravera.flutter_foreground_task.** { *; }

# ── flutter_tts / volume_controller ───────────────────────────────────────
-keep class com.eyedeadevelopment.fluttertts.** { *; }
-keep class com.kurenai7968.volume_controller.** { *; }

# ── Other plugins kept as before ──────────────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class io.material.plugins.dynamic_color.** { *; }
-keep class com.llfbandit.app_links.** { *; }
-keep class dev.fluttercommunity.plus.** { *; }
-keep class androidx.core.splashscreen.** { *; }

# ── OkHttp / TLS providers referenced optionally by networking libs ───────
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
