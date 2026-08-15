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

  // ── READER SETTINGS ──────────────────────────────────────
  String get readingMode => _prefs?.getString('reading_mode') ?? 'Webtoon';
  set readingMode(String value) {
    _prefs?.setString('reading_mode', value);
    notifyListeners();
  }

  String get readingDirection => _prefs?.getString('reading_direction') ?? 'Vertical';
  set readingDirection(String value) {
    _prefs?.setString('reading_direction', value);
    notifyListeners();
  }

  bool get volumeKeyTurn => _prefs?.getBool('volume_key_turn') ?? true;
  set volumeKeyTurn(bool value) {
    _prefs?.setBool('volume_key_turn', value);
    notifyListeners();
  }

  bool get cropBorders => _prefs?.getBool('crop_borders') ?? true;
  set cropBorders(bool value) {
    _prefs?.setBool('crop_borders', value);
    notifyListeners();
  }

  bool get tapZonesEnabled => _prefs?.getBool('tap_zones_enabled') ?? true;
  set tapZonesEnabled(bool value) {
    _prefs?.setBool('tap_zones_enabled', value);
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

  // ── LIBRARY & CATEGORIES ─────────────────────────────────
  int get defaultCategoryId => _prefs?.getInt('default_category_id') ?? 0;
  set defaultCategoryId(int value) {
    _prefs?.setInt('default_category_id', value);
    notifyListeners();
  }

  bool get showUnreadBadges => _prefs?.getBool('show_unread_badges') ?? true;
  set showUnreadBadges(bool value) {
    _prefs?.setBool('show_unread_badges', value);
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
