import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/sync/graphql_client_service.dart';

/// Opens a server-side filter sheet (ISS-079 / B4). Returns applied changes
/// (empty list = reset / none), or null if cancelled.
Future<List<SourceFilterChange>?> showSourceServerFiltersSheet(
  BuildContext context, {
  required String sourceId,
  List<SourceFilterChange>? initialChanges,
}) async {
  return showModalBottomSheet<List<SourceFilterChange>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _SourceServerFiltersSheet(
      sourceId: sourceId,
      initialChanges: initialChanges ?? const [],
    ),
  );
}

class _SourceServerFiltersSheet extends StatefulWidget {
  const _SourceServerFiltersSheet({required this.sourceId, required this.initialChanges});
  final String sourceId;
  final List<SourceFilterChange> initialChanges;

  @override
  State<_SourceServerFiltersSheet> createState() => _SourceServerFiltersSheetState();
}

class _SourceServerFiltersSheetState extends State<_SourceServerFiltersSheet> {
  bool _loading = true;
  List<SourceFilter> _filters = const [];
  final Map<int, Object?> _values = {};

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final data = await GraphQLClientService.instance.fetchSourceFiltersAndPreferences(widget.sourceId);
    if (!mounted) return;
    setState(() {
      _filters = data?.filters ?? const [];
      for (final f in _filters) {
        _values[f.position] = _defaultFor(f);
      }
      // Overlay prior applied changes roughly for checkBox/text/select/triState/sort.
      for (final c in widget.initialChanges) {
        if (c.checkBoxState != null) _values[c.position] = c.checkBoxState;
        if (c.triState != null) _values[c.position] = c.triState;
        if (c.textState != null) _values[c.position] = c.textState;
        if (c.selectState != null) _values[c.position] = c.selectState;
        if (c.sortState != null) _values[c.position] = c.sortState;
      }
      _loading = false;
    });
  }

  Object? _defaultFor(SourceFilter f) {
    switch (f.kind) {
      case SourceFilterKind.checkBox:
        return f.checkBoxDefault ?? false;
      case SourceFilterKind.triState:
        return f.triStateDefault ?? TriStateValue.ignore;
      case SourceFilterKind.text:
        return f.textDefault ?? '';
      case SourceFilterKind.select:
        return f.selectDefault ?? 0;
      case SourceFilterKind.sort:
        return f.sortDefault ?? const SortSelectionValue(index: 0, ascending: true);
      default:
        return null;
    }
  }

  List<SourceFilterChange> _buildChanges() {
    final out = <SourceFilterChange>[];
    for (final f in _filters) {
      if (!f.isInteractive) continue;
      final v = _values[f.position];
      switch (f.kind) {
        case SourceFilterKind.checkBox:
          if (v is bool) out.add(SourceFilterChange.checkBox(f.position, v));
        case SourceFilterKind.triState:
          if (v is TriStateValue && v != TriStateValue.ignore) {
            out.add(SourceFilterChange.triState(f.position, v));
          }
        case SourceFilterKind.text:
          if (v is String && v.isNotEmpty) out.add(SourceFilterChange.text(f.position, v));
        case SourceFilterKind.select:
          if (v is int) out.add(SourceFilterChange.select(f.position, v));
        case SourceFilterKind.sort:
          if (v is SortSelectionValue) {
            out.add(SourceFilterChange.sort(f.position, index: v.index, ascending: v.ascending));
          }
        case SourceFilterKind.group:
          // Top-level group children: emit nested changes for interactive kids.
          for (final child in f.children) {
            if (!child.isInteractive) continue;
            final key = _groupKey(f.position, child.position);
            final cv = _values[key];
            SourceFilterChange? inner;
            switch (child.kind) {
              case SourceFilterKind.checkBox:
                if (cv is bool) inner = SourceFilterChange.checkBox(child.position, cv);
              case SourceFilterKind.triState:
                if (cv is TriStateValue && cv != TriStateValue.ignore) {
                  inner = SourceFilterChange.triState(child.position, cv);
                }
              case SourceFilterKind.text:
                if (cv is String && cv.isNotEmpty) inner = SourceFilterChange.text(child.position, cv);
              case SourceFilterKind.select:
                if (cv is int) inner = SourceFilterChange.select(child.position, cv);
              default:
                break;
            }
            if (inner != null) out.add(SourceFilterChange.group(f.position, inner));
          }
        default:
          break;
      }
    }
    return out;
  }

  int _groupKey(int groupPos, int childPos) => 100000 + groupPos * 1000 + childPos;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, <SourceFilterChange>[]),
                    child: const Text('Reset'),
                  ),
                  FilledButton(
                    key: const Key('source_server_filters_apply'),
                    onPressed: () => Navigator.pop(context, _buildChanges()),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                      children: [
                        for (final f in _filters) ..._tilesFor(f),
                        if (_filters.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('This source has no server filters.', textAlign: TextAlign.center),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _tilesFor(SourceFilter f, {int? groupPos}) {
    switch (f.kind) {
      case SourceFilterKind.header:
        return [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
            child: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ];
      case SourceFilterKind.separator:
        return [const Divider()];
      case SourceFilterKind.checkBox:
        final key = groupPos == null ? f.position : _groupKey(groupPos, f.position);
        final v = _values[key] == true;
        return [
          SwitchListTile(
            title: Text(f.name),
            value: v,
            onChanged: (nv) => setState(() => _values[key] = nv),
          ),
        ];
      case SourceFilterKind.triState:
        final key = groupPos == null ? f.position : _groupKey(groupPos, f.position);
        final v = _values[key] is TriStateValue ? _values[key] as TriStateValue : TriStateValue.ignore;
        return [
          ListTile(
            title: Text(f.name),
            subtitle: Text(v.wire),
            trailing: SegmentedButton<TriStateValue>(
              segments: const [
                ButtonSegment(value: TriStateValue.ignore, label: Text('—')),
                ButtonSegment(value: TriStateValue.include, label: Text('In')),
                ButtonSegment(value: TriStateValue.exclude, label: Text('Ex')),
              ],
              selected: {v},
              onSelectionChanged: (s) => setState(() => _values[key] = s.first),
            ),
          ),
        ];
      case SourceFilterKind.text:
        final key = groupPos == null ? f.position : _groupKey(groupPos, f.position);
        return [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              decoration: InputDecoration(labelText: f.name),
              controller: TextEditingController(text: '${_values[key] ?? ''}'),
              onChanged: (s) => _values[key] = s,
            ),
          ),
        ];
      case SourceFilterKind.select:
        final key = groupPos == null ? f.position : _groupKey(groupPos, f.position);
        final idx = _values[key] is int ? _values[key] as int : 0;
        return [
          ListTile(
            title: Text(f.name),
            trailing: DropdownButton<int>(
              value: idx.clamp(0, (f.values.isEmpty ? 1 : f.values.length) - 1),
              items: [
                for (var i = 0; i < f.values.length; i++)
                  DropdownMenuItem(value: i, child: Text(f.values[i])),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _values[key] = v);
              },
            ),
          ),
        ];
      case SourceFilterKind.sort:
        final key = f.position;
        final cur = _values[key] is SortSelectionValue
            ? _values[key] as SortSelectionValue
            : const SortSelectionValue(index: 0, ascending: true);
        return [
          ListTile(
            title: Text(f.name),
            subtitle: Text(f.values.isEmpty ? '' : f.values[cur.index.clamp(0, f.values.length - 1)]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: cur.index.clamp(0, (f.values.isEmpty ? 1 : f.values.length) - 1),
                  items: [
                    for (var i = 0; i < f.values.length; i++)
                      DropdownMenuItem(value: i, child: Text(f.values[i])),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _values[key] = SortSelectionValue(index: v, ascending: cur.ascending));
                  },
                ),
                IconButton(
                  icon: Icon(cur.ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () => setState(
                    () => _values[key] = SortSelectionValue(index: cur.index, ascending: !cur.ascending),
                  ),
                ),
              ],
            ),
          ),
        ];
      case SourceFilterKind.group:
        return [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          for (final c in f.children) ..._tilesFor(c, groupPos: f.position),
        ];
      default:
        return const [];
    }
  }
}
