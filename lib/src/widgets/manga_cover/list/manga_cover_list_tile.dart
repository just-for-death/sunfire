// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';

import '../../../constants/app_sizes.dart';
import '../../../features/manga_book/domain/manga/manga_model.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../server_image.dart';
import '../widgets/manga_badges.dart';

class MangaCoverListTile extends StatelessWidget {
  const MangaCoverListTile({
    super.key,
    required this.manga,
    this.onPressed,
    this.onLongPress,
    this.showBadges = true,
    this.showCountBadges = false,
    this.isSelected = false,
  });

  final MangaDto manga;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool showCountBadges;
  final bool showBadges;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final baseTile = InkWell(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: Row(
        children: [
          Padding(
            padding: KEdgeInsets.a8.size,
            child: ClipRRect(
              borderRadius: KBorderRadius.r8.radius,
              child: ServerImage(
                imageUrl: manga.thumbnailUrl ?? "",
                size: const Size(60, 80),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: KEdgeInsets.h8.size,
              child: Text(
                manga.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ),
          if (showBadges)
            MangaBadgesRow(manga: manga, showCountBadges: showCountBadges),
        ],
      ),
    );

    if (isSelected) {
      return Container(
        color: context.theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: context.theme.colorScheme.primary,
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: context.theme.colorScheme.onPrimary,
                ),
              ),
            ),
            Expanded(child: baseTile),
          ],
        ),
      );
    }
    return baseTile;
  }
}
