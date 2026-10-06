// UIS-P2-B: tablet rail extras (Kotatsu-style "Continue reading" header
// action + Downloads/Stats trailing items that follow the extended state).
import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';

/// Rail is allowed to show labels (NavigationRail.extended) from this
/// window width when the "Expanded Sidebar" setting is on (Android + desktop).
/// Extended rail is 200 dp, so 840 keeps ≥ 640 dp for content.
const double sunfireRailExtendedMinWidth = 840.0;

/// Resolves the route "Continue reading" should open: the most recent
/// in-progress library chapter, else the most recently read one. Runs only
/// on tap (never in build). Returns null when there is nothing to resume.
Future<String?> resolveContinueReadingRoute() async {
  final db = IsarService.instance;
  var chapters = await db.getInProgressChapters(limit: 1);
  if (chapters.isEmpty) chapters = await db.getRecentChapters(limit: 1);
  if (chapters.isEmpty) return null;
  final ch = chapters.first;
  return '/reader/${ch.serverId != 0 ? ch.serverId : ch.id}';
}

/// Kotatsu-style FAB for the rail header. Extended rail → labelled FAB,
/// collapsed rail → icon FAB with a tooltip.
class SunfireContinueReadingButton extends StatefulWidget {
  const SunfireContinueReadingButton({
    super.key,
    required this.extended,
    required this.onOpen,
    this.resolveRoute = resolveContinueReadingRoute,
  });

  final bool extended;
  final ValueChanged<String> onOpen;
  final Future<String?> Function() resolveRoute;

  static const String label = 'Continue reading';
  static const String emptyMessage = 'Nothing to continue yet';

  @override
  State<SunfireContinueReadingButton> createState() =>
      _SunfireContinueReadingButtonState();
}

class _SunfireContinueReadingButtonState
    extends State<SunfireContinueReadingButton> {
  bool _busy = false;

  Future<void> _onPressed() async {
    if (_busy) return;
    setState(() => _busy = true);
    String? route;
    try {
      route = await widget.resolveRoute();
    } catch (_) {
      route = null;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (route == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(SunfireContinueReadingButton.emptyMessage)),
      );
      return;
    }
    widget.onOpen(route);
  }

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.play_arrow_rounded);
    if (widget.extended) {
      return Tooltip(
        message: SunfireContinueReadingButton.label,
        child: FloatingActionButton.extended(
          heroTag: null,
          elevation: 0,
          onPressed: _busy ? null : _onPressed,
          icon: icon,
          label: const Text(SunfireContinueReadingButton.label),
        ),
      );
    }
    return FloatingActionButton(
      heroTag: null,
      elevation: 0,
      tooltip: SunfireContinueReadingButton.label,
      onPressed: _busy ? null : _onPressed,
      child: icon,
    );
  }
}

/// Downloads + Reading Stats as NavigationRail `trailing` items, pinned to
/// the bottom of the rail (trailingAtBottom). Badge shows active (downloading/queued) count.
/// Labels appear when the rail is extended; tooltips stay in both modes.
class SunfireRailTrailing extends StatelessWidget {
  const SunfireRailTrailing({
    super.key,
    required this.extended,
    required this.activeDownloads,
    required this.onDownloads,
    required this.onStats,
  });

  final bool extended;
  final int activeDownloads;
  final VoidCallback onDownloads;
  final VoidCallback onStats;

  Widget _item(BuildContext context, String label, Widget icon, VoidCallback onTap) {
    if (!extended) {
      return IconButton(tooltip: label, onPressed: onTap, icon: icon);
    }
    return Tooltip(
      message: label,
      child: SizedBox(
        width: 176,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: onTap,
          icon: icon,
          label: Text(label, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = activeDownloads;
    // Pinned at the rail bottom via NavigationRail.trailingAtBottom.
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            extended ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          _item(
            context,
            'Downloads',
            Badge.count(
              count: n,
              isLabelVisible: n > 0,
              child: const Icon(Icons.download_rounded),
            ),
            onDownloads,
          ),
          _item(
            context,
            'Reading Stats',
            const Icon(Icons.insights_rounded),
            onStats,
          ),
        ],
      ),
    );
  }
}
