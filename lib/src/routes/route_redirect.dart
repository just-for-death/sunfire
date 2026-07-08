import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Maps `catalyst://manga/123/chapter/456` → `/manga/123/chapter/456` and
/// `catalyst://library/3` → `/library/3`.
String? deepLinkPathFromUri(Uri uri) {
  if (uri.scheme != 'catalyst') return null;

  final path = uri.path;
  switch (uri.host) {
    case 'manga':
      if (path.isEmpty || path == '/') return '/manga/0';
      return path.startsWith('/manga') ? path : '/manga$path';
    case 'library':
      if (path.isEmpty || path == '/') return '/library/0';
      return path.startsWith('/library') ? path : '/library$path';
    default:
      return null;
  }
}

/// Validates numeric path segments before [go_router_builder] calls [int.parse].
String? redirectPathForUri(Uri uri) {
  final segments = uri.pathSegments;
  if (segments.isEmpty) return null;

  final mangaIdx = segments.indexOf('manga');
  if (mangaIdx >= 0) {
    if (mangaIdx + 1 >= segments.length) {
      return '/manga/0/chapter/0';
    }
    final mangaIdStr = segments[mangaIdx + 1];
    if (int.tryParse(mangaIdStr) == null) {
      return '/manga/0/chapter/0';
    }

    if (mangaIdx + 2 < segments.length && segments[mangaIdx + 2] == 'chapter') {
      if (mangaIdx + 3 >= segments.length) {
        return '/manga/0/chapter/0';
      }
      final chapterIdStr = segments[mangaIdx + 3];
      if (int.tryParse(chapterIdStr) == null) {
        return '/manga/0/chapter/0';
      }
    }
  }

  final libraryIdx = segments.indexOf('library');
  if (libraryIdx >= 0 && libraryIdx + 1 < segments.length) {
    if (int.tryParse(segments[libraryIdx + 1]) == null) {
      return '/library/0';
    }
  }

  return null;
}

String? routeRedirect(BuildContext context, GoRouterState state) {
  final deepLink = deepLinkPathFromUri(state.uri);
  if (deepLink != null && state.uri.path != deepLink) {
    return deepLink;
  }
  return redirectPathForUri(deepLink != null ? Uri.parse(deepLink) : state.uri);
}
