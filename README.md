<div align="center">
  <img src="assets/icons/launcher/catalyst_icon.png" width="120" alt="Catalyst Icon"/>
  <h1>Catalyst</h1>
  <p>A fast, beautiful manga reader for <a href="https://github.com/Suwayomi/Suwayomi-Server">Suwayomi Server</a></p>

  <a href="https://github.com/just-for-death/catalyst/releases/latest">
    <img src="https://img.shields.io/github/v/release/just-for-death/catalyst?style=flat-square&color=7c3aed&label=Latest" alt="Latest Release"/>
  </a>
  <a href="https://github.com/just-for-death/catalyst/releases/latest">
    <img src="https://img.shields.io/github/downloads/just-for-death/catalyst/total?style=flat-square&color=06b6d4&label=Downloads" alt="Downloads"/>
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Android-5.0%2B-green?style=flat-square&logo=android" alt="Android"/>
  <img src="https://img.shields.io/badge/iOS-14%2B-black?style=flat-square&logo=apple" alt="iOS"/>
  <img src="https://img.shields.io/badge/Linux-GTK-lightgrey?style=flat-square&logo=linux" alt="Linux"/>
</div>

---

## About

Catalyst is a Flutter frontend for [Suwayomi Server](https://github.com/Suwayomi/Suwayomi-Server) — a self-hosted manga server. It features a completely redesigned UI with Material You dynamic colour on Android and a native Cupertino glass UI on iOS/iPad.

> **Requires a running Suwayomi Server instance.** See the [Suwayomi Server setup guide](https://github.com/Suwayomi/Suwayomi-Server/wiki) to get started.

---

## Features

### Reading & library
- **Full reader** — Continuous webtoon, single page, LTR/RTL, spread mode, volume key support
- **Redesigned screens** — History, Library with filter chips, Explore, Feed (updates), Downloads
- **Material You** — Dynamic colour from your wallpaper on Android 12+
- **iOS & iPad UI** — Cupertino shell with frosted glass tab bar and sidebar on iPad
- **Tracker support** — MyAnimeList, AniList, Kitsu, Bangumi, MangaUpdates, Shikimori

### Offline & server resilience
- **Device downloads** — Save chapters to local storage from the chapter list (phone/tablet icon)
- **Offline reading** — Open downloaded chapters from **Browse → Downloads → Offline** when the server is unreachable; progress is saved locally and syncs when back online
- **Server status** — Offline banner when the API is down; configurable request timeouts

### Other
- **Migration** — Move manga between sources with optional category, chapter, download, and tracker transfer
- **Adaptive icon** — Squircle/circle/teardrop on Android 8+
- **Linux desktop** — GTK build for development and testing

---

## Download

Head to [**Releases**](https://github.com/just-for-death/catalyst/releases/latest) and grab the right file:

| File | Use for |
|---|---|
| `app-arm64-v8a-release.apk` | **Most Android phones** (2016+, recommended) |
| `app-armeabi-v7a-release.apk` | Older 32-bit ARM Android |
| `app-x86_64-release.apk` | Android emulators / x86 tablets |
| `Catalyst-v6.0.0-unsigned.ipa` | **iPhone / iPad** — sideload via [AltStore](https://altstore.io/) or [Sideloadly](https://sideloadly.io/) (not App Store) |

Most users need **one** Android APK (`arm64`) plus the IPA if they use iOS.

---

## Quick start

1. Install and run [Suwayomi Server](https://github.com/Suwayomi/Suwayomi-Server) (Docker, JAR, or native).
2. Install Catalyst from [Releases](https://github.com/just-for-death/catalyst/releases/latest).
3. In Catalyst → **Settings → Server**, enter your server URL (e.g. `http://192.168.1.10:4567` or a Tailscale address).
4. Add extensions and manga through the server, then browse your library in Catalyst.

---

## Building from source

**Requirements:** Flutter 3.x (stable), Dart 3.x, JDK 17 for Android

```bash
git clone https://github.com/just-for-death/catalyst.git
cd catalyst
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # if you change @riverpod / GraphQL
flutter run                                                # debug on connected device
flutter build apk --release --split-per-abi                # release APKs (3 ABIs)
flutter build ipa --release --no-codesign                    # unsigned IPA (macOS + Xcode)
flutter run -d linux                                       # Linux desktop
```

Release Android builds use R8 minification. If Gradle fails at `minifyReleaseWithR8`, ensure `android/app/proguard-rules.pro` includes the Play Core `-dontwarn` rules shipped in this repo.

CI builds are defined in [`codemagic.yaml`](codemagic.yaml) (`ios-release`, `android-release`, and tag-triggered `all-release`).

---

## Acknowledgements

Catalyst stands on the shoulders of several great open-source projects. Huge thanks to everyone who built and maintains them.

### Foundation

| Project | Role |
|---|---|
| [**Tachidesk-Sorayomi**](https://github.com/Suwayomi/Tachidesk-Sorayomi) by [Suwayomi](https://github.com/Suwayomi) | The original Flutter client Catalyst is forked from. Core logic, GraphQL layer, reader, tracker integration, and data architecture come from this project. |
| [**Suwayomi-Server**](https://github.com/Suwayomi/Suwayomi-Server) by [Suwayomi](https://github.com/Suwayomi) | The self-hosted backend Catalyst connects to. Handles sources, downloads, library management, and tracking sync. |

### UI Inspiration

| Project | Role |
|---|---|
| [**Futon**](https://github.com/AppFuton/Futon) by [AppFuton](https://github.com/AppFuton) | Android UI patterns — Home grid, Explore layout, Feed headers, Library filter chips, bottom navigation. |
| [**Aidoku**](https://github.com/Aidoku/Aidoku) by [Aidoku](https://github.com/Aidoku) | iOS/iPadOS UI — Cupertino shell, glass tab bar, large titles, iPad sidebar. |

---

## Security notes

Catalyst talks to **your** Suwayomi server using a URL you configure.

- **HTTP on a trusted LAN** is common for self-hosted setups. If the server is reachable from untrusted networks, prefer **HTTPS** so traffic and Basic auth are not sent in the clear.
- **Basic authentication**: credentials are stored in the **OS secure store** (Keychain / Keystore) after migration from older preference storage.
- **Android**: cleartext HTTP and user-installed CAs are allowed for local/self-signed servers (`network_security_config.xml`).
- **iOS**: local network HTTP is allowed via App Transport Security (`NSAllowsLocalNetworking`).

---

## Contributing

Pull requests are welcome. For major changes please open an issue first.

1. Fork the repo
2. Create your branch: `git checkout -b feature/my-feature`
3. Commit: `git commit -m 'feat: add my feature'`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

---

## License

[MPL-2.0](LICENSE)

Catalyst is a derivative work of [Tachidesk-Sorayomi](https://github.com/Suwayomi/Tachidesk-Sorayomi), which is also licensed under [MPL-2.0](https://www.mozilla.org/en-US/MPL/2.0/). Per the terms of MPL-2.0, all modifications are made available under the same license.
