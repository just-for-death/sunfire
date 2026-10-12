// lib/src/features/library/manga_tag_editor_sheet.dart
//
// L10.2: Assign/remove custom tags on a manga.

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../core/db/models/tag.dart';
import '../../core/services/tag_service.dart';
import '../../ui/design_system/components/components.dart' show SunfireChip;

/// Bottom sheet to toggle tags on a single manga ([mangaServerId] = canonicalKey).
class MangaTagEditorSheet extends StatefulWidget {
  const MangaTagEditorSheet({
    super.key,
    required this.mangaServerId,
    required this.mangaTitle,
  });

  final int mangaServerId;
  final String mangaTitle;

  static Future<bool?> show(
    BuildContext context, {
    required int mangaServerId,
    required String mangaTitle,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => MangaTagEditorSheet(
        mangaServerId: mangaServerId,
        mangaTitle: mangaTitle,
      ),
    );
  }

  @override
  State<MangaTagEditorSheet> createState() => _MangaTagEditorSheetState();
}

class _MangaTagEditorSheetState extends State<MangaTagEditorSheet> {
  bool _loading = true;
  bool _dirty = false;
  List<Tag> _all = const [];
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await TagService.instance.getAllTags();
      final assigned =
          await TagService.instance.getTagsForManga(widget.mangaServerId);
      if (!mounted) return;
      setState(() {
        _all = all;
        _selected
          ..clear()
          ..addAll(assigned.map((t) => t.id));
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return const Color(0xFFFF5722);
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  Future<void> _toggle(Tag tag, bool selected) async {
    final ok = selected
        ? await TagService.instance.assignTag(widget.mangaServerId, tag.id)
        : await TagService.instance.removeTag(widget.mangaServerId, tag.id);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update "${tag.name}"')),
      );
      return;
    }
    setState(() {
      _dirty = true;
      if (selected) {
        _selected.add(tag.id);
      } else {
        _selected.remove(tag.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      widget.mangaTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _all.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No tags yet. Create some in Settings → Library → Custom Tags.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _all.map((tag) {
                                  final selected = _selected.contains(tag.id);
                                  return SunfireChip(
                                    label: tag.name,
                                    selected: selected,
                                    avatar: CircleAvatar(
                                      backgroundColor: _parseColor(tag.color),
                                      radius: 8,
                                    ),
                                    onSelected: (v) =>
                                        unawaited(_toggle(tag, v)),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _dirty),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
