import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static SettingsService? _instance;
  SharedPreferences? _prefs;

  SettingsService._();

  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── MANGA DETAILS ────────────────────────────────────────
  bool get chapterSortAscending => _prefs?.getBool('chapter_sort_ascending') ?? false;
  set chapterSortAscending(bool value) {
    _prefs?.setBool('chapter_sort_ascending', value);
    notifyListeners();
  }

  // ── ONBOARDING & SERVER ──────────────────────────────────
  bool get onboardingCompleted => _prefs?.getBool('sunfire_onboarding_completed') ?? _prefs?.getBool('onboarding_completed') ?? false;
  set onboardingCompleted(bool value) {
    _prefs?.setBool('sunfire_onboarding_completed', value);
    _prefs?.setBool('onboarding_completed', value);
    notifyListeners();
  }

  String get serverUrl {
    final s = _prefs?.getString('server_url');
    if (s != null && s.isNotEmpty) return s;
    final sf = _prefs?.getString('sunfire_server_url');
    if (sf != null && sf.isNotEmpty) return sf;
    return 'http://localhost:4567';
  }
  set serverUrl(String value) {
    _prefs?.setString('server_url', value);
    _prefs?.setString('sunfire_server_url', value);
    notifyListeners();
  }

  /// FlareSolverr / Byparr proxy URL for Cloudflare bypass (e.g. http://192.168.1.x:8191/v1).
  /// Leave empty to disable.
  String get cfProxyUrl => _prefs?.getString('cf_proxy_url') ?? '';
  set cfProxyUrl(String value) {
    _prefs?.setString('cf_proxy_url', value.trim());
    notifyListeners();
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
  };

  String get accentColorName => _prefs?.getString('accent_color_name') ?? 'Sunfire Orange';
  set accentColorName(String value) {
    _prefs?.setString('accent_color_name', value);
    notifyListeners();
  }

  Color get accentColor => accentColors[accentColorName] ?? const Color(0xFFFF5722);

  // ── READER SETTINGS (MIHON PARITY) ───────────────────────
  String get readingMode => _prefs?.getString('reading_mode') ?? 'Long Strip';
  set readingMode(String value) {
    _prefs?.setString('reading_mode', value);
    notifyListeners();
  }

  String get readerTheme => _prefs?.getString('reader_theme') ?? 'Black';
  set readerTheme(String value) {
    _prefs?.setString('reader_theme', value);
    notifyListeners();
  }

  String get colorFilter => _prefs?.getString('color_filter') ?? 'None';
  set colorFilter(String value) {
    _prefs?.setString('color_filter', value);
    notifyListeners();
  }

  String get scaleType => _prefs?.getString('scale_type') ?? 'Fit Width';
  set scaleType(String value) {
    _prefs?.setString('scale_type', value);
    notifyListeners();
  }

  bool get tapZonesEnabled => _prefs?.getBool('tap_zones_enabled') ?? true;
  set tapZonesEnabled(bool value) {
    _prefs?.setBool('tap_zones_enabled', value);
    notifyListeners();
  }

  bool get invertTapZones => _prefs?.getBool('invert_tap_zones') ?? false;
  set invertTapZones(bool value) {
    _prefs?.setBool('invert_tap_zones', value);
    notifyListeners();
  }

  bool get seamlessTransitions => _prefs?.getBool('seamless_transitions') ?? true;
  set seamlessTransitions(bool value) {
    _prefs?.setBool('seamless_transitions', value);
    notifyListeners();
  }

  bool get volumeKeyTurn => _prefs?.getBool('volume_key_turn') ?? true;
  set volumeKeyTurn(bool value) {
    _prefs?.setBool('volume_key_turn', value);
    notifyListeners();
  }

  bool get cropBorders => _prefs?.getBool('crop_borders') ?? false;
  set cropBorders(bool value) {
    _prefs?.setBool('crop_borders', value);
    notifyListeners();
  }

  // ── APPEARANCE & THEMES ───────────────────────────────────
  String get themeMode => _prefs?.getString('theme_mode') ?? 'OLED Black';
  set themeMode(String value) {
    _prefs?.setString('theme_mode', value);
    notifyListeners();
  }

  bool get materialYouEnabled => _prefs?.getBool('material_you_enabled') ?? true;
  set materialYouEnabled(bool value) {
    _prefs?.setBool('material_you_enabled', value);
    notifyListeners();
  }

  String get dateFormat => _prefs?.getString('date_format') ?? 'YYYY-MM-DD';
  set dateFormat(String value) {
    _prefs?.setString('date_format', value);
    notifyListeners();
  }

  // ── LIBRARY & CATEGORIES (MIHON PARITY) ───────────────────
  String get libraryDisplayMode => _prefs?.getString('library_display_mode') ?? 'Comfortable Grid';
  set libraryDisplayMode(String value) {
    _prefs?.setString('library_display_mode', value);
    notifyListeners();
  }

  bool get showUnreadBadges => _prefs?.getBool('show_unread_badges') ?? true;
  set showUnreadBadges(bool value) {
    _prefs?.setBool('show_unread_badges', value);
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
    _prefs?.setStringList('selected_languages', langs);
    notifyListeners();
  }

  // ── STORAGE & DOWNLOADS ──────────────────────────────────
  bool get autoDownloadEnabled => _prefs?.getBool('auto_download_enabled') ?? false;
  set autoDownloadEnabled(bool value) {
    _prefs?.setBool('auto_download_enabled', value);
    notifyListeners();
  }

  int get autoDownloadCount => _prefs?.getInt('auto_download_count') ?? 3;
  set autoDownloadCount(int value) {
    _prefs?.setInt('auto_download_count', value);
    notifyListeners();
  }

  bool get autoDeleteRead => _prefs?.getBool('auto_delete_read') ?? true;
  set autoDeleteRead(bool value) {
    _prefs?.setBool('auto_delete_read', value);
    notifyListeners();
  }

  bool get downloadOnlyOnWifi => _prefs?.getBool('download_only_on_wifi') ?? true;
  set downloadOnlyOnWifi(bool value) {
    _prefs?.setBool('download_only_on_wifi', value);
    notifyListeners();
  }

  // ── LIBRARY & CATEGORY SETTINGS ──────────────────────────
  int? get defaultCategoryId => _prefs?.getInt('default_category_id');
  set defaultCategoryId(int? value) {
    if (value == null) {
      _prefs?.remove('default_category_id');
    } else {
      _prefs?.setInt('default_category_id', value);
    }
    notifyListeners();
  }

  String get defaultCategoryName => _prefs?.getString('default_category_name') ?? 'Default';
  set defaultCategoryName(String value) {
    _prefs?.setString('default_category_name', value);
    notifyListeners();
  }

  bool get showCategoryTabs => _prefs?.getBool('show_category_tabs') ?? true;
  set showCategoryTabs(bool value) {
    _prefs?.setBool('show_category_tabs', value);
    notifyListeners();
  }

  // ── EXTENSIONS & REPOS ───────────────────────────────────
  bool get autoUpdateJsSources => _prefs?.getBool('auto_update_js_sources') ?? true;
  set autoUpdateJsSources(bool value) {
    _prefs?.setBool('auto_update_js_sources', value);
    notifyListeners();
  }

  List<String> get customRepos => _prefs?.getStringList('custom_repos') ?? [];

  Future<void> addCustomRepo(String url) async {
    final list = List<String>.from(customRepos);
    if (!list.contains(url)) {
      list.add(url);
      await _prefs?.setStringList('custom_repos', list);
      notifyListeners();
    }
  }

  Future<void> removeCustomRepo(String url) async {
    final list = List<String>.from(customRepos);
    list.remove(url);
    await _prefs?.setStringList('custom_repos', list);
    notifyListeners();
  }
}
