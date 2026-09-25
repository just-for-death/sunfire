# Sunfire UI/UX Improvement Plan
**Version:** 1.0 | **Based on:** v3.0.0 codebase audit | **Scope:** Fonts, Pills, Icons, Components, Accessibility, Motion

---

## 🎯 Executive Summary

Sunfire has a coherent dark-first design (OLED black + glassmorphism) with responsive breakpoints and a settings-driven theming system. The plan targets **consistency, polish, accessibility, and developer experience** — not a redesign.

**Core Philosophy:** *Evolution, not revolution. Every change must be measurable, testable, and rollbackable.*

---

## 🚨 Phase -1: Critical Bug Fixes (Do First — Before Any Polish)

*Reader & Updates are the core UX surfaces. These bugs cause data loss, state corruption, and broken UX. Fix before any UI polish.*

### -1.1 Reader — Critical Data Loss / Corruption

| # | Bug | File:Line | Fix |
|---|-----|-----------|-----|
| R1 | **Self-healing scrape uses manga title → wrong chapter list** | `reader_screen.dart:1082-1114` | Pass manga URL to resolver; match by URL not title |
| R2 | **Image cache evicts on-screen images** | `reader_screen.dart:631-647` | Never evict `currentPage ± 2` URLs |
| R3 | **Auto-scroll resume flag chapter-agnostic** | `reader_screen.dart:1212-1217` | `Map<int,bool> _resumeAutoScrollForChapter` |
| R4 | **Volume key recentre triggered by lifecycle** | `reader_screen.dart:153-168, 177-187` | Generation token for recentre source |
| R5 | **Prefetch consumed before generation guard** | `reader_screen.dart:1254, 1307-1319` | Store `generation` with prefetch; check on read |
| R6 | **ContentResolver no overall timeout** | `content_resolver_service.dart:193-235` | `Future.any([local, server])` with 15s timeout |
| R6b | **ImageStreamListener no timeout** | `reader_screen.dart:631-647` | Wrap in `Future.any([listener, 10s timeout])` |
| R7 | **Download-ahead uses stale siblings** | `reader_screen.dart:1282-1302` | Check `_loadGeneration` before enqueue |
| R8 | **Prefetch cache unbounded** | `reader_screen.dart:1307-1319` | Max 3 chapters; clear on chapter load |
| R9 | **Curl concurrency unlimited** | `reader_screen.dart:2201`, `safe_curl.dart` | Semaphore (max 2 concurrent) |
| R10 | **Incognito mode incomplete** | `reader_screen.dart:1446` | Block download-ahead, prefetch, WS, scrobble, history |
| R11 | **Lifecycle detached unhandled** | `reader_screen.dart:147-171` | Handle `AppLifecycleState.detached` |
| R12 | **Scroll indicator timer churn** | `reader_screen.dart:1360-1368` | Debounce or single timer with `reset()` |
| R13 | **Double-tap zoom global var** | `reader_screen.dart:185-195` | Instance variable |
| R14 | **Prefetch desktop-only** | `reader_screen.dart:2294-2303` | Enable on mobile (2 pages) |

### -1.2 Updates — Critical Data Loss / Corruption

| # | Bug | File:Line | Fix |
|---|-----|-----------|-----|
| U1 | **Local list clobbered by stale server data** | `updates_screen.dart:121-128, 162-180` | Merge server into local; preserve local-only + pending mutations |
| U2 | **Bulk mark-read no rollback on failure** | `updates_screen.dart:469-553` | `Future.wait` all syncs; rollback all on any failure; adjust unread after success |
| U3 | **Single toggle no rollback** | `updates_screen.dart:400-431` | Track pending mutation; rollback on sync failure + error SnackBar |
| U4 | **Flood detection inconsistent** | `updates_screen.dart:181-204, 303-319` | Apply same flood detection to local cache load |
| U5 | **Pull-to-refresh too heavy** | `updates_screen.dart:191-198` | Background refresh only; pull-to-refresh reloads local only |
| U6 | **Tab reload wasteful** | `updates_screen.dart:63-66` | Reload only if stale (>5min) or manual |
| U7 | **Language filter hides unknown** | `updates_screen.dart:75-81` | Include empty lang unless explicitly filtered |
| U8 | **Search no debounce** | `updates_screen.dart:1036-1050` | Debounce 300ms |
| U9 | **Clear feed UX poor** | `updates_screen.dart:1150-1170` | Show count, add undo SnackBar, background execution |
| U10 | **Language badge filtering** | `updates_screen.dart:75-81` | Include unknown lang unless explicitly filtered |

### -1.3 Sync/WS/Backend — Critical Data Loss / Corruption

| # | Bug | File:Line | Fix |
|---|-----|-----------|-----|
| S1 | **mergeLastPageRead rewinds progress on server unread** | `sync_engine.dart:98` | Only take server page if `server > local` |
| S2 | **Full chapter snapshot every sync (no incremental)** | `sync_engine.dart:1030-1177` | Add `lastChapterSyncTimestamp` per manga; fetch only `fetchedAt > lastSync` |
| S3 | **Chapter sync no wipe guard** | `sync_engine.dart:1030-1177` | Skip update if server returns 0 chapters for manga with local chapters |
| S4 | **WS auth token expires → infinite reconnect loop** | `websocket_service.dart:39-78, 97-101` | Add `authRefresher` callback; call before reconnect |
| S5 | **WS duplicate subscriptions on reconnect** | `websocket_service.dart:194-213, 215-235` | Send `unsubscribe` for IDs '1','2' before reconnect |
| S6 | **syncChapterProgress direct success doesn't update lastReadAt** | `sync_engine.dart:206` | Update local chapter `lastReadAt` on direct HTTP success |
| S7 | **LibraryUpdateService race: UI reads before sync completes** | `library_update_service.dart:185` | `triggerSync` returns `Future`; await before returning count |
| S8 | **Local scrape duplicates server work** | `library_update_service.dart:188-270` | Skip local scrape for manga already synced by server |
| S9 | **Error swallowing** | Multiple | Use `LoggerService` consistently; show user-facing SnackBar for actionable errors |
| S10 | **Transient error string matching** | `sync_engine.dart:36-48` | Use structured error types from GraphQL client |

### -1.4 Settings — Real-Time Reactivity

| # | Bug | File:Line | Fix |
|---|-----|-----------|-----|
| ST1 | **SettingsService no ChangeNotifier** | `settings_service.dart` | Extend `ChangeNotifier`; `notifyListeners()` on every setter; `ListenableBuilder` in Reader/Updates |

### -1.5 Error Handling — Visibility

| # | Bug | File:Line | Fix |
|---|-----|-----------|-----|
| EH1 | **Silent failures everywhere** | Multiple | Use `LoggerService` consistently; show user-facing SnackBar with retry for actionable errors |

---

## 📋 Phase 0: Foundation (Do First)

### 0.1 Design Token System
**Problem:** Spacing, radius, elevation, blur values scattered inline (8 files).
**Solution:** Create `lib/src/core/theme/design_tokens.dart`

```dart
class DesignTokens {
  // Spacing scale (4dp base)
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20, s24 = 24, s32 = 32;

  // Border radius
  static const double r8 = 8, r10 = 10, r12 = 12, r14 = 14, r16 = 16, r20 = 20, r24 = 24, r32 = 32;

  // Elevation
  static const double e0 = 0, e05 = 0.5, e8 = 8, e24 = 24, e30 = 30;

  // Blur
  static const double blurGlass = 28, blurSheet = 30;

  // Animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 400);

  // Curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
}
```

**Migration:** Replace all inline constants across 95 files. Add `analysis_options.yaml` rule to flag inline constants.

### 0.2 Typography Scale
**Problem:** Font sizes hardcoded in 200+ places; no semantic text styles.
**Solution:** Extend `TextTheme` with semantic roles in `app_theme.dart`

```dart
extension SunfireTextStyles on TextTheme {
  TextStyle get hero => displayLarge?.copyWith(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -0.5) ?? const TextStyle();
  TextStyle get sectionTitle => labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2) ?? const TextStyle();
  TextStyle get cardTitle => titleMedium?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600) ?? const TextStyle();
  TextStyle get cardSubtitle => bodySmall?.copyWith(fontSize: 12, color: Colors.white70) ?? const TextStyle();
  TextStyle get badgeCompact => labelSmall?.copyWith(fontSize: 10.5, fontWeight: FontWeight.bold) ?? const TextStyle();
  TextStyle get badgeChip => labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500) ?? const TextStyle();
  TextStyle get readerChapter => titleSmall?.copyWith(fontSize: 13.5, fontWeight: FontWeight.bold) ?? const TextStyle();
  TextStyle get readerProgress => bodySmall?.copyWith(fontSize: 11.5) ?? const TextStyle();
}
```

**Migration:** Replace all `TextStyle(...)` constructions with semantic references.

---

## 🎨 Phase 1: Component Standardization

### 1.1 Pill System (Unified API)
**Current State:** `SunfireBadge` (compact/chip), `FilterChip`, `ChoiceChip`, `ActionChip`, `InputChip` used inconsistently across 40+ files.

**Unified API:** `lib/src/core/widgets/sunfire_pill.dart`

```dart
enum SunfirePillVariant { status, filter, action, input, genre, server }

class SunfirePill extends StatelessWidget {
  final SunfirePillVariant variant;
  final String label;
  final IconData? leadingIcon;
  final Widget? trailing;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final Color? customColor;

  // Semantic mapping:
  // - status: compact badge (unread, downloading, new)
  // - filter: toggleable (status, display mode)
  // - action: button-like (Add Source, Sync)
  // - input: removable (selected languages, categories)
  // - genre: metadata display (non-interactive)
  // - server: scope indicator (server/local/proxy)
}
```

**Color Semantics (per variant):**
| Variant | Default | Selected | Disabled |
|---------|---------|----------|----------|
| status | accent 12% bg + accent border | — | 30% opacity |
| filter | surface 12% + border | accent 25% + accent border | 30% opacity |
| action | accent bg + white text | — | 40% opacity |
| input | surface 12% + border | — | 30% opacity |
| genre | grey 12% + grey border | — | 30% opacity |
| server | semantic (teal/purple/amber) 15% | — | — |

**Migration:** Replace all `FilterChip`/`ChoiceChip`/`SunfireBadge` with `SunfirePill(variant: ...)`.

### 1.2 Card System
**Current State:** Inline `Container` with `Color(0x1F2A2A32)` bg, `borderRadius: 14/16`, subtle border — 40+ variants.

**Unified Cards:**
```dart
class SunfireCard extends StatelessWidget {
  enum Elevation { flat, raised, glass }  // flat=0, raised=e8, glass=frosted
  enum Radius { tight=8, standard=14, loose=16, sheet=20, modal=24 }

  final Elevation elevation;
  final Radius radius;
  final EdgeInsets padding;
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
}
```

**Presets:**
- `SunfireCard.mangaGrid()` — flat, standard, 16px, glass border
- `SunfireCard.chapterTile()` — flat, standard, 14px, tight padding
- `SunfireCard.sidebar()` — glass, loose, frosted blur
- `SunfireCard.bottomNav()` — glass, modal, blur 30
- `SunfireCard.sheet()` — flat, modal, no border

### 1.3 Button System
**Current State:** `ElevatedButton`, `OutlinedButton`, `TextButton`, `IconButton`, `FloatingActionButton` with inline styling.

**Unified Button:**
```dart
class SunfireButton extends StatelessWidget {
  enum Style { primary, secondary, tertiary, destructive, ghost }
  enum Size { small, medium, large, iconOnly }
  enum Width { fit, expand }

  final Style style;
  final Size size;
  final Width width;
  final Widget child;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final bool loading;
}
```

**Style Mapping:**
| Style | Background | Text | Border | Use Case |
|-------|------------|------|--------|----------|
| primary | accent | white | none | Primary CTA |
| secondary | surface 12% | white | accent | Secondary |
| tertiary | transparent | accent | accent | Tertiary/Link |
| destructive | red 15% | redAccent | red | Delete/Logout |
| ghost | transparent | white70 | none | Low emphasis |

---

## 🏷️ Phase 2: Pill & Icon Polish

### 2.1 Status Pills (Library, Reader, Updates)
**Issues:** Inconsistent sizing, missing loading states, no long-press affordance.

**Improvements:**
- Standard 24px height (compact) / 32px (chip)
- Add `SunfirePill.loading` variant (shimmer pulse)
- Long-press → tooltip with full status text
- Consistent icon sizes: 14px (compact), 16px (chip)

### 2.2 Filter Pills (Library, Browse, Updates)
**Issues:** Selected state not obvious on some themes; no keyboard focus style.

**Improvements:**
- Add `focusNode` + `Focus` widget for keyboard navigation
- Selected: `primaryContainer` bg + `onPrimaryContainer` text (Material 3 tokens)
- Hover (desktop/web): subtle scale 1.02 + shadow

### 2.3 Server Scope Pills
**Current:** `SunfireBadge.server()/local()/proxy()` — hardcoded colors.

**Improvement:** Use semantic color roles from `ColorScheme`:
```dart
extension ServerScopeColor on ColorScheme {
  Color get serverScope => Color(0xFF06B6D4); // teal
  Color get localScope => Color(0xFFA855F7); // purple
  Color get proxyScope => Color(0xFFF59E0B); // amber
}
```

### 2.4 Icon System
**Current:** Material Icons (Round) used directly; no icon theme.

**Improvements:**
1. **Icon Theme:** Add `IconThemeData` to `ThemeData` with `size: 24`, `opticalSize: 24`
2. **Custom Icon Set:** Create `SunfireIcons` class for semantic aliases:
   ```dart
   class SunfireIcons {
     static const IconData manga = Icons.auto_stories_rounded;
     static const IconData chapter = Icons.menu_book_rounded;
     static const IconData download = Icons.download_rounded;
     static const IconData sync = Icons.sync_rounded;
     // ...
   }
   ```
3. **SVG Icons:** For brand/logo — replace emoji/gradients with `SvgPicture.asset`
3. **Size Tokens:** `iconSizeXS=16`, `iconSizeSM=20`, `iconSizeMD=24`, `iconSizeLG=28`, `iconSizeXL=32`

---

## 🔤 Phase 3: Typography & Font System

### 3.1 Font Family
**Current:** System default (Roboto/SF Pro).
**Recommendation:** Keep system fonts for performance, add **variable font** for headings:
- Add `GoogleFonts.inter` (variable) for UI headings
- Keep `GoogleFonts.robotoMono` for code/monospace (log viewer, chapter numbers)

### 3.2 Font Size Scale (Fluid)
**Problem:** Fixed sizes don't scale well across 320px–1440px.
**Solution:** Use `MediaQuery.textScalerOf` + `clamp`:

```dart
double fluidFontSize(BuildContext context, {required double min, required double max, double breakpoint = 600}) {
  final scale = MediaQuery.textScalerOf(context).scale(1.0);
  final width = MediaQuery.sizeOf(context).width;
  final t = (width.clamp(320.0, 1440.0) - 320) / (1440 - 320);
  return lerpDouble(min, max, t)! * scale;
}
```

### 3.3 Line Height & Letter Spacing Standardization
| Role | Line Height | Letter Spacing |
|------|-------------|----------------|
| Hero | 1.15 | -0.5 |
| Title | 1.25 | 0 |
| Body | 1.5 | 0 |
| Caption | 1.4 | +0.2 |
| Button | 1.2 | +0.5 |
| Badge | 1.2 | 0 |

---

## 🎭 Phase 4: Motion & Interaction

### 4.1 Motion Tokens (from Phase 0)
| Token | Duration | Curve | Use Case |
|-------|----------|-------|----------|
| `fast` | 150ms | easeOutCubic | Hover, press, badge appear |
| `normal` | 200ms | easeOutCubic | Card tap, dialog open |
| `medium` | 280ms | easeInOutCubic | Sidebar, nav rail |
| `slow` | 400ms | easeInOutCubic | Sheet, page transition |
| `page` | 260ms | easeOutCubic | Tab/page switch |

### 4.2 Standardized Transitions
**Replace all custom animations with:**
```dart
class SunfireTransitions {
  static PageRouteBuilder<T> fadeSlide<T>(Widget child) => PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => child,
    transitionDuration: DesignTokens.normal,
    reverseTransitionDuration: DesignTokens.fast,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: anim.drive(Tween(begin: const Offset(0, 0.04), end: Offset.zero)
            .chain(CurveTween(curve: DesignTokens.standard))),
        child: child,
      ),
    ),
  );

  static Widget fadeIn(Widget child, {Duration? delay}) => FadeTransition(
    opacity: CurvedAnimation(parent: _controller, curve: Interval(delay?.inMilliseconds ?? 0, 1.0)),
    child: child,
  );
}
```

### 4.3 Micro-interactions
| Component | Interaction | Feedback |
|-----------|-------------|----------|
| Pill tap | Scale 0.95 → 1.0 | Haptic light |
| Card tap | Ripple + scale 0.98 | Haptic light |
| Button press | Scale 0.96 | Haptic medium |
| Switch toggle | Spring | Haptic selection |
| Sidebar expand | Width + label fade | None |
| Page transition | Fade + slide up 4dp | None |
| Sheet open | Fade + slide up 8dp | Haptic light |

### 4.4 Reduced Motion
**Add setting:** `SettingsService.reducedMotion` → wraps all animations:
```dart
Duration effectiveDuration(Duration base) =>
  SettingsService.instance.reducedMotion ? Duration.zero : base;
```

---

## ♿ Phase 5: Accessibility (WCAG 2.1 AA)

### 5.1 Semantics Audit
**Add explicit `Semantics` to:**
- `SunfireBadge` → `label: 'Unread, 5 chapters'`
- `ChapterProgressBar` → `value: 'Chapter 12, page 5 of 24, 21% read'`
- `ReaderTapZones` → `button: true, label: 'Next page'`
- `SidebarItem` → `selected: true, label: 'Library'`

### 5.2 Focus Management
- All interactive elements: `FocusTraversalOrder` logical
- `Focus` widget on all custom clickables
- Visible focus ring: `primary` color, 2px, offset 2px
- Skip-to-content link on settings screens

### 5.3 Color Contrast
**Current:** OLED `#0A0A0C` + white = 21:1 ✓
**Verify:** All semantic colors meet 4.5:1 (text) / 3:1 (UI)
- Accent on surface: test all 8 palettes
- Status colors on glass: test all variants
- Disabled states: ensure 3:1 minimum

### 5.4 Text Scaling
- Add `SettingsService.fontScaleFactor` (0.85–1.3, step 0.05)
- Apply via `MediaQuery(textScaler: TextScaler.linear(factor))`
- Test at 0.85x and 1.3x — no overflow, truncation, or clipped text

### 5.5 Reduced Motion
- Respect `MediaQuery.motionScaling` (iOS) / system setting (Android)
- Add manual toggle in Accessibility settings section

---

## 🧪 Phase 6: Testing & Validation Strategy

### 6.1 Golden File Tests (Widget)
**Tool:** `golden_toolkit` + `flutter_test`
**Coverage:**
| Component | Variants | Breakpoints |
|-----------|----------|-------------|
| `SunfirePill` | 6 variants × 3 states × 2 themes | 320, 720, 1440 |
| `SunfireCard` | 5 presets × 2 themes | 320, 720, 1440 |
| `SunfireButton` | 5 styles × 3 sizes × 2 themes | — |
| `LibraryScreen` | 4 display modes × 2 themes | 320, 720, 1440 |
| `ReaderScreen` | 4 reading modes × 2 themes | 320, 720, 1440 |

**CI:** Run on every PR; fail on pixel diff > 0.1%

### 6.2 Accessibility Tests
```dart
testWidgets('SunfirePill meets contrast', (tester) async {
  for (final variant in SunfirePillVariant.values) {
    final pill = SunfirePill(variant: variant, label: 'Test');
    await tester.pumpWidget(MaterialApp(home: pill));
    final semantics = tester.getSemantics(find.byType(SunfirePill));
    expect(semantics.hasFlag(SemanticsFlag.button), isTrue);
    // Contrast check via custom matcher
  }
});

testWidgets('Text scaling 1.3x no overflow', (tester) async {
  await tester.pumpWidget(MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
    child: MaterialApp(home: LibraryScreen()),
  ));
  // Verify no RenderOverflow errors
});
```

### 6.3 Visual Regression (Chromatic/Percy)
- Capture all screens at 3 breakpoints
- Review on PR — approve or request changes

### 6.4 Performance Benchmarks
- Frame render time (target: <16ms p99)
- List scroll FPS (target: 60fps sustained)
- Animation jank (target: 0 jank frames)

---

## 📦 Phase 7: Implementation Roadmap

### Sprint 0 (Week 0-1): Critical Bug Fixes — **DO FIRST**
- [ ] **R1** Self-healing scrape: match by manga URL not title (`reader_screen.dart`, `content_resolver_service.dart`)
- [ ] **R2** Image cache: never evict `currentPage ± 2` (`reader_screen.dart`)
- [ ] **R3** Auto-scroll per-chapter flag (`reader_screen.dart`)
- [ ] **R4** Volume key recentre generation token (`reader_screen.dart`)
- [ ] **R5** Prefetch generation guard (`reader_screen.dart`)
- [ ] **R6** ContentResolver 15s overall timeout + ImageStreamListener timeout (`content_resolver_service.dart`, `reader_screen.dart`)
- [ ] **R7** Download-ahead generation guard (`reader_screen.dart`)
- [ ] **R8** Prefetch cache max 3 + clear on chapter load (`reader_screen.dart`)
- [ ] **R9** Curl semaphore max 2 (`reader_screen.dart`, `safe_curl.dart`)
- [ ] **U1** Updates: merge server into local, preserve pending (`updates_screen.dart`)
- [ ] **U2** Bulk mark-read atomic + rollback (`updates_screen.dart`)
- [ ] **U3** Single toggle rollback on sync failure (`updates_screen.dart`)
- [ ] **S1** `mergeLastPageRead`: only take server if `server > local` (`sync_engine.dart:98`)
- [ ] **S2** Incremental chapter sync (`sync_engine.dart`)
- [ ] **S3** Chapter wipe guard (`sync_engine.dart`)
- [ ] **S4** WS auth refresher callback (`websocket_service.dart`)
- [ ] **S5** WS unsubscribe before reconnect (`websocket_service.dart`)
- [ ] **S6** `syncChapterProgress` updates `lastReadAt` on direct success (`sync_engine.dart`)
- [ ] **S7** `LibraryUpdateService` await sync completion (`library_update_service.dart`)
- [ ] **S8** Skip local scrape for server-synced manga (`library_update_service.dart`)
- [ ] **ST1** `SettingsService` extends `ChangeNotifier` (`settings_service.dart`, `reader_screen.dart`, `updates_screen.dart`)
- [ ] **EH1** Error handling: `LoggerService` + user-facing SnackBar with retry

### Sprint 1 (Week 1-2): Foundation
- [ ] Create `design_tokens.dart`
- [ ] Create semantic `TextStyle` extensions
- [ ] Add `reducedMotion` + `fontScaleFactor` settings
- [ ] Migrate 10 highest-impact files to tokens

### Sprint 2 (Week 2-3): Pill & Card System
- [ ] Implement `SunfirePill` with 6 variants
- [ ] Implement `SunfireCard` with 5 presets
- [ ] Migrate `SunfireBadge` → `SunfirePill(variant: .status)`
- [ ] Migrate all `FilterChip`/`ChoiceChip` → `SunfirePill(variant: .filter)`
- [ ] Golden tests for Pill + Card

### Sprint 3 (Week 3-4): Button & Typography
- [ ] Implement `SunfireButton`
- [ ] Migrate all buttons
- [ ] Semantic TextStyle migration
- [ ] Fluid font size + line height standardization

### Sprint 4 (Week 4-5): Icons & Motion
- [ ] `SunfireIcons` semantic aliases
- [ ] SVG brand/logo
- [ ] Motion token integration
- [ ] Reduced motion setting + integration

### Sprint 5 (Week 5-6): Accessibility
- [ ] Semantics on all custom components
- [ ] Focus management + visible focus ring
- [ ] Color contrast audit + fixes
- [ ] Text scaling 0.85x–1.3x testing
- [ ] Screen reader testing (TalkBack/VoiceOver)

### Sprint 6 (Week 6): Polish & Ship
- [ ] Golden test suite in CI
- [ ] Visual regression baseline
- [ ] Performance benchmarks
- [ ] Documentation update
- [ ] Release v3.1.0 "UI Polish"

---

## ✅ Verification Checklist (Per Sprint)

### Code Quality
- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — 100% pass (440+)
- [ ] Golden tests — 0 pixel diff
- [ ] No inline constants (enforced by linter)

### Accessibility
- [ ] Semantics on all custom widgets
- [ ] Focus visible + logical order
- [ ] Contrast ≥ 4.5:1 (text), ≥ 3:1 (UI)
- [ ] Text scaling 0.85x–1.3x — no overflow
- [ ] Reduced motion respected

### Performance
- [ ] Frame time p99 < 16ms
- [ ] Scroll 60fps sustained
- [ ] Animation jank = 0
- [ ] App size ≤ previous release

### Design Consistency
- [ ] All pills use `SunfirePill`
- [ ] All cards use `SunfireCard`
- [ ] All buttons use `SunfireButton`
- [ ] All text uses semantic styles
- [ ] All spacing/radius from tokens

---

## 🚫 Out of Scope (Future)
- Custom font loading (keep system for now)
- RTL layout (not needed for manga)
- High-contrast theme (system handles)
- Animation editor/designer tool
- Theme marketplace

---

## 📚 References
- [Material 3 Design Tokens](https://m3.material.io/foundations/design-tokens/overview)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- Sunfire codebase: `lib/src/core/theme/`, `lib/src/core/widgets/`, `lib/src/features/settings/widgets/`