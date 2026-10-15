// R1.8: end-of-chapter transition card extracted from reader_screen.
import 'package:flutter/material.dart';

import '../../core/db/models/chapter.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';

/// Finished / next chapter card shown after the last page.
class ReaderChapterTransitionCard extends StatelessWidget {
  const ReaderChapterTransitionCard({
    super.key,
    required this.chapter,
    required this.nextChapter,
    required this.onReadNext,
  });

  final Chapter? chapter;
  final Chapter? nextChapter;
  final VoidCallback onReadNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      constraints: const BoxConstraints(maxWidth: 460),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (chapter != null)
            _Section(
              label: 'Finished',
              chapter: chapter!,
              labelColor: primaryColor,
            ),
          const SizedBox(height: 28),
          if (nextChapter != null) ...[
            _Section(
              label: 'Next',
              chapter: nextChapter!,
              labelColor: primaryColor,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: onReadNext,
                child: const Text(
                  'Read Next Chapter',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ] else
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colorScheme.outlineVariant, width: 0.8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: primaryColor, size: 20),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "You're all caught up — there's no next chapter.",
                      style: TextStyle(fontSize: 13, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.chapter,
    required this.labelColor,
  });

  final String label;
  final Chapter chapter;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (chapter.isDownloaded) ...[
              Icon(Icons.check_circle_rounded, color: labelColor, size: 18),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                chapter.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (chapter.scanlator != null && chapter.scanlator!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              chapter.scanlator!,
              style: TextStyle(
                fontSize: 12,
                color: SunfireColors.contentTertiary,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
