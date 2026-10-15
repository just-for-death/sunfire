import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/manga.dart';
import '../../core/metron/metron_models.dart';
import '../../core/metron/metron_service.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
import 'global_search_screen.dart';

class MetronSeriesDetailScreen extends StatefulWidget {
  final int seriesId;
  final String? initialTitle;
  final String? initialImage;

  const MetronSeriesDetailScreen({
    super.key,
    required this.seriesId,
    this.initialTitle,
    this.initialImage,
  });

  @override
  State<MetronSeriesDetailScreen> createState() => _MetronSeriesDetailScreenState();
}

class _MetronSeriesDetailScreenState extends State<MetronSeriesDetailScreen> {
  MetronSeries? _series;
  List<MetronIssueSummary> _issues = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSeriesData());
  }

  Future<void> _loadSeriesData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await MetronService.instance.getSeriesDetail(widget.seriesId);
      final issuesData = await MetronService.instance.getSeriesIssues(widget.seriesId);

      if (mounted) {
        setState(() {
          _series = detail;
          _issues = issuesData.issues;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showLinkToLibraryDialog() async {
    final libraryMangas = await IsarService.instance.getLibraryManga();
    if (!mounted) return;

    if (libraryMangas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your library is empty. Use "Find in Sources" to add comics to your library first.')),
      );
      return;
    }

    final query = (_series?.name ?? widget.initialTitle ?? '').toLowerCase();
    // Sort library comics: exact or fuzzy matches first
    libraryMangas.sort((a, b) {
      final aMatch = a.title.toLowerCase().contains(query) ? 1 : 0;
      final bMatch = b.title.toLowerCase().contains(query) ? 1 : 0;
      return bMatch.compareTo(aMatch);
    });
unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(SunfireRadius.sheet))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, color: SunfireColors.trackerBlue),
                  const SizedBox(width: SunfireSpacing.sm),
                  const Text('Link Metron to Library Comic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: libraryMangas.length,
                itemBuilder: (context, idx) {
                  final m = libraryMangas[idx];
                  final isAlreadyLinked = m.metronSeriesId == widget.seriesId;

                  return ListTile(
                    leading: m.thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              m.thumbnailUrl!,
                              width: 40,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 40,
                                height: 56,
                                color: SunfireColors.surface2,
                                child: const Icon(Icons.book, size: SunfireIconSize.md),
                              ),
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 56,
                            decoration: BoxDecoration(color: SunfireColors.surface2, borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.book, size: SunfireIconSize.md),
                          ),
                    title: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${m.sourceName} • ${m.chapterCount} chapters', style: const TextStyle(fontSize: 12, color: SunfireColors.contentTertiary)),
                    trailing: isAlreadyLinked
                        ? const Icon(Icons.check_circle, color: SunfireColors.success)
                        : TextButton(
                            child: const Text('Link'),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await _applyMetronLink(m);
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> _applyMetronLink(Manga manga) async {
    if (_series == null) return;

    final issuesData = await MetronService.instance.getSeriesIssues(widget.seriesId);
    // Persist the issue-number -> Metron-id map as proper JSON. A hand-joined
    // string breaks (silently corrupting later scrobble lookups) whenever a
    // key contains JSON-special characters; jsonEncode is shape-safe for the
    // Map<String, int> we write here.
    manga.metronIssuesJson = jsonEncode(issuesData.issueMap);
    manga.metronSeriesId = widget.seriesId;
    manga.publisher = _series?.publisher?.name;
    manga.isMetadataLocked = true;

    if (_series?.description != null && _series!.description!.isNotEmpty) {
      manga.description = _series!.description;
    }
    if (_series?.genres != null && _series!.genres.isNotEmpty) {
      manga.genres = _series!.genres;
    }
    if (_series?.status != null && _series!.status!.isNotEmpty) {
      manga.status = _series!.status;
    }

    await IsarService.instance.saveManga(manga);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Linked "${_series!.name}" to "${manga.title}"! Metadata enriched.'),
          backgroundColor: SunfireColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final series = _series;
    final title = series?.displayName ?? widget.initialTitle ?? 'Comic Details';
    final cover = series?.image ?? widget.initialImage;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: SunfireColors.error),
                        const SizedBox(height: SunfireSpacing.md),
                        Text('Failed to load series details', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(_errorMessage!, style: const TextStyle(color: SunfireColors.contentTertiary, fontSize: 12), textAlign: TextAlign.center),
                        const SizedBox(height: SunfireSpacing.lg),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          onPressed: _loadSeriesData,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header card
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: cover != null
                              ? Image.network(
                                  cover,
                                  width: 110,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 110,
                                    height: 160,
                                    color: SunfireColors.surface2,
                                    child: const Icon(Icons.book, size: 40),
                                  ),
                                )
                              : Container(
                                  width: 110,
                                  height: 160,
                                  color: SunfireColors.surface2,
                                  child: const Icon(Icons.book, size: 40),
                                ),
                        ),
                        const SizedBox(width: SunfireSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                series?.name ?? title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              if (series?.publisher != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: SunfireColors.trackerBlue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    series!.publisher!.name,
                                    style: const TextStyle(color: SunfireColors.trackerBlue, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                '${series?.yearBegan != null ? "Year: ${series!.yearBegan}" : ""} • ${series?.issueCount ?? _issues.length} Issues',
                                style: const TextStyle(color: SunfireColors.contentTertiary, fontSize: 13),
                              ),
                              if (series?.status != null) ...[
                                const SizedBox(height: SunfireSpacing.xs),
                                Text(
                                  'Status: ${series!.status}',
                                  style: const TextStyle(color: SunfireColors.contentTertiary, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: SunfireSpacing.lg),

                    // Primary Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('Find in Sources'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: SunfireSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              final q = series?.name ?? widget.initialTitle ?? '';
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => GlobalSearchScreen(initialQuery: q),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.link_rounded),
                            label: const Text('Link to Library'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: SunfireSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _showLinkToLibraryDialog,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    if (series?.description != null && series!.description!.trim().isNotEmpty) ...[
                      Text('About', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        series.description!.trim(),
                        style: const TextStyle(fontSize: 13, height: 1.4, color: SunfireColors.contentSecondary),
                      ),
                      const SizedBox(height: SunfireSpacing.lg),
                    ],

                    // Genres
                    if (series?.genres != null && series!.genres.isNotEmpty) ...[
                      Text('Genres', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: SunfireSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: series.genres.map((g) {
                          return Chip(
                            label: Text(g, style: const TextStyle(fontSize: 11)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Issue List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Issues (${_issues.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: SunfireSpacing.sm),

                    if (_issues.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No issue details available for this series.', style: TextStyle(color: SunfireColors.contentTertiary)),
                      )
                    else
                      ..._issues.map((issue) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: SunfireSpacing.xs),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: issue.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      issue.image!,
                                      width: 36,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 36, height: 50, color: SunfireColors.surface2),
                                    ),
                                  )
                                : Container(width: 36, height: 50, color: SunfireColors.surface2, child: const Icon(Icons.book, size: SunfireIconSize.sm)),
                            title: Text(issue.issueName ?? 'Issue #${issue.number}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              issue.storeDate ?? issue.coverDate ?? 'Release date unknown',
                              style: const TextStyle(color: SunfireColors.contentTertiary, fontSize: 12),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
    );
  }
}
