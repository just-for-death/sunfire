import 'package:flutter/material.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../theme/catalyst_ui_tokens.dart';
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
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Text(
            group.getLocalizedTitle(context),
            style: context.theme.textTheme.labelLarge?.copyWith(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: mangaCoverGridDelegate(
            CatalystUiTokens.gridPreferredItemWidth,
            showTitle: false,
          ),
          itemCount: group.items.length,
          itemBuilder: (context, i) => HistoryItemTile(
            item: group.items[i],
            onRemove: () => onRemoveItem(group.items[i].id),
          ),
        ),
      ],
    );
  }
}
