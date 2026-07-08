import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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

String? routeRedirect(BuildContext context, GoRouterState state) =>
    redirectPathForUri(state.uri);
