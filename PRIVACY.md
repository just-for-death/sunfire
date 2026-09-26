# Privacy Policy

**Sunfire does not collect, transmit, sell, or share your personal data.**

There is no account system, no telemetry, no crash reporting service, and no
advertising SDK in this app. This document describes exactly what leaves your
device and why.

_Last reviewed for release 4.0.0._

---

## What Sunfire stores on your device

Everything Sunfire knows lives in local storage on the device you installed it
on:

| Data | Where it lives |
| --- | --- |
| Library, categories, history, reading progress | [Isar](https://isar.dev) database in the app's private documents directory |
| Downloaded chapters | App documents directory, as image or CBZ files |
| Settings and preferences | Local preferences store |
| Extension source code | App documents directory, under `extensions/` |
| Diagnostic logs | `logs/sunfire_diagnostic.log` in the app documents directory |

None of this is readable by other apps. On Android and iOS it sits in
application-private storage.

## Credentials

Two kinds of secret are stored, and both are handled differently:

- **Suwayomi server credentials** (password or bearer token) — stored in
  platform secure storage (Android Keystore / iOS Keychain), not in plain
  preferences.
- **Manga tracker tokens** (Metron.cloud, AniList, MyAnimeList, Kitsu) — stored
  in platform secure storage.

Secure storage is provided by the operating system. Sunfire never transmits a
credential anywhere except to the service it authenticates against.

## Network requests Sunfire makes

Sunfire talks to exactly three kinds of destination, and every one of them is
something you configured or chose:

1. **Your Suwayomi/Tachidesk server.** The host you enter during onboarding.
   Used for library sync, source browsing, downloads, backup, and tracker
   progress.
2. **Manga sites, via extension sources.** Sunfire runs scrapers locally in an
   embedded QuickJS runtime. Requests go from your device to the manga site
   being browsed, using that site's scraper. Sunfire has no proxy in the middle.
3. **Extension repositories.** The extension index you add (by default the
   Sunfire official catalog and the MangaYomi community catalog) is fetched so
   scrapers can be installed and updated. The index host sees a normal HTTPS
   request from your device.

If you configure a [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)
instance — which is optional and off by default — Cloudflare-protected page
loads are relayed through **your** FlareSolverr host. That host is under your
control and is not contacted otherwise.

## What Sunfire never does

- No analytics, telemetry, or usage tracking of any kind.
- No crash reporting to a third party.
- No advertising or profiling SDKs.
- No Google Favicon service calls. Source icons are bundled FOSS assets or
  served by the extension repository you configured — see
  `SourceIconHelper`. This is a deliberate privacy choice: the common shortcut
  of fetching `<site>/favicon.ico` from Google's CDN would tell Google which
  sites you read.
- No background upload of your library, history, or downloads.

## Incognito mode

*Settings → General → Incognito Mode* pauses recording of reading history and
progress. While it is on, chapter-read events are not written to the local
database and are not pushed to your server or to trackers. Progress you
accumulated before enabling it is left untouched — the mode stops new writes,
it does not delete old ones.

## Third-party services

Sunfire can talk to third-party services, but only when you explicitly
configure them:

- **Manga tracker APIs** (Metron.cloud, AniList, MyAnimeList, Kitsu) — see the
  trackers' own privacy policies.
- **Suwayomi server** — see the policies of whoever operates it.
- **Manga sites** — see the policies of the sites you browse.

## Children

Sunfire is not directed at children and collects no data from anyone,
including children.

## Changes to this policy

Material changes will be listed in the [changelog](CHANGELOG.md) and the
version number in *Settings → About* will reflect the release. Because there is
no telemetry, we cannot notify you proactively — check the repository if this
matters to you.

## Questions

Open an issue at
[github.com/just-for-death/sunfire](https://github.com/just-for-death/sunfire/issues).
