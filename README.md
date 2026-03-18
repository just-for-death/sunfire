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

### Key Flutter packages

| Package | Author | Purpose |
|---|---|---|
| [hooks_riverpod](https://pub.dev/packages/hooks_riverpod) | Remi Rousselet | State management |
| [go_router](https://pub.dev/packages/go_router) | Flutter team | Declarative routing |
| [flex_color_scheme](https://pub.dev/packages/flex_color_scheme) | Rydmike | Theming & Material You |
| [dynamic_color](https://pub.dev/packages/dynamic_color) | Material Foundation | Wallpaper colour extraction |
| [graphql_flutter](https://pub.dev/packages/graphql_flutter) | zino-app | GraphQL client |
| [graphql_codegen](https://pub.dev/packages/graphql_codegen) | Zino ApS | GraphQL code generation |
| [cached_network_image](https://pub.dev/packages/cached_network_image) | Baseflow | Manga cover & page caching |
| [freezed](https://pub.dev/packages/freezed) | Remi Rousselet | Immutable data models |
| [infinite_scroll_pagination](https://pub.dev/packages/infinite_scroll_pagination) | Edson Bueno | Paginated lists |
| [flutter_hooks](https://pub.dev/packages/flutter_hooks) | Remi Rousselet | React-style hooks |
| [scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list) | Google | Reader scroll control |
| [shimmer](https://pub.dev/packages/shimmer) | Hung HD | Loading placeholders |
| [hive](https://pub.dev/packages/hive) | Hive | Local key-value storage |
| [flutter_android_volume_keydown](https://github.com/DattatreyaReddy/flutter_android_volume_keydown) | DattatreyaReddy | Volume key page turning |
| [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) | Brian Egan & Brian Morrison | Icons |
| [flutter_markdown](https://pub.dev/packages/flutter_markdown) | Flutter team | Markdown rendering |
| [file_picker](https://pub.dev/packages/file_picker) | Miguel Ruivo | File import (extensions, backups) |
| [url_launcher](https://pub.dev/packages/url_launcher) | Flutter team | Open external links |
| [permission_handler](https://pub.dev/packages/permission_handler) | Baseflow | Storage & notification permissions |
| [network_info_plus](https://pub.dev/packages/network_info_plus) | Flutter Community | Local server discovery |
| [package_info_plus](https://pub.dev/packages/package_info_plus) | Flutter Community | App version info |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Flutter team | Persistent settings |
| [path_provider](https://pub.dev/packages/path_provider) | Flutter team | Filesystem paths |
| [web_socket_channel](https://pub.dev/packages/web_socket_channel) | Flutter team | Live download progress |

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
