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
  Current version: <code>4.0.0+1</code> (Stable Release)
</p>

---

## Highlights

- **Local-first** — read offline. Library and reading state live in [Isar](https://isar.dev); scrapers run on-device via [QuickJS](https://bellard.org/quickjs/) — no cloud, no account needed.
- **Suwayomi sync** — bidirectional sync of library, categories, history, chapter progress, and tracker progress whenever a server is reachable.
- **Offline queue** — mark-read, bookmarks, library changes, category edits, and tracker-progress updates replay the moment you're back online.
- **Manga tracking** — track Western comics on [Metron.cloud](https://metron.cloud) directly, plus AniList / MyAnimeList / Kitsu tracking via your Suwayomi server. Auto-scrobble chapter reads back to your tracker.
- **Reader** — four reading modes (long strip, long strip with gaps, paged LTR, paged RTL), pinch/double-tap zoom, white-border cropping, color filters (invert / grayscale / amber / sepia), 3-zone tap navigation, volume-key page turns, and auto-scroll with speed presets.
- **Chapter transitions** — Mihon-style end-of-chapter card ("Finished:" / "Next:") with a full-width **Read Next Chapter** button and scanlator attribution.
- **Adaptive UI** — phone bottom nav (<720px), tablet/iPad navigation rail (≥720px), and a two-pane manga detail view (≥840px).
- **Reading stats** — daily streak, chapters read, total read time, overall progress, top genres, and source distribution.
- **Backup & restore** — JSON backups with configurable categories / chapters / history inclusion and optional scheduled backups.
- **Downloads** — per-chapter and batch downloads with a queue, pause/cancel, retry passes (Referer stripping, origin Referer, browser UA, curl fallback), and offline reading.
- **Anti-bot** — optional [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) support for Cloudflare-protected sources.
- **FOSS extension icons** — bundled letter-tile PNGs instead of the Google Favicon CDN.

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

## Screens & navigation

- **Library** — your manga with categories, sorting, and filtering.
- **Updates** — recent chapter feed from your sources and bundled scrapers.
- **History** — continue-reading list with last-read progress.
- **Browse** — extension sources and repositories: search, global search, category filters, and extension management.
- **More** — downloads queue, reading stats, trackers, and the full settings suite (server, library, downloads, reader, appearance, general, advanced, backup, extension repos).

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

On first launch, connect a Suwayomi server (`http://192.168.1.100:4567`, optionally with basic auth / bearer token), or skip it and run in **Standalone Mode** using the bundled local JS sources.

---

## Tracking

- **Metron.cloud (Western comics)** — configure an API token in *Settings → Manga Trackers*. Search series, link them to your library, and set status / volumes / chapters / reading lists. Auto-scrobble pushes chapter-read events back to Metron.
- **AniList / MyAnimeList / Kitsu** — enabled when a Suwayomi server is connected; progress syncs through the server's tracker integration.

---

## CI

- **Codemagic** (`codemagic.yaml`) — Android universal + split APKs and an unsigned iOS IPA for sideloading (AltStore / TrollStore / Sideloadly).

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
├── core/          # services: settings, sync engine, trackers, DB, storage
│   ├── db/        #   Isar models & repositories
│   ├── engine/    #   QuickJS runtime, JS scrapers, image transport
│   ├── metron/    #   Metron.cloud API client & models
│   ├── sync/      #   Suwayomi GraphQL, WebSocket, sync engine
│   ├── logging/   #   on-device diagnostic log with live stream
│   ├── services/  #   downloads, notifications, image cache, settings
│   └── theme/     #   light/dark/OLED themes, Material You
├── features/      # screens: reader, library, browse, manga detail, ...
└── main.dart
assets/
├── extensions/    # bundled JS sources
└── icons/         # launcher icons, source letter-tiles, logo
```

---

## Security notes

- Server connection is opted-in per host: custom TLS certificate validation only trusts the explicitly-configured server host (plus loopback) — no blanket LAN-range MITM allowance.
- The Metron tracking token is stored in platform secure storage (Keychain / Keystore), never in plaintext preferences.

---

## Contributing

- Open an [issue](https://github.com/just-for-death/sunfire/issues) for bugs or ideas.
- Fork, branch, and submit a PR. Prefer small, focused changes.
- When touching bundled sources in `assets/extensions/`, keep the extension repo index in sync.
- Run `flutter analyze` and the test suite before opening a PR.

---

## Acknowledgments

[Suwayomi](https://github.com/Suwayomi) · [MangaYomi](https://github.com/kodjodevf/mangayomi) · [Tachiyomi](https://github.com/tachiyomiorg) / [Mihon](https://github.com/mihonapp/mihon) · [QuickJS](https://bellard.org/quickjs/) · [Isar](https://isar.dev) · [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)

---

## License

[Mozilla Public License 2.0](LICENSE)