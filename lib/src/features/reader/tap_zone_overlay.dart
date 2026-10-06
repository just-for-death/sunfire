import 'dart:async';

import 'package:flutter/material.dart';

import 'tap_zones.dart';

/// Brief translucent overlay that paints the active tap zones (Mihon-style).
///
/// Dismisses on tap or after [autoDismiss]. Does not consume navigation taps
/// once dismissed — parent should remove it from the tree.
class TapZoneOverlay extends StatefulWidget {
  const TapZoneOverlay({
    super.key,
    required this.preset,
    this.invert = false,
    this.rtlPaged = false,
    this.autoDismiss = const Duration(milliseconds: 1800),
    this.onDismissed,
  });

  final TapZonePreset preset;
  final bool invert;
  final bool rtlPaged;
  final Duration autoDismiss;
  final VoidCallback? onDismissed;

  @override
  State<TapZoneOverlay> createState() => _TapZoneOverlayState();
}

class _TapZoneOverlayState extends State<TapZoneOverlay> {
  double _opacity = 1;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _autoDismissTimer = Timer(widget.autoDismiss, _fadeOut);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _fadeOut() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    if (!mounted) return;
    setState(() => _opacity = 0);
  }

  Color _colorFor(TapZoneAction action) {
    switch (action) {
      case TapZoneAction.previous:
        return const Color(0x99FF9800);
      case TapZoneAction.next:
        return const Color(0x994CAF50);
      case TapZoneAction.menu:
        return const Color(0x664246F5);
    }
  }

  String _labelFor(TapZoneAction raw) {
    final action = applyTapZoneModifiers(
      raw,
      invert: widget.invert,
      rtlPaged: widget.rtlPaged,
    );
    switch (action) {
      case TapZoneAction.previous:
        return 'Prev';
      case TapZoneAction.next:
        return 'Next';
      case TapZoneAction.menu:
        return 'Menu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final regions = tapZoneRegions(widget.preset);
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 280),
      onEnd: () {
        if (_opacity == 0) widget.onDismissed?.call();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _fadeOut,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              children: [
                for (final r in regions)
                  Positioned(
                    left: r.$2 * w,
                    top: r.$3 * h,
                    width: (r.$4 - r.$2) * w,
                    height: (r.$5 - r.$3) * h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _colorFor(r.$1),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Center(
                        child: Text(
                          _labelFor(r.$1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 28,
                  child: Text(
                    'Tap zones · ${widget.preset.settingsLabel}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
