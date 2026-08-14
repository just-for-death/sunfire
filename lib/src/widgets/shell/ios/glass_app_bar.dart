import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../utils/extensions/custom_extensions.dart';
import '../../../utils/platform/platform_ui.dart';

/// A frosted-glass large-title app bar matching Catalyst's iOS style.
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
  double get minExtent => topPad + 44 + _bottomHeight;

  @override
  double get maxExtent =>
      largeTitle ? topPad + 54 + _bottomHeight : topPad + 44 + _bottomHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final isExpanded = largeTitle && t < 0.5;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.7 + 0.2 * t)
                : Colors.white.withValues(alpha: 0.85 + 0.1 * t),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08 * t)
                    : Colors.black.withValues(alpha: 0.06 * t),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: isExpanded ? 52 : 44,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: isExpanded ? 28 : 17,
                            fontWeight:
                                isExpanded ? FontWeight.w700 : FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                            letterSpacing: isExpanded ? -0.5 : 0,
                          ),
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      ...actions,
                      const SizedBox(width: 8),
                    ],
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
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: br,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.06),
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

/// Frosted flexible space for [SliverAppBar] on iOS.
Widget? glassAppBarFlexibleSpace(BuildContext context) {
  if (!isCupertinoPlatform) return null;
  final isDark = context.isDarkMode;
  return ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.72),
      ),
    ),
  );
}

/// Material [AppBar] on Android; frosted glass [AppBar] on iOS.
PreferredSizeWidget adaptiveGlassAppBar({
  required BuildContext context,
  Widget? title,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
  Widget? leading,
  bool automaticallyImplyLeading = true,
  bool centerTitle = false,
  double? titleSpacing,
  double? elevation,
}) {
  if (!isCupertinoPlatform) {
    return AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      elevation: elevation,
    );
  }

  final isDark = context.isDarkMode;
  return AppBar(
    title: title,
    actions: actions,
    bottom: bottom,
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    centerTitle: centerTitle,
    titleSpacing: titleSpacing,
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.72),
        ),
      ),
    ),
  );
}
