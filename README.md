<p align="center">
  <img src="assets/icons/sunfire_logo.png" alt="Sunfire" width="160">
</p>

<h1 align="center">☀️ Sunfire</h1>

<p align="center">
  Local-first manga reader and <a href="https://github.com/Suwayomi/Suwayomi-Server">Suwayomi</a> client, built with Flutter and an embedded QuickJS scraper runtime.
</p>

<p align="center">
  <a href="#"><img alt="Platform: Android" src="https://img.shields.io/badge/android-3DDC84?style=flat-square&logo=android&logoColor=white"></a>
  <a href="#"><img alt="Platform: iOS / iPadOS" src="https://img.shields.io/badge/iOS%20%2F%20iPadOS-000000?style=flat-square&logo=apple&logoColor=white"></a>
  <a href="#"><img alt="Platform: Linux" src="https://img.shields.io/badge/linux-FCC624?style=flat-square&logo=linux&logoColor=black"></a>
</p>

<p align="center">
  <a href="https://github.com/just-for-death/sunfire/releases"><img alt="Release" src="https://img.shields.io/github/v/release/just-for-death/sunfire?style=flat-square&color=FF5722"></a>
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white"></a>
  <a href="LICENSE"><img alt="License: MPL 2.0" src="https://img.shields.io/badge/License-MPL_2.0-blue.svg?style=flat-square"></a>
  <a href="https://github.com/just-for-death/sunfire/issues"><img alt="PRs / Issues" src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square"></a>
</p>

<p align="center">
  Current version: <code>1.0.0+1</code> (Stable Release)
</p>

---

## Highlights

- **Local-first** — read offline. Library and reading state live in [Isar](https://isar.dev); scrapers run on-device via [QuickJS](https://bellard.org/quickjs/) — no cloud, no account needed.
- **Suwayomi sync** — bidirectional sync of library, categories, history, chapter progress, and tracker progress whenever a server is reachable.
- **Offline queue** — mark-read, bookmarks, library changes, category edits, and tracker-progress updates replay the moment you're back online.
- **Adaptive UI** — phone bottom nav (<720px), tablet/iPad navigation rail (≥720px), and a two-pane manga detail view (≥840px). Volume keys turn pages on Android and iOS.
- **FOSS extension icons** — bundled letter-tile PNGs instead of the Google Favicon CDN.
- **Reader** — long-strip, long-strip-with-gaps, paged LTR, and paged RTL; pinch/double-tap zoom, crop, inverted taps, and auto-scroll.
- **Anti-bot** — optional [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) support for Cloudflare-protected sources.

---

## Supported platforms

| Platform | Status |
| --- | --- |
| Android | ✅ Primary target |
| iOS / iPadOS | ✅ |
| Linux (desktop) | ✅ local dev / testing |
| Web | ❌ Not supported (see note below) |

> Builds for **macOS / Windows** are not configured yet — PRs welcome.
>
> **Web**: not currently buildable — the app's Isar database and QuickJS
> runtime are native (`dart:ffi`) and have no web implementation.

---

## Getting started

### Prerequisites

- [Flutter 3.x](https://docs.flutter.dev/get-started/install) (the repo pins an FVM stable channel)
- For Linux desktop builds: standard GTK/Clang toolchain (`flutter doctor` will validate)
- For Android releases: Android SDK + signing keystore

### Run

```bash
git clone https://github.com/just-for-death/sunfire.git
cd sunfire
flutter pub get

flutter run -d linux                 # Linux desktop
flutter run -d <android-device>      # Android
flutter run -d <ios-device>          # iOS / iPad
```

### Release builds

```bash
# Android (split per ABI, obfuscated)
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols

# iOS
flutter build ipa
```

On first launch, enter a Suwayomi server URL (e.g. `http://192.168.1.100:4567`) or skip it and use the bundled local JS sources.

---

## Extension repository

Bundled scrapers live in `assets/extensions/`.
Upstream: [`just-for-death/mangayomi-extensions`](https://github.com/just-for-death/mangayomi-extensions)

Repository index:

```
https://raw.githubusercontent.com/just-for-death/mangayomi-extensions/main/index.json
```

To update bundled sources, bump **both** the JS `mangayomiSources.version` and `index.json`, then run:

```bash
scripts/sync_bundled_extensions.sh
```

---

## Tests

```bash
# Rebuild Linux debug once after `flutter clean` so the QuickJS native .so exists
flutter build linux --debug
flutter test
```

Coverage is practical and server-aware:

- **Server-off group** — dead-port behavior, offline queue replay.
- **Server-on group** — Docker Suwayomi on `:4567`: library pull, categories, sources, extensions, trackers, chapter push, thumbnails, and bookmark mutation.

---

## Project layout

```
lib/
├── core/          # services: settings, sync engine, tracker, storage
├── features/      # feature screens: reader, library, extensions, ...
└── main.dart
assets/
├── extensions/    # bundled JS sources
└── icons/         # launcher icons, source letter-tiles, logo
```

---

## Contributing

- Open an [issue](https://github.com/just-for-death/sunfire/issues) for bugs or ideas.
- Fork, branch, and submit a PR. Prefer small, focused changes.
- When touching bundled sources, follow the extension repo workflow above and keep `index.json` in sync.
- Run `flutter analyze` and the test suite before opening a PR.

---

## Acknowledgments

[Suwayomi](https://github.com/Suwayomi) · [MangaYomi](https://github.com/kodjodevf/mangayomi) · [Tachiyomi](https://github.com/tachiyomiorg) / [Mihon](https://github.com/mihonapp/mihon) · [QuickJS](https://bellard.org/quickjs/) · [Isar](https://isar.dev) · [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)

---

## License

[Mozilla Public License 2.0](LICENSE)