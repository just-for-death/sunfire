## Catalyst v5.0.0

### Highlights
- **Basic auth:** Credentials can be stored with the platform secure store (`flutter_secure_storage`), with a **SharedPreferences fallback** when the OS keyring is unavailable (e.g. Linux without unlocked libsecret).
- **iOS:** Main navigation shell uses **`ServerAwareWrapper`**, so the **offline server banner** matches Android (dismissible banner when the API is unreachable).
- **Linux:** Desktop (**GTK**) build target supported; CMake tweak for `flutter_secure_storage_linux` on strict Clang toolchains.
- **Navigation (phone):** Compact bottom bar with **overflow sheet** for extra destinations; **glass-style** iOS tab bar and iPad sidebar refinements.
- **Server:** Reachability checks, offline UI, and related settings/tests.

### Builds in this release
| Artifact | Notes |
|----------|--------|
| **Catalyst-5.0.0-unsigned.ipa** | **iOS** — from CI **xcarchive** (unsigned). Install via **AltStore**, **Sideloadly**, or similar-not from the App Store. |
| **app-arm64-v8a-release.apk** | **Android** — **arm64** (most phones/tablets). Per-ABI split build (same as Codemagic). |
| **app-armeabi-v7a-release.apk** | **Android** — **32-bit ARM** (older devices). |
| **app-x86_64-release.apk** | **Android** — **x86_64** (emulators and some tablets). |

Install the **one APK** that matches your device ABI (most users want **arm64**). Universal "fat" APK is not attached; build locally with `flutter build apk --release` if you need a single file.

**Version:** 5.0.0 (build **500** per `pubspec.yaml`).

### Upgrade notes
- If you used Basic auth stored only in SharedPreferences before, the app migrates into secure storage when possible.
- **iOS** sideloading: replace the previous IPA with this one; trust the developer profile as before.
- **Android:** sideload the matching APK or upgrade over the previous install if the signing key matches your build pipeline.
