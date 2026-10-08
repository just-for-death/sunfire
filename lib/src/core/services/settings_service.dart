import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/javascript/m_client.dart';
import '../engine/repo_manager.dart';
import '../logging/logger_service.dart';

class SettingsService extends ChangeNotifier {
  static SettingsService? _instance;
  SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _cfProxyUrlKey = 'cf_proxy_url_secure';
  /// Plaintext pref: only '' | 'off' | 'none' | not-yet-migrated legacy URL.
  static const _cfProxyPrefKey = 'cf_proxy_url';
  String? _cachedSecureProxyUrl;

  SettingsService._();

  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      // Migrate proxy URL from shared_preferences to secure storage if needed
      await _migrateProxyUrlToSecureStorage();
      // Cache secure storage proxy URL for fast synchronous access
      _cachedSecureProxyUrl = await _secureStorage.read(key: _cfProxyUrlKey);
    } catch (e) {
      // Never let a keychain/keystore problem abort settings init (locked iOS
      // keychain in background fetch, Linux without libsecret, Android keystore
      // corruption, missing plugin in tests). A not-yet-migrated legacy
      // plaintext URL or "no proxy" is the fallback (UIX-10). Log only the error type: the URL may
      // contain credentials.
      unawaited(LoggerService.instance.logWarning(
          'Secure storage unavailable, proxy URL not loaded: ${e.runtimeType}', 'Settings'));
    }
    // Apply the Cloudflare bypass proxy here, not only in the cfProxyUrl
    // setter. The WorkManager background isolate calls initialize() and never
    // runs main.dart's startup wiring, so background library updates and
    // source scrapes were hitting Cloudflare-protected sites directly and
    // failing while the foreground app worked.
    MClient.cfProxyUrl = cfProxyUrl;
    await _migrateOnboardingReposIntoCustomRepos();
    for (final url in customRepos) {
      final normalized = RepoManager.normalizeRepoUrl(url);
      RepoManager.instance.addUserRepo(RepoManager.deriveRepoTitle(normalized), normalized);
    }
  }

  /// Moves a legacy plaintext proxy URL (`cf_proxy_url` pref) into secure
  /// storage (UIX-10). The plaintext copy is cleared only after the value has
  /// been written AND read back unchanged. If secure storage throws, the
  /// plaintext is left in place (the user keeps a working proxy) and the
  /// migration is retried on the next launch. Older builds read the pref
  /// first, so when both exist and differ the pref value wins.
  Future<void> _migrateProxyUrlToSecureStorage() async {
    final saved = _prefs?.getString(_cfProxyPrefKey)?.trim();
    if (saved == null || saved.isEmpty || saved == 'none' || saved == 'off') return;
    try {
      final secure = await _secureStorage.read(key: _cfProxyUrlKey);
      if (secure != saved) {
        await _secureStorage.write(key: _cfProxyUrlKey, value: saved);
        final readBack = await _secureStorage.read(key: _cfProxyUrlKey);
        if (readBack != saved) {
          unawaited(LoggerService.instance.logWarning(
              'Proxy URL migration not verified; plaintext copy kept until next launch', 'Settings'));
          return;
        }
      }
      _cachedSecureProxyUrl = saved;
      await _prefs?.setString(_cfProxyPrefKey, '');
    } catch (e) {
      // Log only the error type: the URL may contain credentials.
      unawaited(LoggerService.instance.logWarning(
          'Proxy URL migration to secure storage failed (${e.runtimeType}); will retry next launch',
          'Settings'));
    }
  }

  /// Onboarding historically wrote `sunfire_selected_repos`; Browse/Settings read `custom_repos`.
  Future<void> _migrateOnboardingReposIntoCustomRepos() async {
    final legacy = _prefs?.getStringList('sunfire_selected_repos') ?? [];
    if (legacy.isEmpty) return;
    final existing = List<String>.from(customRepos);
    var changed = false;
    for (final url in legacy) {
      final normalized = RepoManager.normalizeRepoUrl(url);
      if (normalized.isEmpty) continue;
      final already = existing.any((e) => RepoManager.normalizeRepoUrl(e) == normalized);
      if (!already) {
        existing.add(normalized);
        changed = true;
      }
    }
    if (changed) {
      await _prefs?.setStringList('custom_repos', existing);
    }
  }

  // ── MANGA DETAILS ────────────────────────────────────────
  bool get chapterSortAscending => _prefs?.getBool('chapter_sort_ascending') ?? false;
  set chapterSortAscending(bool value) {
    unawaited(_prefs?.setBool('chapter_sort_ascending', value));
    notifyListeners();
  }

  // ── ONBOARDING & SERVER ──────────────────────────────────
  bool get onboardingCompleted => _prefs?.getBool('sunfire_onboarding_completed') ?? _prefs?.getBool('onboarding_completed') ?? false;
  set onboardingCompleted(bool value) {
    unawaited(_prefs?.setBool('sunfire_onboarding_completed', value));
    unawaited(_prefs?.setBool('onboarding_completed', value));
    notifyListeners();
  }

  String get serverUrl {
    final s = _prefs?.getString('server_url');
    if (s != null && s.trim().isNotEmpty) return s.trim();
    final sf = _prefs?.getString('sunfire_server_url');
    if (sf != null && sf.trim().isNotEmpty) return sf.trim();
    return '';
  }
  set serverUrl(String value) {
    final trimmed = value.trim();
    unawaited(_prefs?.setString('server_url', trimmed));
    unawaited(_prefs?.setString('sunfire_server_url', trimmed));
    notifyListeners();
  }

  // Certificate pinning is hidden for this release (UIX-06, Jane decision A).
  // The old implementation only ran for certificates that had already failed
  // CA validation and hashed the whole DER while the UI asked for SPKI pins, so
  // it gave no protection. No getter/setter is exposed and no client receives
  // pins. Any legacy `certificate_pins` pref is left untouched (not read) so a
  // future real implementation (option B) can migrate it.

  /// FlareSolverr / Byparr proxy URL for Cloudflare bypass (e.g. http://192.168.1.x:8191/v1).
  /// Empty by default. Set to 'none', 'off', or empty to disable.
  ///
  /// The URL may contain credentials, so it lives only in secure storage
  /// (UIX-10). The `cf_proxy_url` pref now only holds '' or 'off' (disabled
  /// flag), or a legacy plaintext URL that has not been migrated yet because
  /// secure storage was unavailable at startup. If secure storage is
  /// unavailable when a NEW URL is set, it is kept for the current session
  /// only (Jane's decision): there is no plaintext fallback.
  String get cfProxyUrl {
    final flag = _prefs?.getString(_cfProxyPrefKey)?.trim();
    if (flag == 'none' || flag == 'off') return '';
    final secure = _cachedSecureProxyUrl?.trim() ?? '';
    if (secure.isNotEmpty) return secure;
    // Legacy plaintext only while its migration could not run.
    return (flag != null && flag.isNotEmpty) ? flag : '';
  }

  set cfProxyUrl(String value) {
    final trimmed = value.trim();
    final disabled = trimmed.isEmpty || trimmed == 'none' || trimmed == 'off';
    _cachedSecureProxyUrl = disabled ? null : trimmed;
    // Never write the URL itself to prefs. 'off' (rather than '') when
    // disabling, so a failed secure delete cannot resurrect an old URL on the
    // next launch. Writing '' for a new URL also drops any legacy plaintext.
    unawaited(_prefs?.setString(_cfProxyPrefKey, disabled ? 'off' : ''));
    unawaited(_persistSecureProxyUrl(disabled ? null : trimmed));
    MClient.cfProxyUrl = disabled ? '' : trimmed;
    notifyListeners();
  }

  /// Completes when the most recent proxy URL write/delete has finished
  /// (successfully or not). For tests.
  @visibleForTesting
  Future<void> get pendingProxyPersist => _pendingProxyPersist;
  Future<void> _pendingProxyPersist = Future<void>.value();

  Future<void> _persistSecureProxyUrl(String? value) {
    return _pendingProxyPersist = () async {
      try {
        if (value == null) {
          await _secureStorage.delete(key: _cfProxyUrlKey);
        } else {
          await _secureStorage.write(key: _cfProxyUrlKey, value: value);
        }
      } catch (e) {
        unawaited(LoggerService.instance.logWarning(
            value == null
                ? 'Could not delete secure proxy URL (${e.runtimeType}); proxy disabled via flag'
                : 'Secure storage unavailable (${e.runtimeType}); proxy URL kept for this session only',
            'Settings'));
      }
    }();
  }

  // ── ACCENT COLOR PALETTE ──────────────────────────────────
  static const Map<String, Color> accentColors = {
    'Sunfire Orange': Color(0xFFFF5722),
    'Catppuccin Blue': Color(0xFF7AA2F7),
    'Emerald Green': Color(0xFF10B981),
    'Crimson Red': Color(0xFFEF4444),
    'Amethyst Purple': Color(0xFF8B5CF6),
    'Teal Cyan': Color(0xFF06B6D4),
    'Sakura Pink': Color(0xFFEC4899),
    'Amber Gold': Color(0xFFF59E0B),
    'Nord Frost': Color(0xFF88C0D0),
    'Rose Pine': Color(0xFFEB6F92),
    'Lavender Mist': Color(0xFFA78BFA),
    'Cyber Lime': Color(0xFF84CC16),
    'Sunset Coral': Color(0xFFFF6B6B),
    'Midnight Indigo': Color(0xFF6366F1),
    'Mocha Brown': Color(0xFFB45309),
    'Electric Violet': Color(0xFFC084FC),
  };

  String get accentColorName => _prefs?.getString('accent_color_name') ?? 'Sunfire Orange';
  set accentColorName(String value) {
    unawaited(_prefs?.setString('accent_color_name', value));
    notifyListeners();
  }

  Color get accentColor => accentColors[accentColorName] ?? const Color(0xFFFF5722);

  // ── TABLET NAVIGATION ─────────────────────────────────────
  bool get tabletSidebarExpanded => _prefs?.getBool('tablet_sidebar_expanded') ?? true;
  set tabletSidebarExpanded(bool value) {
    unawaited(_prefs?.setBool('tablet_sidebar_expanded', value));
    notifyListeners();
  }

  // ── READER SETTINGS (MIHON PARITY) ───────────────────────
  /// Suppresses reading-history recording and progress tracking.
  ///
  /// Scope is *reading progress only*, matching the settings UI wording
  /// ("Pause reading history recording and suppress unread progress updates").
  /// Bookmarks, library membership, downloads and categories are deliberate
  /// user-created organisation and are intentionally NOT suppressed — a user
  /// reading privately still expects the things they deliberately saved to
  /// persist. Enforced centrally by `SyncEngine.commitChapterReadState` and
  /// `SyncEngine.syncChapterProgress`; do not add ad-hoc checks at call sites,
  /// which is how eleven of the twelve mutation paths used to bypass it.
  bool get incognitoMode => _prefs?.getBool('incognito_mode') ?? false;
  set incognitoMode(bool value) {
    unawaited(_prefs?.setBool('incognito_mode', value));
    notifyListeners();
  }

  String get readingMode => _prefs?.getString('reading_mode') ?? 'Long Strip';
  set readingMode(String value) {
    unawaited(_prefs?.setString('reading_mode', value));
    notifyListeners();
  }

  String get readerTheme => _prefs?.getString('reader_theme') ?? 'Black';
  set readerTheme(String value) {
    unawaited(_prefs?.setString('reader_theme', value));
    notifyListeners();
  }

  String get colorFilter => _prefs?.getString('color_filter') ?? 'None';
  set colorFilter(String value) {
    unawaited(_prefs?.setString('color_filter', value));
    notifyListeners();
  }

  String get scaleType => _prefs?.getString('scale_type') ?? 'Fit Width';
  set scaleType(String value) {
    unawaited(_prefs?.setString('scale_type', value));
    notifyListeners();
  }

  bool get tapZonesEnabled => _prefs?.getBool('tap_zones_enabled') ?? true;
  set tapZonesEnabled(bool value) {
    unawaited(_prefs?.setBool('tap_zones_enabled', value));
    notifyListeners();
  }

  bool get invertTapZones => _prefs?.getBool('invert_tap_zones') ?? false;
  set invertTapZones(bool value) {
    unawaited(_prefs?.setBool('invert_tap_zones', value));
    notifyListeners();
  }

  /// Paged-mode tap-zone preset (Default / L-shaped / Kindle-ish / Edge / Left-Right / Off).
  String get tapZonePresetPaged => _prefs?.getString('tap_zone_preset_paged') ?? 'Default';
  set tapZonePresetPaged(String value) {
    unawaited(_prefs?.setString('tap_zone_preset_paged', value));
    notifyListeners();
  }

  /// Webtoon / long-strip tap-zone preset (separate from paged, Tachimanga-style).
  String get tapZonePresetWebtoon => _prefs?.getString('tap_zone_preset_webtoon') ?? 'Default';
  set tapZonePresetWebtoon(String value) {
    unawaited(_prefs?.setString('tap_zone_preset_webtoon', value));
    notifyListeners();
  }

  /// First-run Mihon-style zone overlay has been shown at least once.
  bool get tapZonesOverlaySeen => _prefs?.getBool('tap_zones_overlay_seen') ?? false;
  set tapZonesOverlaySeen(bool value) {
    unawaited(_prefs?.setBool('tap_zones_overlay_seen', value));
    notifyListeners();
  }

  /// Single / Double / Automatic (by orientation).
  String get doublePageDisplayMode => _prefs?.getString('double_page_display_mode') ?? 'Single';
  set doublePageDisplayMode(String value) {
    unawaited(_prefs?.setString('double_page_display_mode', value));
    notifyListeners();
  }

  /// When true, first page stands alone before pairing (Aidoku / Komelia offset).
  bool get doublePageOffset => _prefs?.getBool('double_page_offset') ?? false;
  set doublePageOffset(bool value) {
    unawaited(_prefs?.setBool('double_page_offset', value));
    notifyListeners();
  }

  /// Invert left/right pairing in double-page spreads (RTL-friendly).
  bool get invertDoublePages => _prefs?.getBool('invert_double_pages') ?? false;
  set invertDoublePages(bool value) {
    unawaited(_prefs?.setBool('invert_double_pages', value));
    notifyListeners();
  }

  bool get seamlessTransitions => _prefs?.getBool('seamless_transitions') ?? true;
  set seamlessTransitions(bool value) {
    unawaited(_prefs?.setBool('seamless_transitions', value));
    notifyListeners();
  }

  /// Mihon/Mangayomi-style end-of-chapter dialog with Previous/Next/Close
  /// actions, shown once per chapter when the last page is reached.
  bool get showEndOfChapterDialog => _prefs?.getBool('show_end_of_chapter_dialog') ?? true;
  set showEndOfChapterDialog(bool value) {
    unawaited(_prefs?.setBool('show_end_of_chapter_dialog', value));
    notifyListeners();
  }

  bool get volumeKeyTurn => _prefs?.getBool('volume_key_turn') ?? true;
  set volumeKeyTurn(bool value) {
    unawaited(_prefs?.setBool('volume_key_turn', value));
    notifyListeners();
  }

  bool get cropBorders => _prefs?.getBool('crop_borders') ?? false;
  set cropBorders(bool value) {
    unawaited(_prefs?.setBool('crop_borders', value));
    notifyListeners();
  }

  bool get keepScreenAwake => _prefs?.getBool('keep_screen_awake') ?? true;
  set keepScreenAwake(bool value) {
    unawaited(_prefs?.setBool('keep_screen_awake', value));
    notifyListeners();
  }

  // ── APPEARANCE & THEMES ───────────────────────────────────
  String get themeMode => _prefs?.getString('theme_mode') ?? 'OLED Black';
  set themeMode(String value) {
    unawaited(_prefs?.setString('theme_mode', value));
    notifyListeners();
  }

  /// Pure black (AMOLED) toggle, separate from [themeMode] (UIS-P2-C).
  /// Legacy installs that picked the old 'OLED Black' theme mode keep pure
  /// black until they flip this switch.
  bool get pureBlackEnabled =>
      _prefs?.getBool('pure_black_enabled') ?? (themeMode == 'OLED Black');
  set pureBlackEnabled(bool value) {
    unawaited(_prefs?.setBool('pure_black_enabled', value));
    notifyListeners();
  }

  bool get materialYouEnabled => _prefs?.getBool('material_you_enabled') ?? true;
  set materialYouEnabled(bool value) {
    unawaited(_prefs?.setBool('material_you_enabled', value));
    notifyListeners();
  }

  String get dateFormat => _prefs?.getString('date_format') ?? 'YYYY-MM-DD';
  set dateFormat(String value) {
    unawaited(_prefs?.setString('date_format', value));
    notifyListeners();
  }

  String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    switch (dateFormat) {
      case 'MM/DD/YYYY':
        return '$m/$d/$y';
      case 'DD/MM/YYYY':
        return '$d/$m/$y';
      case 'DD.MM.YYYY':
        return '$d.$m.$y';
      case 'YYYY-MM-DD':
      default:
        return '$y-$m-$d';
    }
  }

  // ── LIBRARY & CATEGORIES (MIHON PARITY) ───────────────────
  String get libraryDisplayMode => _prefs?.getString('library_display_mode') ?? 'Comfortable Grid';
  set libraryDisplayMode(String value) {
    unawaited(_prefs?.setString('library_display_mode', value));
    notifyListeners();
  }

  int get gridColumnCount => _prefs?.getInt('library_grid_columns') ?? 0; // 0 = Auto
  set gridColumnCount(int value) {
    unawaited(_prefs?.setInt('library_grid_columns', value));
    notifyListeners();
  }

  bool get showUnreadBadges => _prefs?.getBool('show_unread_badges') ?? true;
  set showUnreadBadges(bool value) {
    unawaited(_prefs?.setBool('show_unread_badges', value));
    notifyListeners();
  }

  bool get showDownloadedBadges => _prefs?.getBool('show_downloaded_badges') ?? true;
  set showDownloadedBadges(bool value) {
    unawaited(_prefs?.setBool('show_downloaded_badges', value));
    notifyListeners();
  }

  bool get showLanguageBadges => _prefs?.getBool('show_language_badges') ?? false;
  set showLanguageBadges(bool value) {
    unawaited(_prefs?.setBool('show_language_badges', value));
    notifyListeners();
  }

  // ── SOURCES & BROWSING (MIHON PARITY) ─────────────────────
  List<String> get pinnedSources => _prefs?.getStringList('pinned_sources') ?? [];
  Future<void> togglePinSource(String sourceName) async {
    final list = List<String>.from(pinnedSources);
    if (list.contains(sourceName)) {
      list.remove(sourceName);
    } else {
      list.add(sourceName);
    }
    await _prefs?.setStringList('pinned_sources', list);
    notifyListeners();
  }

  bool isSourcePinned(String sourceName) => pinnedSources.contains(sourceName);

  List<String> get selectedLanguages => _prefs?.getStringList('selected_languages') ?? ['all'];
  set selectedLanguages(List<String> langs) {
    unawaited(_prefs?.setStringList('selected_languages', langs));
    notifyListeners();
  }

  /// Whether an entry's language passes the selected-language filter.
  ///
  /// `all` (or no selection) disables filtering. Entries with an unknown/empty
  /// language always pass so content is never hidden by accident.
  static bool languageMatchesFilter(String lang, List<String> selectedLanguages) {
    if (selectedLanguages.isEmpty || selectedLanguages.contains('all')) return true;
    final l = lang.trim().toLowerCase();
    if (l.isEmpty) return true;
    return selectedLanguages.contains(l);
  }

  /// Short uppercase language code for badges, or null when the language is a
  /// default/universal label that doesn't warrant a badge.
  static String? languageBadgeLabel(String lang) {
    final v = lang.trim().toUpperCase();
    if (v.isEmpty || v == 'EN' || v == 'ALL' || v == 'MULTI' || v == 'UNIVERSAL') return null;
    return v.length <= 6 ? v : v.substring(0, 6);
  }

  bool get showNsfwSources => _prefs?.getBool('show_nsfw_sources') ?? true;
  set showNsfwSources(bool value) {
    unawaited(_prefs?.setBool('show_nsfw_sources', value));
    notifyListeners();
  }

  // Legacy aliases — keep prefs keys readable for older installs.
  bool get autoDownloadEnabled => autoDownloadWhileReading;
  set autoDownloadEnabled(bool value) => autoDownloadWhileReading = value;

  int get autoDownloadCount => downloadAheadChapterCount;
  set autoDownloadCount(int value) => downloadAheadChapterCount = value;

  bool get autoDeleteRead => deleteChapterAfterMarkedRead;
  set autoDeleteRead(bool value) => deleteChapterAfterMarkedRead = value;

  bool get deleteChapterAfterMarkedRead => _prefs?.getBool('delete_chapter_after_marked_read') ?? false;
  set deleteChapterAfterMarkedRead(bool value) {
    unawaited(_prefs?.setBool('delete_chapter_after_marked_read', value));
    notifyListeners();
  }

  String get deleteFinishedChaptersWhileReading => _prefs?.getString('delete_finished_chapters_while_reading') ?? 'Disabled';
  set deleteFinishedChaptersWhileReading(String value) {
    unawaited(_prefs?.setString('delete_finished_chapters_while_reading', value));
    notifyListeners();
  }

  bool get allowDeletingBookmarkedChapters => _prefs?.getBool('allow_deleting_bookmarked_chapters') ?? false;
  set allowDeletingBookmarkedChapters(bool value) {
    unawaited(_prefs?.setBool('allow_deleting_bookmarked_chapters', value));
    notifyListeners();
  }

  bool get autoDownloadWhileReading => _prefs?.getBool('auto_download_while_reading') ?? false;
  set autoDownloadWhileReading(bool value) {
    unawaited(_prefs?.setBool('auto_download_while_reading', value));
    notifyListeners();
  }

  int get downloadAheadChapterCount => _prefs?.getInt('download_ahead_chapter_count') ?? 2;
  set downloadAheadChapterCount(int value) {
    unawaited(_prefs?.setInt('download_ahead_chapter_count', value));
    notifyListeners();
  }

  bool get downloadOnlyOnWifi => _prefs?.getBool('download_only_on_wifi') ?? true;
  set downloadOnlyOnWifi(bool value) {
    unawaited(_prefs?.setBool('download_only_on_wifi', value));
    notifyListeners();
  }

  bool get downloadOnlyWhileCharging => _prefs?.getBool('download_only_while_charging') ?? false;
  set downloadOnlyWhileCharging(bool value) {
    unawaited(_prefs?.setBool('download_only_while_charging', value));
    notifyListeners();
  }

  /// Show a system notification when a batch of chapter downloads finishes.
  bool get downloadNotificationsEnabled => _prefs?.getBool('download_notifications_enabled') ?? true;
  set downloadNotificationsEnabled(bool value) {
    unawaited(_prefs?.setBool('download_notifications_enabled', value));
    notifyListeners();
  }

  /// Keep downloading in the background via the Android foreground service.
  bool get backgroundDownloadsEnabled => _prefs?.getBool('background_downloads_enabled') ?? true;
  set backgroundDownloadsEnabled(bool value) {
    unawaited(_prefs?.setBool('background_downloads_enabled', value));
    notifyListeners();
  }

  // Local auto-download category include/exclude removed (UIX-13, decision a):
  // no local auto-download-on-update feature exists for it to filter. Legacy
  // `auto_download_categories_include/exclude` prefs are left unread.

  // ── LIBRARY & CATEGORY SETTINGS ──────────────────────────
  int? get defaultCategoryId => _prefs?.getInt('default_category_id');
  set defaultCategoryId(int? value) {
    if (value == null) {
      unawaited(_prefs?.remove('default_category_id'));
    } else {
      unawaited(_prefs?.setInt('default_category_id', value));
    }
    notifyListeners();
  }

  String get defaultCategoryName => _prefs?.getString('default_category_name') ?? 'Default';
  set defaultCategoryName(String value) {
    unawaited(_prefs?.setString('default_category_name', value));
    notifyListeners();
  }

  bool get showCategoryTabs => _prefs?.getBool('show_category_tabs') ?? true;
  set showCategoryTabs(bool value) {
    unawaited(_prefs?.setBool('show_category_tabs', value));
    notifyListeners();
  }

  // ── LIBRARY AUTO-UPDATE & NOTIFICATIONS (MIHON PARITY) ──
  int get libraryUpdateFrequencyHours => _prefs?.getInt('library_update_frequency_hours') ?? 12;
  set libraryUpdateFrequencyHours(int value) {
    unawaited(_prefs?.setInt('library_update_frequency_hours', value));
    notifyListeners();
  }

  bool get libraryUpdateOnlyOnWifi => _prefs?.getBool('library_update_only_on_wifi') ?? true;
  set libraryUpdateOnlyOnWifi(bool value) {
    unawaited(_prefs?.setBool('library_update_only_on_wifi', value));
    notifyListeners();
  }

  bool get libraryUpdateOnlyCharging => _prefs?.getBool('library_update_only_charging') ?? false;
  set libraryUpdateOnlyCharging(bool value) {
    unawaited(_prefs?.setBool('library_update_only_charging', value));
    notifyListeners();
  }

  /// Timeout in seconds for the initial onboarding sync.
  /// Defaults to 45 seconds. Can be increased for slow connections/large libraries.
  /// Stable SyncEngine device id (UUID). Persisted so `lastSync_<id>` meta is
  /// per-device instead of the shared literal `default_device` (ISS-062).
  String? get syncDeviceId {
    final v = _prefs?.getString('sync_device_id');
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  set syncDeviceId(String? value) {
    if (value == null || value.trim().isEmpty) {
      unawaited(_prefs?.remove('sync_device_id'));
    } else {
      unawaited(_prefs?.setString('sync_device_id', value.trim()));
    }
    notifyListeners();
  }

  int get initialSyncTimeoutSeconds => _prefs?.getInt('initial_sync_timeout_seconds') ?? 45;
  set initialSyncTimeoutSeconds(int value) {
    unawaited(_prefs?.setInt('initial_sync_timeout_seconds', value));
    notifyListeners();
  }

  /// Maximum seconds to wait for server library update jobs to complete.
  /// Defaults to 45 seconds (30 * 1.5s polling intervals).
  int get serverUpdatePollTimeoutSeconds => _prefs?.getInt('server_update_poll_timeout_seconds') ?? 45;
  set serverUpdatePollTimeoutSeconds(int value) {
    unawaited(_prefs?.setInt('server_update_poll_timeout_seconds', value));
    notifyListeners();
  }

  bool get newChapterNotificationsEnabled => _prefs?.getBool('new_chapter_notifications_enabled') ?? true;
  set newChapterNotificationsEnabled(bool value) {
    unawaited(_prefs?.setBool('new_chapter_notifications_enabled', value));
    notifyListeners();
  }

  int get lastLibraryUpdateTimestamp => _prefs?.getInt('last_library_update_timestamp') ?? 0;
  set lastLibraryUpdateTimestamp(int value) {
    unawaited(_prefs?.setInt('last_library_update_timestamp', value));
    notifyListeners();
  }

  // ── EXTENSIONS & REPOS ───────────────────────────────────
  bool get autoUpdateJsSources => _prefs?.getBool('auto_update_js_sources') ?? true;
  set autoUpdateJsSources(bool value) {
    unawaited(_prefs?.setBool('auto_update_js_sources', value));
    notifyListeners();
  }

  List<String> get customRepos => _prefs?.getStringList('custom_repos') ?? [];

  Future<void> addCustomRepo(String url) async {
    final normalized = RepoManager.normalizeRepoUrl(url);
    if (normalized.isEmpty) return;
    final list = List<String>.from(customRepos);
    final already = list.any((existing) => RepoManager.normalizeRepoUrl(existing) == normalized);
    if (!already) {
      list.add(normalized);
      await _prefs?.setStringList('custom_repos', list);
      RepoManager.instance.addUserRepo(RepoManager.deriveRepoTitle(normalized), normalized);
      notifyListeners();
    }
  }

  Future<void> removeCustomRepo(String url) async {
    final normalized = RepoManager.normalizeRepoUrl(url);
    final list = List<String>.from(customRepos)
      ..removeWhere((existing) => existing == url || RepoManager.normalizeRepoUrl(existing) == normalized);
    await _prefs?.setStringList('custom_repos', list);
    RepoManager.instance.removeUserRepo(normalized);
    notifyListeners();
  }

  // ── GENERAL SETTINGS ──────────────────────────────────────
  String get appLocale => _prefs?.getString('app_locale') ?? 'en';
  set appLocale(String value) {
    unawaited(_prefs?.setString('app_locale', value));
    notifyListeners();
  }

  String get startScreen => _prefs?.getString('start_screen') ?? 'Library';
  set startScreen(String value) {
    unawaited(_prefs?.setString('start_screen', value));
    notifyListeners();
  }

  bool get confirmExit => _prefs?.getBool('confirm_exit') ?? false;
  set confirmExit(bool value) {
    unawaited(_prefs?.setBool('confirm_exit', value));
    notifyListeners();
  }

  int get networkTimeoutSeconds => _prefs?.getInt('network_timeout_seconds') ?? 30;
  set networkTimeoutSeconds(int value) {
    unawaited(_prefs?.setInt('network_timeout_seconds', value));
    notifyListeners();
  }

  // ── AUTO-SCROLL SETTINGS ──────────────────────────────────
  double get defaultAutoScrollSpeed => _prefs?.getDouble('default_auto_scroll_speed') ?? 50.0;
  set defaultAutoScrollSpeed(double value) {
    unawaited(_prefs?.setDouble('default_auto_scroll_speed', value));
    notifyListeners();
  }

  bool get autoScrollPauseOnTouch => _prefs?.getBool('auto_scroll_pause_on_touch') ?? true;
  set autoScrollPauseOnTouch(bool value) {
    unawaited(_prefs?.setBool('auto_scroll_pause_on_touch', value));
    notifyListeners();
  }

  bool get autoScrollAutoNextChapter => _prefs?.getBool('auto_scroll_auto_next_chapter') ?? true;
  set autoScrollAutoNextChapter(bool value) {
    unawaited(_prefs?.setBool('auto_scroll_auto_next_chapter', value));
    notifyListeners();
  }

  bool get autoScrollShowFloatingHud => _prefs?.getBool('auto_scroll_show_floating_hud') ?? true;
  set autoScrollShowFloatingHud(bool value) {
    unawaited(_prefs?.setBool('auto_scroll_show_floating_hud', value));
    notifyListeners();
  }

  bool get autoScrollSmoothEaseIn => _prefs?.getBool('auto_scroll_smooth_ease_in') ?? true;
  set autoScrollSmoothEaseIn(bool value) {
    unawaited(_prefs?.setBool('auto_scroll_smooth_ease_in', value));
    notifyListeners();
  }

  // ── METRON.CLOUD TRACKING ──────────────────────────────────
  /// Auto-scrobble issues to Metron when a chapter finishes reading.
  bool get metronAutoScrobble => _prefs?.getBool('metron_auto_scrobble') ?? true;
  set metronAutoScrobble(bool value) {
    unawaited(_prefs?.setBool('metron_auto_scrobble', value));
    notifyListeners();
  }

  // `metronAutoMatch` removed (UIX-13, decision a): nothing ever performed the
  // auto-match. Legacy `metron_auto_match` pref is left unread.
}

