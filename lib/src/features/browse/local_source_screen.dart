// IMP-002: browse entry for the on-device Local source (folders and CBZ).
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models/manga.dart';
import '../../core/engine/local_source_service.dart';

class LocalSourceScreen extends StatefulWidget {
  const LocalSourceScreen({super.key});

  @override
  State<LocalSourceScreen> createState() => _LocalSourceScreenState();
}

class _LocalSourceScreenState extends State<LocalSourceScreen> {
  final _svc = LocalSourceService.instance;
  List<Manga> _manga = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final list = await _svc.listLibrary();
    if (!mounted) return;
    setState(() {
      _manga = list;
      _loading = false;
    });
  }

  Future<void> _pickRoot() async {
    final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose local manga folder');
    if (!mounted || dir == null || dir.isEmpty) return;
    await _svc.setRoot(dir);
    await _scan();
  }

  Future<void> _scan() async {
    if (_svc.root == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _svc.scan();
    if (!mounted) return;
    _error = res.error;
    await _load();
    if (!mounted || res.error != null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${res.manga} series, ${res.addedChapters} new, ${res.removedChapters} removed chapters'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final root = _svc.root;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local source'),
        actions: [
          if (root != null)
            IconButton(
              key: const ValueKey('localRescan'),
              tooltip: 'Rescan',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : _scan,
            ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            key: const ValueKey('localRootTile'),
            leading: const Icon(Icons.folder_rounded),
            title: const Text('Folder'),
            subtitle: Text(root ?? 'Not set: pick a folder with one sub-folder or CBZ set per series',
                style: TextStyle(color: cs.onSurfaceVariant)),
            trailing: const Icon(Icons.edit_rounded),
            onTap: _pickRoot,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(_error!, key: const ValueKey('localScanError'), style: TextStyle(color: cs.error)),
            ),
          Divider(height: 1, color: cs.outlineVariant),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _manga.isEmpty
                    ? Center(
                        child: Text(root == null ? 'Pick a folder to get started' : 'No series found in this folder',
                            style: TextStyle(color: cs.onSurfaceVariant)),
                      )
                    : ListView.builder(
                        itemCount: _manga.length,
                        itemBuilder: (context, i) {
                          final m = _manga[i];
                          return ListTile(
                            leading: const Icon(Icons.menu_book_rounded),
                            title: Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () => unawaited(context.push('/manga/${m.serverId}')),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
