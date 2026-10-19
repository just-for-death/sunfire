// iPad sidebar for chapter navigation in the reader.
//
// Shows a persistent side panel on tablet-width windows, replacing the
// bottom-sheet chapter selector. Uses the same data and callbacks as
// ReaderChapterSelectorSheet.
import 'package:flutter/material.dart';

import '../../core/db/models/chapter.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';

/// A persistent sidebar for chapter navigation on tablet-width windows.
///
/// Shows a scrollable list of sibling chapters with the current chapter
/// highlighted. Tapping a chapter calls [onSelect].
class ReaderChapterSidebar extends StatelessWidget {
  const ReaderChapterSidebar({
    super.key,
    required this.siblings,
    required this.current,
    required this.onSelect,
    this.width = 280.0,
  });

  final List<Chapter> siblings;
  final Chapter? current;
  final ValueChanged<Chapter> onSelect;
  final double width;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: SunfireColors.surface1,
        border: Border(
          right: BorderSide(
            color: SunfireColors.borderSubtle,
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chapters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SunfireColors.contentPrimary,
                  ),
                ),
                Text(
                  '${siblings.length} Total',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SunfireColors.contentTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: SunfireColors.borderSubtle),
          // Chapter list
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: siblings.length,
              itemBuilder: (context, index) {
                final ch = siblings[index];
                final isCurrent = (ch.id == current?.id) ||
                    (ch.serverId != 0 && ch.serverId == current?.serverId);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Material(
                    color: isCurrent
                        ? primaryColor.withValues(alpha: 0.15)
                        : SunfireColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SunfireRadius.md),
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
  }
}