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
</div>

---

## About

Catalyst is a Flutter frontend for [Suwayomi Server](https://github.com/Suwayomi/Suwayomi-Server) — a self-hosted manga server. It features a completely redesigned UI with Material You dynamic colour on Android and a native Cupertino glass UI on iOS/iPad.

> **Requires a running Suwayomi Server instance.** See the [Suwayomi Server setup guide](https://github.com/Suwayomi/Suwayomi-Server/wiki) to get started.

---

## Features

- **Material You** — Dynamic colour from your wallpaper on Android 12+
- **iOS & iPad UI** — Native Cupertino shell with frosted glass tab bar and sidebar on iPad
- **Redesigned screens** — Home, Library with filter chips, Explore, Feed (updates), Downloads
- **Full reader** — Continuous webtoon, single page, LTR/RTL with volume key support
- **Tracker support** — MyAnimeList, AniList, Kitsu, Bangumi, MangaUpdates, Shikimori
- **Adaptive icon** — Proper squircle/circle/teardrop on Android 8+
- **Offline reading** — Download chapters for local reading

---

## Download

Head to [**Releases**](https://github.com/just-for-death/catalyst/releases/latest) and grab the right file:

| File | Use for |
|---|---|
| `app-arm64-v8a-release.apk` | Most Android phones (2016+) |
| `app-armeabi-v7a-release.apk` | Older 32-bit Android |
| `app-x86_64-release.apk` | Android emulators |
| `Catalyst.ipa` | iPhone / iPad (sideload via AltStore or Sideloadly) |

---

## Building from source

**Requirements:** Flutter 3.x, Dart 3.x

```bash
git clone https://github.com/just-for-death/catalyst.git
cd catalyst
flutter pub get
flutter run                                    # debug on connected device
flutter build apk --release --split-per-abi   # release APKs
flutter build ipa --no-codesign               # unsigned IPA
```

---

## Acknowledgements

Catalyst stands on the shoulders of several great open-source projects. Huge thanks to everyone who built and maintains them.

### Foundation

| Project | Role |
|---|---|
| [**Tachidesk-Sorayomi**](https://github.com/Suwayomi/Tachidesk-Sorayomi) by [Suwayomi](https://github.com/Suwayomi) | The original Flutter client Catalyst is forked from. All core logic, GraphQL layer, reader, tracker integration, and data architecture come from this project. |
| [**Suwayomi-Server**](https://github.com/Suwayomi/Suwayomi-Server) by [Suwayomi](https://github.com/Suwayomi) | The self-hosted backend server Catalyst connects to. Handles sources, downloads, library management, and tracking sync. |

### UI Inspiration

| Project | Role |
|---|---|
| [**Futon**](https://github.com/AppFuton/Futon) by [AppFuton](https://github.com/AppFuton) | Inspired the Android UI redesign — the Home grouped cover grid, Explore pill-action layout, Feed date headers, Library filter chips, and bottom navigation structure are all modelled after Futon's Material design patterns. |
| [**Aidoku**](https://github.com/Aidoku/Aidoku) by [Aidoku](https://github.com/Aidoku) | Inspired the iOS/iPadOS UI — the Cupertino navigation shell, frosted glass tab bar, large-title app bars, iPad split-view sidebar, and glass card aesthetic are all modelled after Aidoku's native SwiftUI design. |



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
