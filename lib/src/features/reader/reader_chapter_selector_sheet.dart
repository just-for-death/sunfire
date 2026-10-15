// R1.8: chapter list sheet extracted from reader_screen.
import 'package:flutter/material.dart';

import '../../core/db/models/chapter.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
import 'reader_chapter_navigation.dart';

/// Modal chapter list for navigating siblings from the reader HUD.
class ReaderChapterSelectorSheet {
  ReaderChapterSelectorSheet._();

  static Future<void> show({
    required BuildContext context,
    required List<Chapter> siblings,
    required Chapter? current,
    required ValueChanged<Chapter> onSelect,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentIndex =
        current != null ? findSiblingChapterIndex(siblings, current) : -1;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: SunfireColors.surface1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            if (currentIndex > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  final targetOffset = (currentIndex * 58.0)
                      .clamp(0.0, scrollController.position.maxScrollExtent);
                  scrollController.jumpTo(targetOffset);
                }
              });
            }

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: SunfireColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chapters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: SunfireColors.contentPrimary,
                        ),
                      ),
                      Text(
                        '${siblings.length} Total',
                        style: const TextStyle(
                          color: SunfireColors.contentTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SunfireSpacing.md),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: siblings.length,
                      itemBuilder: (context, index) {
                        final ch = siblings[index];
                        final isCurrent = (ch.id == current?.id) ||
                            (ch.serverId != 0 &&
                                ch.serverId == current?.serverId);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Material(
                            color: isCurrent
                                ? primaryColor.withValues(alpha: 0.15)
                                : SunfireColors.borderSubtle,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isCurrent
                                    ? primaryColor.withValues(alpha: 0.6)
                                    : SunfireColors.borderDefault,
                                width: 0.8,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Text(
                                ch.name.isNotEmpty
                                    ? ch.name
                                    : 'Chapter ${ch.chapterNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isCurrent
                                      ? primaryColor
                                      : (ch.isRead
                                          ? SunfireColors.contentTertiary
                                          : SunfireColors.contentPrimary),
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: isCurrent
                                  ? Icon(Icons.check_circle_rounded,
                                      color: primaryColor, size: 18)
                                  : (ch.isRead
                                      ? const Icon(Icons.done_rounded,
                                          color: SunfireColors.contentTertiary, size: 16)
                                      : null),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                if (!isCurrent) onSelect(ch);
                              },
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
      },
    );
  }
}
