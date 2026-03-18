import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../utils/extensions/custom_extensions.dart';

/// A frosted-glass large-title app bar matching Aidoku/iOS 26 style.
/// Drops in as a SliverPersistentHeader in a CustomScrollView.
class GlassSliverAppBar extends StatelessWidget {
  const GlassSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.largeTitle = true,
  });

  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool largeTitle;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.theme.colorScheme;
    final topPad = MediaQuery.of(context).padding.top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _GlassAppBarDelegate(
        title: title,
        actions: actions ?? [],
        isDark: isDark,
        cs: cs,
        topPad: topPad,
        bottom: bottom,
        largeTitle: largeTitle,
      ),
    );
  }
}

class _GlassAppBarDelegate extends SliverPersistentHeaderDelegate {
  _GlassAppBarDelegate({
    required this.title,
    required this.actions,
    required this.isDark,
    required this.cs,
    required this.topPad,
    this.bottom,
    this.largeTitle = true,
  });

  final String title;
  final List<Widget> actions;
  final bool isDark;
  final ColorScheme cs;
  final double topPad;
  final PreferredSizeWidget? bottom;
  final bool largeTitle;

  double get _bottomHeight => bottom?.preferredSize.height ?? 0;

  @override
  double get minExtent => topPad + 52 + _bottomHeight;

  @override
  double get maxExtent =>
      largeTitle ? topPad + 100 + _bottomHeight : topPad + 52 + _bottomHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final showSmallTitle = t > 0.6;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.55 * t + 0.1)
                : Colors.white.withOpacity(0.72 * t + 0.1),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.08 * t)
                    : Colors.black.withOpacity(0.06 * t),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar row
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      // Small title fades in on scroll
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: showSmallTitle ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      ...actions,
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                // Large title fades out on scroll
                if (largeTitle)
                  AnimatedOpacity(
                    opacity: (1.0 - t * 2).clamp(0.0, 1.0),
                    duration: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_GlassAppBarDelegate old) =>
      old.title != title || old.isDark != isDark;
}

/// Glass card — frosted surface for cards, sheets, info panels
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.margin,
  });

  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final br = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.white.withOpacity(0.72),
              borderRadius: br,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.06),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
