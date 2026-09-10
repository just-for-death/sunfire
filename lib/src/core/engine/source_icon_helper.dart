import 'package:flutter/material.dart';

/// FOSS-safe source icon helpers. Avoid Google Favicon CDN (privacy / store policy).
/// Bundled icons live under `assets/icons/sources/` and are referenced as
/// `asset:assets/icons/sources/<key>.png`.
class SourceIconHelper {
  SourceIconHelper._();

  static final _googleFavicon = RegExp(
    r'google\.[^/]+/s2/favicons',
    caseSensitive: false,
  );

  /// Canonical bundled icon keys for shipped extensions.
  static const Map<String, String> bundledSourceKeys = {
    'weeb central': 'weeb_central',
    'weeb_central': 'weeb_central',
    'weebcentral': 'weeb_central',
    'mangapill': 'mangapill',
    'mangago': 'mangago',
    'mangahere': 'mangahere',
    'manga here': 'mangahere',
    'mangafreak': 'mangafreak',
    'manga freak': 'mangafreak',
    'nhentai': 'nhentai',
    'n hentai': 'nhentai',
    'ninehentai': 'ninehentai',
    '9hentai': 'ninehentai',
    'webtoons': 'webtoons',
    'webtoon': 'webtoons',
    'read comics online': 'read_comics_online',
    'read_comics_online': 'read_comics_online',
    'readcomiconline': 'read_comics_online',
  };

  static String assetPathForKey(String key) => 'assets/icons/sources/$key.png';

  static String assetUriForKey(String key) => 'asset:${assetPathForKey(key)}';

  static String? bundledAssetUriForName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final raw = name.trim().toLowerCase();
    final stripped = raw
        .replaceAll(RegExp(r'\([^)]*\)'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
    final compact = stripped.replaceAll(' ', '');
    final key = bundledSourceKeys[stripped] ??
        bundledSourceKeys[compact] ??
        bundledSourceKeys[raw];
    if (key == null) return null;
    return assetUriForKey(key);
  }

  /// True when [url] should not be fetched (privacy/CDN policy or known-bad path).
  static bool isUnusableIconUrl(String? url) {
    if (url == null || url.trim().isEmpty) return true;
    final u = url.trim();
    if (u.startsWith('asset:')) return false;
    if (_googleFavicon.hasMatch(u)) return true;
    if (u.contains('/javascript/icon/')) return true;
    return false;
  }

  static bool isAssetIcon(String? url) {
    final u = url?.trim() ?? '';
    return u.startsWith('asset:') || u.startsWith('assets/');
  }

  static String assetPathFromUri(String url) {
    final u = url.trim();
    if (u.startsWith('asset:')) return u.substring('asset:'.length);
    return u;
  }

  /// Returns a usable icon reference: `asset:…`, `http(s):…`, or empty.
  static String sanitizeIconUrl(String? url, {String? sourceName}) {
    if (url != null && url.trim().isNotEmpty) {
      final u = url.trim();
      if (u.startsWith('asset:') || u.startsWith('assets/')) {
        return u.startsWith('asset:') ? u : 'asset:$u';
      }
      if (!isUnusableIconUrl(u) &&
          (u.startsWith('http://') || u.startsWith('https://'))) {
        return u;
      }
    }
    return bundledAssetUriForName(sourceName) ?? '';
  }

  /// Prefer explicit URL, then bundled FOSS asset for [sourceName].
  static String resolveIcon({String? iconUrl, String? sourceName}) {
    final sanitized = sanitizeIconUrl(iconUrl, sourceName: sourceName);
    if (sanitized.isNotEmpty) return sanitized;
    return bundledAssetUriForName(sourceName) ?? '';
  }

  /// First letter (or `#`) for a local avatar when no network icon exists.
  static String letterAvatar(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    final rune = trimmed.runes.first;
    return String.fromCharCode(rune).toUpperCase();
  }
}

/// Renders a source icon from an `asset:` URI, http(s) URL, or letter fallback.
class SourceIconImage extends StatelessWidget {
  final String? iconUrl;
  final String name;
  final double size;
  final Color? fallbackColor;

  const SourceIconImage({
    super.key,
    required this.name,
    this.iconUrl,
    this.size = 36,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = fallbackColor ?? Theme.of(context).colorScheme.primary;
    final resolved = SourceIconHelper.resolveIcon(iconUrl: iconUrl, sourceName: name);
    final letter = SourceIconHelper.letterAvatar(name);

    Widget fallback() => Center(
          child: Text(
            letter,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.44,
            ),
          ),
        );

    if (resolved.isEmpty) return fallback();

    if (SourceIconHelper.isAssetIcon(resolved)) {
      return Image.asset(
        SourceIconHelper.assetPathFromUri(resolved),
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    return Image.network(
      resolved,
      fit: BoxFit.cover,
      width: size,
      height: size,
      cacheWidth: (size * 3).round(),
      cacheHeight: (size * 3).round(),
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
}
