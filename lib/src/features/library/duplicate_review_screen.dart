// lib/src/features/library/duplicate_review_screen.dart
//
// L10.4: Duplicate Review Screen — UI for reviewing and confirming
// merge of detected duplicate manga entries.

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../core/db/models/manga.dart';
import '../../core/library/duplicate_detection_service.dart'
    show DuplicateDetectionService, DuplicateScanResult;
import '../../ui/design_system/components/components.dart'
    show SunfireCard;
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
import '../../ui/design_system/tokens/sunfire_typography.dart';

/// Duplicate review screen for reviewing and merging duplicates.
class DuplicateReviewScreen extends StatefulWidget {
  const DuplicateReviewScreen({super.key});

  @override
  State<DuplicateReviewScreen> createState() => _DuplicateReviewScreenState();
}

class _DuplicateReviewScreenState extends State<DuplicateReviewScreen> {
  bool _scanning = false;
  bool _merging = false;
  DuplicateScanResult? _result;
  final Set<int> _selectedGroups = {};

  @override
  void initState() {
    super.initState();
    unawaited(_runScan());
  }

  Future<void> _runScan() async {
    setState(() {
      _scanning = true;
      _result = null;
      _selectedGroups.clear();
    });

    try {
      final result = await DuplicateDetectionService.instance.scanForDuplicates();
      if (mounted) {
        setState(() => _result = result);
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _mergeSelected() async {
    if (_result == null || _selectedGroups.isEmpty) return;

    setState(() => _merging = true);
    int merged = 0;

    try {
      for (final group in _result!.groups) {
        if (!_selectedGroups.contains(group.canonical.id)) continue;
        await DuplicateDetectionService.instance.mergeGroup(group);
        merged++;
      }
    } finally {
      if (mounted) {
        setState(() {
          _merging = false;
          _selectedGroups.clear();
        });
        await _runScan();
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merged $merged duplicate group${merged == 1 ? "" : "s"}')),
      );
    }
  }

  Future<void> _mergeAll() async {
    if (_result == null) return;

    setState(() => _merging = true);
    int merged = 0;

    try {
      for (final group in _result!.groups) {
        await DuplicateDetectionService.instance.mergeGroup(group);
        merged++;
      }
    } finally {
      if (mounted) {
        setState(() {
          _merging = false;
          _selectedGroups.clear();
        });
        await _runScan();
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merged $merged duplicate group${merged == 1 ? "" : "s"}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicate Detection'),
        actions: [
          if (_result != null && !_scanning && !_merging) ...[
            TextButton.icon(
              icon: const Icon(Icons.check_circle_rounded),
              label: Text('Merge ${_selectedGroups.isEmpty ? _result!.groupCount : _selectedGroups.length}'),
              onPressed: _selectedGroups.isEmpty ? _mergeAll : _mergeSelected,
              style: TextButton.styleFrom(foregroundColor: cs.onPrimaryContainer),
            ),
            const SizedBox(width: SunfireSpacing.sm),
            if (_selectedGroups.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selectedGroups.clear()),
                child: const Text('Clear Selection'),
              ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _scanning || _merging ? null : _runScan,
            tooltip: 'Rescan',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_scanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: SunfireSpacing.lg),
            Text('Scanning library for duplicates...',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    if (_merging) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: SunfireSpacing.lg),
            Text('Merging duplicates...',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    if (_result == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.find_replace_rounded,
                size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: SunfireSpacing.lg),
            Text('No scan results',
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: SunfireSpacing.sm),
            FilledButton.icon(
              icon: const Icon(Icons.search_rounded),
              label: const Text('Start Scan'),
              onPressed: _runScan,
            ),
          ],
        ),
      );
    }

    final result = _result!;
    if (result.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded,
                size: 64, color: SunfireColors.success),
            const SizedBox(height: SunfireSpacing.lg),
            Text('No duplicates found!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: SunfireSpacing.sm),
            Text('Scanned ${result.totalMangaScanned} manga in ${result.scanDuration.inMilliseconds}ms',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: SunfireSpacing.lg),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Rescan'),
              onPressed: _runScan,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Groups Found',
                  value: result.groupCount.toString(),
                  icon: Icons.group_rounded,
                  color: SunfireColors.trackerAmber,
                ),
              ),
              Expanded(
                child: _SummaryTile(
                  label: 'Duplicates',
                  value: result.duplicateCount.toString(),
                  icon: Icons.content_copy_rounded,
                  color: SunfireColors.error,
                ),
              ),
              Expanded(
                child: _SummaryTile(
                  label: 'Scanned',
                  value: result.totalMangaScanned.toString(),
                  icon: Icons.library_books_rounded,
                  color: SunfireColors.trackerBlue,
                ),
              ),
            ],
          ),
        ),

        // Groups list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: result.groups.length,
            itemBuilder: (context, index) {
              final group = result.groups[index];
              final selected = _selectedGroups.contains(group.canonical.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SunfireCard(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedGroups.remove(group.canonical.id);
                    } else {
                      _selectedGroups.add(group.canonical.id);
                    }
                  }),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: selected,
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                _selectedGroups.add(group.canonical.id);
                              } else {
                                _selectedGroups.remove(group.canonical.id);
                              }
                            }),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.canonical.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Keep this • Merge ${group.duplicates.length} duplicate${group.duplicates.length == 1 ? "" : "s"}',
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SunfireSpacing.md),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text(group.reason),
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            labelStyle: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSecondaryContainer),
                          ),
                          Chip(
                            label: Text('${group.totalCount} total'),
                            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                            labelStyle: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onTertiaryContainer),
                          ),
                        ],
                      ),
                      const SizedBox(height: SunfireSpacing.md),
                      // Duplicate list
                      ...group.duplicates.map<Widget>((Manga d) => _buildDuplicateItem(d, context)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDuplicateItem(Manga d, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 16),
      child: Row(
        children: [
          Icon(Icons.content_copy_rounded, size: SunfireIconSize.sm, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: SunfireSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.title, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${d.chapterCount} chapters • ${d.sourceName}',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: SunfireSpacing.xs),
        Text(value, style: SunfireTypography.withWeight(SunfireTypography.titleLarge, FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}