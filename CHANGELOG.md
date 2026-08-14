# Changelog

All notable changes to the **Catalyst** manga reader project will be documented in this file.

## [8.0.0] - 2026-08-14

### Added
- **Complete Mihon UI History Tab Overhaul**:
  - Redesigned History into a date-grouped feed (*Today*, *Yesterday*, *Recent*, etc.) matching Mihon.
  - New Mihon-inspired history list tiles featuring cover thumbnails, manga titles, chapter details, page progress indicators (`Page X/Y`), timestamps, and direct **Play / Resume** action buttons.
  - Integrated swipe-to-delete and adaptive removal confirmation for history items.
- **Navigation Restructure**:
  - Set **Library** as the default landing screen on app launch.
  - Moved **History** into the main top-level navigation tab.
- **Enhanced Downloading & Queue Support**:
  - Global `DownloadProgressBanner` for monitoring active downloads.
  - Full background downloading support so downloads continue when navigating away from manga details.

### Fixed
- **Status Bar & Header Overlap (iPad & LiveContainer)**:
  - Enforced `math.max(padding.top, 38.0)` top inset padding across shell app bars, eliminating status bar overlaps for LiveContainer IPA execution and iPad displays.
- **Codebase Quality**:
  - Verified `0` analyzer issues and `112/112` passing unit/widget tests.
