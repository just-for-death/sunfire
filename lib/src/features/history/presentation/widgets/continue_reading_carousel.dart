import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/server_image.dart';
import '../../domain/history_group.dart';
import '../../domain/history_item.dart';
import '../history_reader_navigation.dart';

/// Horizontal "Continue reading" row shared by iOS and Android history.
class ContinueReadingCarousel extends StatelessWidget {
  const ContinueReadingCarousel({
    super.key,
    required this.groups,
    this.useCupertinoStyle = false,
  });

  final List<HistoryGroup> groups;
  final bool useCupertinoStyle;

  @override
  Widget build(BuildContext context) {
    final allItems = inProgressHistoryItems(groups);
    if (allItems.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    final cs = context.theme.colorScheme;
    final titleStyle = useCupertinoStyle
        ? TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.isDarkMode ? Colors.white : Colors.black,
            letterSpacing: -0.3,
          )
        : context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          );

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              useCupertinoStyle ? 20 : 16,
              useCupertinoStyle ? 20 : 16,
              useCupertinoStyle ? 20 : 16,
              12,
            ),
            child: Text(context.l10n.historyContinueReading, style: titleStyle),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: allItems.length,
              itemBuilder: (context, i) => _CarouselCard(
                item: allItems[i],
                useCupertinoStyle: useCupertinoStyle,
                colorScheme: cs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselCard extends ConsumerWidget {
  const _CarouselCard({
    required this.item,
    required this.useCupertinoStyle,
    required this.colorScheme,
  });

  final HistoryItemDto item;
  final bool useCupertinoStyle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = historyItemReadProgress(item);
    final completed = historyItemIsCompleted(item);
    final radius = BorderRadius.circular(useCupertinoStyle ? 14 : 12);

    return Semantics(
      button: true,
      label: '${item.manga.title}, ${(progress * 100).round()}%',
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ServerImage(
                    imageUrl: item.manga.thumbnailUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
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
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.manga.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: Colors.white24,
                            color: completed
                                ? colorScheme.secondary
                                : colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: radius,
                  onTap: () => openReaderFromHistoryItem(context, ref, item),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
