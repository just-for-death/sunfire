import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Bounded disk cache for manga page images.
abstract final class MangaCacheManager {
  static const _key = 'catalystMangaImages';

  static final CacheManager instance = CacheManager(
    Config(
      _key,
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 400,
    ),
  );
}
