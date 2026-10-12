// lib/src/features/library/tag_management_screen.dart
//
// L10.2: Custom tag CRUD UI (color-coded).

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../core/db/models/tag.dart';
import '../../core/services/tag_service.dart';
import '../../ui/design_system/components/components.dart'
    show SunfireButton, SunfireCard;

/// Manage user-defined library tags.
class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  bool _loading = true;
  List<Tag> _tags = const [];

  static const _palette = <String>[
    '#FF5722',
    '#E91E63',
    '#9C27B0',
    '#3F51B5',
    '#2196F3',
    '#009688',
    '#4CAF50',
    '#FF9800',
    '#795548',
    '#607D8B',
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final tags = await TagService.instance.getAllTags();
      if (mounted) setState(() => _tags = tags);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return const Color(0xFFFF5722);
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  Future<void> _showEditor({Tag? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var color = existing?.color ?? _palette.first;
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(existing == null ? 'New tag' : 'Edit tag'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g. Favorites',
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),
                  const Text('Color'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _palette.map((c) {
                      final selected = c.toLowerCase() == color.toLowerCase();
                      return InkWell(
                        onTap: () => setLocal(() => color = c),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _parseColor(c),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? Theme.of(ctx).colorScheme.onSurface
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(existing == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    final name = TagService.normalizeTagName(nameCtrl.text);
    nameCtrl.dispose();
    if (created != true || name == null || !mounted) return;

    if (existing == null) {
      final tag = await TagService.instance.createTag(name: name, color: color);
      if (!mounted) return;
      if (tag == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create tag')),
        );
        return;
      }
    } else {
      final ok = await TagService.instance
          .updateTag(existing, name: name, color: color);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update tag (duplicate name?)')),
        );
        return;
      }
    }
    await _reload();
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text(
          'Remove "${tag.name}" from the library and all assigned manga?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await TagService.instance.deleteTag(tag.id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Tags'),
        actions: [
          IconButton(
            tooltip: 'Add tag',
            onPressed: () => unawaited(_showEditor()),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tags.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No tags yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create color-coded tags to organize your library.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SunfireButton.primary(
                          label: 'Create tag',
                          onPressed: () => unawaited(_showEditor()),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tags.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tag = _tags[index];
                    return SunfireCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _parseColor(tag.color),
                          radius: 12,
                        ),
                        title: Text(tag.name),
                        subtitle: Text(tag.color),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  unawaited(_showEditor(existing: tag)),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => unawaited(_deleteTag(tag)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _tags.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => unawaited(_showEditor()),
              child: const Icon(Icons.add),
            ),
    );
  }
}
