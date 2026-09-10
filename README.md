# ☀️ Sunfire

Local-first manga reader and [Suwayomi](https://github.com/Suwayomi/Suwayomi-Server) client for **Android**, **iPhone**, and **iPad**. Built with Flutter and an embedded QuickJS scraper runtime.

**Current version:** `11.0.0-beta+32` · GitHub latest prior release: [v10.0.0-beta](https://github.com/just-for-death/sunfire/releases/tag/v10.0.0-beta)

[![Release](https://img.shields.io/github/v/release/just-for-death/sunfire?style=flat-square&color=FF5722)](https://github.com/just-for-death/sunfire/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-blue.svg?style=flat-square)](LICENSE)

---

## Highlights

- **Local-first**: Works offline with [Isar](https://isar.dev) and on-device [QuickJS](https://bellard.org/quickjs/) scrapers.
- **Suwayomi sync**: Bidirectional library, chapter progress, categories, history, and tracker progress when a server is reachable.
- **Offline queue**: Mark-read, bookmarks, library add/remove, category create/rename/delete/assign, and tracker progress replay when you come back online.
- **Android + iOS/iPad**: Phone bottom nav below 720px; tablet / iPad rail at ≥720px; manga detail two-pane at ≥840px. Volume keys turn pages on Android, iOS, and macOS.
- **FOSS extension icons**: Bundled letter-tile PNGs — no Google Favicon CDN.
- **Reader**: Long strip, long strip with gaps, paged LTR, paged RTL; zoom, crop, inverted taps, auto-scroll.
- **Anti-bot**: Optional [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) for Cloudflare-protected sources.

---

## Quick start

```bash
git clone https://github.com/just-for-death/sunfire.git
cd sunfire
flutter pub get
flutter run -d linux          # or an Android / iOS device
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols
```

On first launch, enter a Suwayomi URL (for example `http://192.168.1.100:4567`) or skip and use local JS sources only.

### F-Droid / IzzyOnDroid

- No Play Services Cronet / GMS. Android uses `dart:io` HTTP.
- `dependenciesInfo.includeInApk` is disabled (no encrypted Play dependency blob).
- Prefer the **arm64-v8a** split APK. Cleartext HTTP is limited to loopback / emulator (`localhost`, `127.0.0.1`, `10.0.2.2`). Use HTTPS for LAN Suwayomi IPs.

---

## Extension repository

Bundled scrapers: `assets/extensions/`  
Upstream: [`just-for-death/mangayomi-extensions`](https://github.com/just-for-death/mangayomi-extensions)

```
https://raw.githubusercontent.com/just-for-death/mangayomi-extensions/main/index.json
```

After editing a source, bump **both** the JS `mangayomiSources.version` and `index.json`, then:

```bash
scripts/sync_bundled_extensions.sh
```

---

## Tests

```bash
# Rebuild Linux debug once after flutter clean so QuickJS native .so exists
flutter build linux --debug
flutter test
```

Practical coverage includes a **dead-port (server off)** group and a **Docker Suwayomi on `:4567` (server on)** group: library pull, categories, sources, extensions, trackers, chapter push, thumbnails, bookmark mutation.

---

## Acknowledgments

[Suwayomi](https://github.com/Suwayomi) · [MangaYomi](https://github.com/kodjodevf/mangayomi) · [Tachiyomi](https://github.com/tachiyomiorg) / [Mihon](https://github.com/mihonapp/mihon) · [QuickJS](https://bellard.org/quickjs/) · [Isar](https://isar.dev) · [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)

---

## License

[Mozilla Public License 2.0](LICENSE)
