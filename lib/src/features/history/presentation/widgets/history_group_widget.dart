import 'package:flutter/material.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../domain/history_group.dart';
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            group.getLocalizedTitle(context),
            style: context.theme.textTheme.titleSmall?.copyWith(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: group.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 82),
          itemBuilder: (context, i) => HistoryItemTile(
            key: ValueKey('history-item-${group.items[i].id}'),
            item: group.items[i],
            onRemove: () => onRemoveItem(group.items[i].id),
          ),
        ),
      ],
    );
  }
}
