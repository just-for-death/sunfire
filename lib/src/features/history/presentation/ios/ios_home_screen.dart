import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/server_image.dart';
import '../../../../widgets/shell/ios/glass_app_bar.dart';
import '../../domain/history_group.dart';
import '../../domain/history_item.dart';
import '../history_controller.dart';

class IOSHomeScreen extends ConsumerWidget {
  const IOSHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyGroups = ref.watch(filteredHistoryGroupsProvider);
    final historyState = ref.watch(readingHistoryProvider);
    final isDark = context.isDarkMode;
    final cs = context.theme.colorScheme;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF2F2F7),
      extendBodyBehindAppBar: true,
      body: historyState.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) => CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Glass large-title app bar
            GlassSliverAppBar(
              title: 'Home',
              actions: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.search,
                    color: cs.primary,
                  ),
                  onPressed: () => const GlobalSearchRoute().push(context),
                ),
              ],
            ),

            if (historyGroups.isNotEmpty) ...[
              // ── Continue Reading carousel
              _ContinueReadingCarousel(groups: historyGroups),

              // ── Recent section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              // ── Recent history list as glass cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                sliver: SliverList.builder(
                  itemCount: historyGroups.fold<int>(
                      0, (sum, g) => sum + g.items.length),
                  itemBuilder: (context, index) {
                    // Flatten all items across groups
                    final allItems =
                        historyGroups.expand((g) => g.items).toList();
                    if (index >= allItems.length) return null;
                    return _IOSHistoryTile(
                      item: allItems[index],
                      isDark: isDark,
                      cs: cs,
                      onRemove: () => ref
                          .read(readingHistoryProvider.notifier)
                          .removeFromHistory(allItems[index].id),
                    );
                  },
                ),
              ),
            ] else
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.book,
                          size: 56,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'No reading history',
                        style: TextStyle(
                          fontSize: 17,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Continue Reading carousel (Aidoku HomeBigScrollerView style)
class _ContinueReadingCarousel extends StatelessWidget {
  const _ContinueReadingCarousel({required this.groups});
  final List<HistoryGroup> groups;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final allItems = groups.expand((g) => g.items).take(10).toList();
    if (allItems.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Continue Reading',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: allItems.length,
              itemBuilder: (context, i) =>
                  _CarouselCard(item: allItems[i], isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.item, required this.isDark});
  final HistoryItemDto item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final progress = item.pageCount > 0
        ? (item.lastPageRead / item.pageCount).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => ReaderRoute(
        mangaId: item.mangaId,
        chapterId: item.id,
      ).push(context),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover
              ServerImage(
                imageUrl: item.manga.thumbnailUrl ?? '',
                fit: BoxFit.cover,
              ),
              // Bottom glass overlay with title + progress
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.manga.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 3,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.25),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── iOS-style history list tile with glass card
class _IOSHistoryTile extends StatelessWidget {
  const _IOSHistoryTile({
    required this.item,
    required this.isDark,
    required this.cs,
    required this.onRemove,
  });
  final HistoryItemDto item;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Cover
          GestureDetector(
            onTap: () => MangaRoute(mangaId: item.mangaId).push(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ServerImage(
                imageUrl: item.manga.thumbnailUrl ?? '',
                size: const Size(48, 68),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.manga.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Continue arrow
          GestureDetector(
            onTap: () => ReaderRoute(
              mangaId: item.mangaId,
              chapterId: item.id,
            ).push(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                CupertinoIcons.play_fill,
                size: 14,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
