# ☀️ Sunfire

A blazing-fast, local-first manga reader and [Suwayomi](https://github.com/Suwayomi/Suwayomi-Server) client built with Flutter and embedded QuickJS.

[![Release](https://img.shields.io/github/v/release/just-for-death/sunfire?style=flat-square&color=FF5722)](https://github.com/just-for-death/sunfire/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-blue.svg?style=flat-square)](LICENSE)

---

## ⚡ Highlights

- **Local-First Architecture**: Operates 100% offline using embedded [Isar](https://isar.dev) NoSQL database and on-device [QuickJS](https://bellard.org/quickjs/) JavaScript scrapers.
- **Suwayomi Server Sync**: Connects seamlessly with Suwayomi server when online for bidirectional library, reading history, and tracker synchronization.
- **Universal Extension Repos**: Dynamically add and update third-party MangaYomi-compatible JS extension repositories without hardcoded constraints.
- **Advanced Reader**: Continuous Webtoon (vertical), Paged LTR, and Paged RTL with smooth zoom, dual-page mode, and automatic cross-source failover/recovery.
- **Anti-Bot Resilience**: Intelligent FlareSolverr integration for seamless scraping past Cloudflare challenges.
- **AMOLED Dark Theme**: Pure obsidian theme with dynamic accent color customization.

---

## 🚀 Quick Start

### Build & Run

```bash
# Clone the repository
git clone https://github.com/just-for-death/sunfire.git
cd sunfire

# Get dependencies
flutter pub get

# Run on Linux Desktop
flutter run -d linux

# Build Release APK
flutter build apk --release --split-per-abi
```

### Server Setup (Optional)
On initial launch, enter your [Suwayomi Server](https://github.com/Suwayomi/Suwayomi-Server) address (e.g., `http://192.168.1.100:4567`) to hydrate your library, or use Sunfire standalone with local JS scrapers.

---

## 🤝 Acknowledgments

Sunfire is built on the shoulders of giants in the open-source manga community:

- **[Suwayomi](https://github.com/Suwayomi)** — The self-hosted manga server ecosystem and GraphQL API.
- **[MangaYomi](https://github.com/kodjodevf/mangayomi)** — The modular cross-platform JavaScript extension scraper standard and runtime architecture.
- **[Tachiyomi](https://github.com/tachiyomiorg) & [Mihon](https://github.com/mihonapp/mihon)** — The foundational pioneers and design inspiration for modern manga readers.
- **[QuickJS](https://bellard.org/quickjs/)** (Fabrice Bellard & Charlie Gordon) — The compact, ultra-fast embedded JavaScript engine.
- **[Isar Database](https://isar.dev)** — The blazingly fast embedded NoSQL database for Flutter.
- **[FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)** — The open-source proxy solution for anti-bot bypass.

---

## 📄 License

Sunfire is licensed under the [Mozilla Public License 2.0 (MPL-2.0)](LICENSE).
