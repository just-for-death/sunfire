import 'package:flutter/material.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../domain/history_group.dart';
import '../../domain/history_item.dart';
import 'history_item_tile.dart';

class HistoryGroupWidget extends StatelessWidget {
  const HistoryGroupWidget({
    super.key,
    required this.group,
    required this.onRemoveItem,
  });

  final HistoryGroup group;
  final Function(int chapterId) onRemoveItem;

  @override
  Widget build(BuildContext context) {
    if (group.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Futon-style section header
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            group.getLocalizedTitle(context),
            style: context.theme.textTheme.labelLarge?.copyWith(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Horizontal cover row — 3 per row grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: group.items.length,
          itemBuilder: (context, i) => HistoryItemTile(
            item: group.items[i],
            onRemove: () => onRemoveItem(group.items[i].id),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
