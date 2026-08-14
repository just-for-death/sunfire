// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';

import '../../../constants/gen/assets.gen.dart';
import '../../../features/manga_book/domain/manga/manga_model.dart';
import '../../../features/manga_book/presentation/manga_thumbnail_viewer/manga_thumbnail_viewer.dart';
import '../../../theme/catalyst_typography.dart';
import '../../../theme/catalyst_ui_tokens.dart';
import '../../../utils/extensions/custom_extensions.dart';
import '../../server_image.dart';
import '../widgets/manga_badges.dart';

/// Cover tile used by every manga grid.
///
/// The cover fills the cell and the caption sits underneath it, so the artwork
/// is never covered by a title gradient.
class MangaCoverGridTile extends StatelessWidget {
  const MangaCoverGridTile({
    super.key,
    required this.manga,
    this.onPressed,
    this.onLongPress,
    this.showTitle = true,
    this.showBadges = true,
    this.showCountBadges = false,
    this.showDarkOverlay = false,
    this.isSelected = false,
  });
  final MangaDto manga;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool showCountBadges;
  final bool showTitle;
  final bool showBadges;
  final bool showDarkOverlay;
  final bool isSelected;

  void _openThumbnail(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        transitionDuration: CatalystUiTokens.durationStandard,
        reverseTransitionDuration: CatalystUiTokens.durationShort,
        pageBuilder: (context, _, __) =>
            MangaThumbnailViewer(imageUrl: manga.thumbnailUrl ?? ""),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: CatalystUiTokens.curveStandard,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    final cover = manga.thumbnailUrl.isNotBlank
        ? ServerImage(imageUrl: manga.thumbnailUrl ?? "")
        : Center(
            child: ImageIcon(
              AssetImage(Assets.icons.darkIcon.path),
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: CatalystUiTokens.coverRadius,
            child: ColoredBox(
              color: cs.surfaceContainer,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  cover,
                  if (showDarkOverlay)
                    ColoredBox(
                      color: cs.scrim.withValues(alpha: 0.4),
                    ),
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: onPressed ?? () => _openThumbnail(context),
                      onLongPress: onLongPress,
                    ),
                  ),
                  if (showBadges)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: MangaBadgesRow(
                          manga: manga,
                          showCountBadges: showCountBadges,
                        ),
                      ),
                    ),
                  if (isSelected)
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: CatalystUiTokens.coverRadius,
                          color: cs.primary.withValues(alpha: 0.28),
                          border: Border.all(color: cs.primary, width: 3),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              CatalystUiTokens.space8,
                            ),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: cs.primary,
                              child: Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: cs.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showTitle)
          SizedBox(
            height: CatalystUiTokens.gridTitleExtent,
            child: Padding(
              padding: const EdgeInsets.only(
                top: CatalystUiTokens.space4,
                left: CatalystUiTokens.space2,
                right: CatalystUiTokens.space2,
              ),
              child: Text(
                manga.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CatalystTypography.coverTitle.copyWith(
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
