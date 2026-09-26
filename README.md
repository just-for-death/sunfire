<p align="center">
  <img src="assets/icons/sunfire_logo.png" alt="Sunfire" width="160">
</p>

<h1 align="center">☀️ Sunfire</h1>

<p align="center">
  Local-first manga reader and <a href="https://github.com/Suwayomi/Suwayomi-Server">Suwayomi</a> client.
  Sources are scraped on-device by an embedded QuickJS runtime — your library never
  needs a cloud account to read.
</p>

<p align="center">
  <a href="https://github.com/just-for-death/sunfire/releases"><img alt="Release" src="https://img.shields.io/github/v/release/just-for-death/sunfire?style=flat-square&color=FF5722"></a>
  <a href="LICENSE"><img alt="License: MPL 2.0" src="https://img.shields.io/badge/License-MPL_2.0-blue.svg?style=flat-square"></a>
  <a href="CHANGELOG.md"><img alt="Changelog" src="https://img.shields.io/badge/changelog-4.0.0-9C27B0?style=flat-square"></a>
  <a href="PRIVACY.md"><img alt="Privacy: no telemetry" src="https://img.shields.io/badge/privacy-no%20telemetry-4CAF50?style=flat-square"></a>
  <a href="https://github.com/just-for-death/sunfire/issues"><img alt="Issues" src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square"></a>
</p>

<p align="center">
  <b>Android</b> · <b>iOS / iPadOS</b> · <b>Linux</b> &nbsp;|&nbsp; Current version <code>4.0.0+1</code>
</p>

---

## Why Sunfire

You already run a Suwayomi server. Sunfire is the reader in front of it that
doesn't add a second service to babysit.

- **No account, no cloud, no telemetry.** Connect to a server you control, or
  run fully standalone. See the [privacy policy](PRIVACY.md).
- **Sources are code, not a feature.** Scrapers are JavaScript fetched from a
  repo index and executed locally in QuickJS. Adding a source is adding a
  `.js` file to a repository — no app release required.
- **Offline is the default, not a fallback.** Library, history, and progress
  live in a local database. A queued mutation replays when you come back.
- **Privacy in the small stuff too.** Source icons are bundled FOSS assets.
  Sunfire never calls Google's favicon service, which would otherwise tell
  Google which sites you read.

---

## Features

**Reading**
- Four reading modes: long strip, long strip (gaps), paged LTR, paged RTL
- Pinch and double-tap zoom, white-border cropping
- Color filters: invert, grayscale, night amber, sepia
- 3-zone tap navigation, volume-key page turns, auto-scroll with speed presets
- Mihon-style end-of-chapter card with scanlator attribution and a full-width
  **Read Next Chapter** button
- Cross-chapter prefetch and download-ahead, both generation-guarded so a slow
  network can't apply a stale chapter's pages

**Library and sync**
- Bidirectional sync of library, categories, history, bookmarks, chapter
  progress, and tracker progress
- Offline mutation queue — mark-read, bookmarks, library changes, category
  edits, and tracker updates all replay on reconnect
- Incognito mode that suppresses history writes on *every* path, not just the
  reader
- Categories, sorting, filtering, unread badges, and global update intervals

**Sources**
- Two catalogs out of the box: the **Sunfire Official** catalog (9 maintained
  sources) and the **MangaYomi Community** catalog
- Add your own repo by URL; the index is cached, and a malformed response can
  never overwrite a good cache
- Optional [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) for
  Cloudflare-protected sites, using a named session per root domain so a solved
  browser context is reused instead of re-solving on every request

**Downloads**
- Per-chapter and whole-series batch download with a durable queue
- Pause, resume, cancel, and retry passes (Referer stripping, origin Referer,
  browser UA, curl fallback)
- CBZ compression, Wi-Fi and charging constraints
- Downloaded chapters are fully readable offline, including local-only
  entries that have no server ID

**Tracking**
- [Metron.cloud](https://metron.cloud) for Western comics, with automatic
  scrobbling on chapter read
- AniList, MyAnimeList, and Kitsu through your Suwayomi server

**Everything else**
- Reading statistics: daily streak, chapters read, time read, top genres,
  source distribution
- JSON backup and restore, with optional scheduled backups
- OPDS, SOCKS proxy, and scoped TLS trust
- On-device diagnostic log with a live viewer
- Material You dynamic color, light/dark/pure-black themes
- Phone bottom navigation, tablet navigation rail, two-pane detail view

---

## Screens

| Screen | What it's for |
| --- | --- |
| **Library** | Your manga, with categories, sorting, and unread counts |
| **Updates** | Recent chapter feed from your sources |
| **History** | Continue reading, with last-read position |
| **Browse** | Sources and repos: search, global search, filters, extension management |
| **Manga detail** | Chapters, trackers, downloads, two-pane on wide screens |
| **Reader** | The reading surface |
| **More** | Downloads, statistics, trackers, settings, and About |

---

## Getting started

### Option 1 — connect a server

On first launch, enter your Suwayomi host (for example `http://192.168.1.100:4567`).
Basic auth and bearer tokens are both supported. Sunfire pulls your library and
categories, and syncs from then on.

### Option 2 — standalone

Skip the server. Sunfire installs the extension catalogs on first run and works
entirely on-device with a local library.

---

## Install

Download a build from [GitHub Releases](https://github.com/just-for-death/sunfire/releases):

- **Android** — split-per-ABI APKs, plus a universal APK
- **iOS / iPadOS** — unsigned IPA for sideloading (AltStore, TrollStore, Sideloadly)

---

## Build from source

### Prerequisites

- [Flutter 3.x](https://docs.flutter.dev/get-started/install). The repo pins a
  stable channel via FVM.
- For Linux desktop: the standard GTK/Clang toolchain (`flutter doctor` will
  validate).
- For Android: Android SDK and a signing keystore.

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
# Android — split per ABI, obfuscated
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols

# iOS
flutter build ipa
```

---

## Platform support

| Platform | Status |
| --- | --- |
| Android | ✅ Primary target |
| iOS / iPadOS | ✅ |
| Linux (desktop) | ✅ |
| macOS / Windows | ❌ Not configured — PRs welcome |
| Web | ❌ Not buildable |

Web is blocked by architecture, not oversight: the Isar database and the
QuickJS runtime are both native (`dart:ffi`) and have no web implementation.
Linux builds are supported and are the easiest way to run the test suite.

---

## How extensions work

There is no bundled source tree. The flow is:

1. On first run, if nothing is installed, Sunfire fetches the official and
   community index files.
2. Each entry's `pkgPath` resolves against the repo root to a `.js` URL.
3. The source is downloaded, checked against a declared `sha256` when the repo
   publishes one, and written to the app documents directory under
   `extensions/`.
4. From then on the on-disk copy is the source of truth. Repo updates diff
   against the installed version, and an unattended update is refused unless
   the repo declares a `sha256` over HTTPS.

A few details worth knowing if you maintain a catalog:

- `lang` declares the **scraper's** language. A plural `langs` array is also
  accepted when it has exactly one entry; a genuinely multi-language list
  resolves to "all languages" so Browse's language filter can still offer it.
- An index response is validated before it is promoted to the cache. A
  captive-portal HTML page served with a 200 cannot replace a good index.
- The index is fetched with a cache-busting timestamp, so a newly published
  source is visible immediately rather than after a CDN expiry.

---

## Testing

```bash
# Build the Linux debug target once after `flutter clean` so the
# QuickJS native library exists.
flutter build linux --debug
flutter test
```

The suite is organized around the ways this app actually fails:

- **Offline and server-down** — dead-port behavior, queue replay, reachability
  classification.
- **Server-on** — library pull, categories, sources, extensions, trackers,
  chapter push, thumbnails.
- **Extensions** — live scraper execution against real sites, download
  simulation per source, repo update flow, index schema.
- **Regression pins** — tests written for a specific fixed bug, with the root
  cause documented in the file header. These fail if the bug returns, and they
  are the reason several subtle defects here were caught at all.
- **Incognito enforcement** — including a baseline-reproduction test that
  fails against the pre-fix code.

Some tests reach a live Suwayomi server on your LAN. They are the only tests
that need a reachable server; everything else runs offline.

---

## Project layout

```
lib/
├── main.dart
├── app.dart                 # router, theme, app shell wiring
├── core/
│   ├── backup/              # JSON backup + restore
│   ├── db/                  # Isar models and repositories
│   ├── engine/              # QuickJS runtime, repo manager, image transport
│   ├── logging/             # on-device diagnostic log with live stream
│   ├── metron/              # Metron.cloud client and models
│   ├── services/            # downloads, notifications, image cache, settings
│   ├── sync/                # Suwayomi GraphQL, WebSocket, sync engine
│   ├── theme/               # light / dark / OLED, Material You
│   └── widgets/             # shared widgets
└── features/
    ├── browse/  downloads/  history/  library/  manga_detail/
    ├── onboarding/  reader/  settings/  stats/  updates/
assets/
└── icons/                   # launcher icons, source letter-tiles, logo
```

---

## Security

- **Scoped TLS trust.** Custom certificate validation trusts only the
  explicitly configured server host, plus loopback. There is no blanket
  LAN-range allowance.
- **iOS ATS** exceptions are scoped to local networking only.
- **Secrets in secure storage.** Suwayomi credentials and tracker tokens go to
  the Android Keystore / iOS Keychain, never to plain preferences.
- **No plaintext secrets in the repository.** Keystores, `key.properties`,
  and signing material are gitignored.
- **Extension integrity.** Installed sources are verified against the repo's
  declared `sha256` when one is published, and unattended updates are refused
  for a source whose hash is missing or whose URL is not HTTPS.

Report a vulnerability through
[GitHub Security Advisories](https://github.com/just-for-death/sunfire/security/advisories/new)
rather than a public issue.

---

## Contributing

- Open an [issue](https://github.com/just-for-death/sunfire/issues) for bugs or
  ideas before starting anything large.
- Fork, branch, and submit a PR. Small, focused changes are much easier to
  review.
- Source scrapers live in the separate
  [mangayomi-extensions](https://github.com/just-for-death/mangayomi-extensions)
  repository, not in this one.
- Run `flutter analyze` and `flutter test` before opening a PR. Both are
  expected to be clean.

---

## Acknowledgments

[Suwayomi](https://github.com/Suwayomi) ·
[MangaYomi](https://github.com/kodjodevf/mangayomi) ·
[Tachiyomi](https://github.com/tachiyomiorg) /
[Mihon](https://github.com/mihonapp/mihon) ·
[QuickJS](https://bellard.org/quickjs/) ·
[Isar](https://isar.dev) ·
[FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)

Sunfire stands on the shoulders of all of these. The end-of-chapter reading
experience in particular follows Mihon's design closely.

---

## Changelog

Notable changes are recorded in [CHANGELOG.md](CHANGELOG.md), following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). The current
release is **4.0.0**, the first under the remote-extension architecture.

---

## License

[Sunfire](https://github.com/just-for-death/sunfire) is released under the
[Mozilla Public License 2.0](LICENSE).

The extension scrapers in
[mangayomi-extensions](https://github.com/just-for-death/mangayomi-extensions)
are a separate project with their own licensing.
