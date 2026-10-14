// IMP-004: offline "More like this" row (shared genres, author, artist).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models/manga.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/recommendations.dart';

typedef RecommendationLoader = Future<List<MangaRecommendation>> Function(Manga target);

class MoreLikeThisRow extends StatefulWidget {
  const MoreLikeThisRow({super.key, required this.manga, this.loader});
  final Manga manga;

  /// Test seam; defaults to [moreLikeThis].
  final RecommendationLoader? loader;

  @override
  State<MoreLikeThisRow> createState() => _MoreLikeThisRowState();
}

class _MoreLikeThisRowState extends State<MoreLikeThisRow> {
  late Future<List<MangaRecommendation>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(MoreLikeThisRow old) {
    super.didUpdateWidget(old);
    if (old.manga.serverId != widget.manga.serverId) _future = _load();
  }

  Future<List<MangaRecommendation>> _load() async {
    try {
      return await (widget.loader ?? moreLikeThis)(widget.manga);
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<List<MangaRecommendation>>(
      future: _future,
      builder: (context, snap) {
        final recs = snap.data ?? const <MangaRecommendation>[];
        if (recs.isEmpty) return const SizedBox.shrink();
        return Padding(
          key: const ValueKey('moreLikeThisRow'),
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('More like this', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final r = recs[i];
                    final m = r.manga;
                    return SizedBox(
                      width: 104,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => unawaited(context.push('/manga/${m.serverId}')),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MangaCoverImage(
                                mangaServerId: m.serverId,
                                thumbnailUrl: m.thumbnailUrl,
                                sourceName: m.sourceName,
                                width: 104,
                                height: 140,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                            if (r.reasons.isNotEmpty)
                              Text(r.reasons.first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
