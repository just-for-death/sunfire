// IMP-028: GlobalKey-free lookup of laid-out webtoon list items.
//
// Each list item is wrapped in a [WebtoonItemSlot] that registers its own
// BuildContext under its item index while mounted. Visibility detection and
// jumps read positions through the registry, so the list no longer needs a
// GlobalKey per page (GlobalKeys are costly and keep elements alive).
import 'package:flutter/widgets.dart';

class WebtoonItemRegistry {
  final Map<int, BuildContext> _contexts = {};

  BuildContext? contextOf(int index) {
    final ctx = _contexts[index];
    return (ctx != null && ctx.mounted) ? ctx : null;
  }

  /// Mounted item indices (unordered).
  Iterable<int> get indices => _contexts.keys;

  void register(int index, BuildContext context) => _contexts[index] = context;

  /// Removes [index] only if it still belongs to [context] (a slot that moved
  /// to another index must not delete the new owner's entry).
  void unregister(int index, BuildContext context) {
    if (identical(_contexts[index], context)) _contexts.remove(index);
  }

  /// After trimming [removed] leading items: re-key so lookups stay valid
  /// until the slots re-register on the next build.
  void shift(int removed) {
    if (removed <= 0) return;
    final shifted = <int, BuildContext>{
      for (final e in _contexts.entries)
        if (e.key >= removed) e.key - removed: e.value,
    };
    _contexts
      ..clear()
      ..addAll(shifted);
  }

  void clear() => _contexts.clear();
}

/// Registers its context in [registry] under [index] while mounted.
class WebtoonItemSlot extends StatefulWidget {
  const WebtoonItemSlot({
    super.key,
    required this.index,
    required this.registry,
    required this.child,
  });

  final int index;
  final WebtoonItemRegistry? registry;
  final Widget child;

  @override
  State<WebtoonItemSlot> createState() => _WebtoonItemSlotState();
}

class _WebtoonItemSlotState extends State<WebtoonItemSlot> {
  @override
  void initState() {
    super.initState();
    widget.registry?.register(widget.index, context);
  }

  @override
  void didUpdateWidget(WebtoonItemSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || !identical(oldWidget.registry, widget.registry)) {
      oldWidget.registry?.unregister(oldWidget.index, context);
      widget.registry?.register(widget.index, context);
    }
  }

  @override
  void dispose() {
    widget.registry?.unregister(widget.index, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
