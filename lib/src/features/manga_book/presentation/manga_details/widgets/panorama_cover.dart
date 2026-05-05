import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../theme/komikku_ui_tokens.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../widgets/server_image.dart';

/// A widget that displays a panorama‑style cover header for a manga.
///
/// Uses a themed gradient + cover overlay to keep title contrast readable.
class PanoramaCover extends HookConsumerWidget {
  const PanoramaCover({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.author,
  });

  final String imageUrl;
  final String title;
  final String? author;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = context.theme.colorScheme.primary;
    final secondary = context.theme.colorScheme.secondary;

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(KomikkuUiTokens.space24),
          bottomRight: Radius.circular(KomikkuUiTokens.space24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.35,
            child: ServerImage(
              imageUrl: imageUrl,
              size: const Size(double.infinity, double.infinity),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          // Title and author foreground.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (author != null && author!.isNotBlank) ...[
                const SizedBox(height: 4),
                Text(
                  author!,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
