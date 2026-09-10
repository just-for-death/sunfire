import 'package:shared_preferences/shared_preferences.dart';

/// Per-source overrides written by Source Configuration and read by QuickJS.
class SourcePreferences {
  SourcePreferences._();

  static final Map<String, String> _baseUrlCache = {};

  static String sourceKey(String sourceName) =>
      sourceName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  static String prefKey(String sourceName, String suffix) =>
      'pref_source_${sourceKey(sourceName)}_$suffix';

  static Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith('pref_source_') && key.endsWith('_base_url')) {
        final value = prefs.getString(key);
        if (value != null && value.trim().isNotEmpty) {
          _baseUrlCache[key] = value.trim();
        }
      }
    }
  }

  static Future<void> setCustomBaseUrl(String sourceName, String url) async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefKey(sourceName, 'base_url');
    final trimmed = url.trim();
    await prefs.setString(key, trimmed);
    if (trimmed.isEmpty) {
      _baseUrlCache.remove(key);
    } else {
      _baseUrlCache[key] = trimmed;
    }
  }

  static String? getCustomBaseUrl(String sourceName) {
    final key = prefKey(sourceName, 'base_url');
    final cached = _baseUrlCache[key];
    if (cached != null && cached.isNotEmpty) return cached;
    return null;
  }

  /// Applies a user mirror override onto extracted extension metadata.
  static Map<String, dynamic> applyToSourceMeta(String sourceName, Map<String, dynamic> meta) {
    final override = getCustomBaseUrl(sourceName);
    if (override == null || override.isEmpty) return meta;
    final copy = Map<String, dynamic>.from(meta);
    copy['baseUrl'] = override;
    return copy;
  }
}
