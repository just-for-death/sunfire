// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_sizes.dart';
import '../../../features/manga_book/domain/manga/manga_model.dart';
import '../../../theme/komikku_ui_tokens.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../providers/manga_cover_providers.dart';

class MangaBadgesRow extends ConsumerWidget {
  const MangaBadgesRow({
    super.key,
    required this.manga,
    this.needSpacer = false,
    this.showCountBadges = false,
    this.padding,
  });
  final MangaDto manga;
  final bool needSpacer;
  final bool showCountBadges;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedBadge = ref.watch(downloadedBadgeProvider).ifNull(true);
    final unreadBadge = ref.watch(unreadBadgeProvider).ifNull(true);
    final languageBadge = ref.watch(languageBadgeProvider).ifNull(false);
    final sourceBadge = ref.watch(sourceBadgeProvider).ifNull(false);
    return Padding(
      padding: padding ?? KEdgeInsets.a8.size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!showCountBadges && manga.inLibrary.ifNull())
            ClipRRect(
              borderRadius: KBorderRadius.r8.radius,
              child: MangaBadge(
                icon: Icons.collections_bookmark_rounded,
                color: context.theme.colorScheme.secondaryContainer,
                textColor: context.theme.colorScheme.onSecondaryContainer,
              ),
            ),
          if (showCountBadges) ...[
            ClipRRect(
              borderRadius: KBorderRadius.r8.radius,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (manga.unreadCount.isGreaterThan(0) && unreadBadge)
                    MangaBadge(
                      text: "${manga.unreadCount.getValueOnNullOrNegative()}",
                      color: context.theme.colorScheme.secondaryContainer,
                      textColor: context.theme.colorScheme.onSecondaryContainer,
                    ),
                  if (manga.downloadCount.isGreaterThan(0) && downloadedBadge)
                    MangaBadge(
                      text: "${manga.downloadCount.getValueOnNullOrNegative()}",
                      color: context.theme.colorScheme.tertiaryContainer,
                      textColor: context.theme.colorScheme.onTertiaryContainer,
                    ),
                ],
              ),
            ),
            if (needSpacer) const Spacer(),
            if (manga.source != null) ...[
              if (sourceBadge)
                ClipRRect(
                  borderRadius: KBorderRadius.r8.radius,
                  child: MangaBadge(
                    text: manga.source!.name,
                    color: context.theme.colorScheme.secondaryContainer,
                    textColor: context.theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              if (manga.source?.lang.isNotBlank == true && languageBadge)
                ClipRRect(
                  borderRadius: KBorderRadius.r8.radius,
                  child: MangaBadge(
                    text: manga.source!.lang.toUpperCase(),
                    color: context.theme.colorScheme.tertiaryContainer,
                    textColor: context.theme.colorScheme.onTertiaryContainer,
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class MangaBadge extends StatelessWidget {
  const MangaBadge({
    super.key,
    this.text,
    this.icon,
    required this.color,
    required this.textColor,
  }) : assert(text != null || icon != null);
  final String? text;
  final IconData? icon;
  final Color color;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: color,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KomikkuUiTokens.space8,
          vertical: KomikkuUiTokens.space4,
        ),
        child: text.isNotBlank
            ? Text(
                text!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(icon, color: textColor, size: 16),
      ),
    );
  }
}
