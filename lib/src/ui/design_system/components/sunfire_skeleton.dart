// sunfire_skeleton.dart
//
// S6.1: Skeleton loading placeholders (shimmer cards, list rows, grids).
//
// Used by Library (grid), History/Updates (rows) instead of bare spinners
// on cold start, so first paint already shows layout shape.

library;

import 'package:flutter/material.dart';

import '../tokens/sunfire_motion.dart';
import '../tokens/sunfire_spacing.dart';

/// Shimmer base: animated opacity pulse over a rounded box.
class SunfireShimmerBox extends StatefulWidget {
  const SunfireShimmerBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = SunfireRadius.sm,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SunfireShimmerBox> createState() => _SunfireShimmerBoxState();
}

class _SunfireShimmerBoxState extends State<SunfireShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SunfireDuration.ambient,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base.withValues(
              alpha: 0.5 + 0.3 * _controller.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton manga card (cover + title lines) for library grids.
class SunfireMangaCardSkeleton extends StatelessWidget {
  const SunfireMangaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SunfireShimmerBox(
            height: double.infinity,
            borderRadius: SunfireRadius.md,
          ),
        ),
        SizedBox(height: SunfireSpacing.xs),
        SunfireShimmerBox(height: 12),
        SizedBox(height: SunfireSpacing.xs),
        SunfireShimmerBox(width: 80, height: 10),
      ],
    );
  }
}

/// Skeleton grid matching the library layout (S6.1).
class SunfireSkeletonGrid extends StatelessWidget {
  const SunfireSkeletonGrid({
    super.key,
    required this.crossAxisCount,
    required this.childAspectRatio,
    this.itemCount = 12,
  });

  final int crossAxisCount;
  final double childAspectRatio;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(SunfireSpacing.lg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: SunfireSpacing.cardGap,
        mainAxisSpacing: SunfireSpacing.md,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          const SunfireMangaCardSkeleton(),
    );
  }
}

/// Skeleton list row (chapters, history, updates).
class SunfireListRowSkeleton extends StatelessWidget {
  const SunfireListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: SunfireSpacing.xs),
      child: Row(
        children: [
          SunfireShimmerBox(
              width: 48, height: 64, borderRadius: SunfireRadius.sm),
          SizedBox(width: SunfireSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SunfireShimmerBox(height: 14),
                SizedBox(height: SunfireSpacing.xs),
                SunfireShimmerBox(width: 140, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
