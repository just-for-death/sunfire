import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/server_image.dart';
import '../../../browse_center/domain/source/source_model.dart';
import '../../../manga_book/domain/manga/manga_model.dart';
import '../../controller/migration_controller.dart';
import '../../data/migration_repository.dart';
import '../widgets/migration_options_widget.dart';
import 'migration_search_screen.dart';

class MigrationBatchMatchScreen extends HookConsumerWidget {
  const MigrationBatchMatchScreen({
    super.key,
    required this.sourceMangas,
    required this.targetSource,
  });

  final List<MangaDto> sourceMangas;
  final SourceDto targetSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final matches = useState<Map<MangaDto, MangaDto?>>({});
    final isMatching = useState(true);
    final error = useState<String?>(null);
    final migrationOptions = ref.watch(migrationOptionsProvider);

    useEffect(() {
      Future(() async {
        isMatching.value = true;
        final results = <MangaDto, MangaDto?>{};
        try {
          final migrationRepository = ref.read(migrationRepositoryProvider);
          for (final manga in sourceMangas) {
            final searchResults = await migrationRepository.searchMangaInSource(
              targetSource.id,
              manga.title,
            );
            if (searchResults != null && searchResults.isNotEmpty) {
              // Try to find exact title match, otherwise pick the first
              final exactMatch = searchResults.firstWhere(
                (r) => r.title.toLowerCase() == manga.title.toLowerCase(),
                orElse: () => searchResults.first,
              );
              results[manga] = exactMatch;
            } else {
              results[manga] = null;
            }
          }
          matches.value = results;
        } catch (e) {
          error.value = e.toString();
        } finally {
          isMatching.value = false;
        }
      });
      return null;
    }, const []);

    final matchedCount = matches.value.values.where((m) => m != null).length;
    final canMigrate = matchedCount > 0 && !isMatching.value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Match (${targetSource.displayName})'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            color: context.theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMatching.value
                        ? 'Automatically pairing ${sourceMangas.length} mangas...'
                        : 'Found $matchedCount matches out of ${sourceMangas.length}',
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (isMatching.value)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Match List
          Expanded(
            child: isMatching.value && matches.value.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : error.value != null
                    ? Center(
                        child: Text(
                          'Error: ${error.value}',
                          style: TextStyle(color: context.theme.colorScheme.error),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: sourceMangas.length,
                        itemBuilder: (context, index) {
                          final sourceManga = sourceMangas[index];
                          final targetManga = matches.value[sourceManga];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Source
                                  Expanded(
                                    child: _MiniMangaCover(manga: sourceManga, label: 'Source'),
                                  ),
                                  
                                  // Middle icon
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: IconButton(
                                      tooltip: 'Manual Search',
                                      icon: Icon(
                                        targetManga != null ? Icons.edit : Icons.search,
                                      ),
                                      color: targetManga != null 
                                          ? context.theme.colorScheme.primary 
                                          : context.theme.colorScheme.error,
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MigrationSearchScreen(
                                              sourceMangas: [sourceManga],
                                              targetSource: targetSource,
                                              onSelectedOverride: (newTargetManga) {
                                                final newMatches = Map<MangaDto, MangaDto?>.from(matches.value);
                                                newMatches[sourceManga] = newTargetManga;
                                                matches.value = newMatches;
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  // Target
                                  Expanded(
                                    child: targetManga != null
                                        ? _MiniMangaCover(manga: targetManga, label: 'Match')
                                        : Center(
                                            child: Text(
                                              'No match',
                                              style: TextStyle(
                                                color: context.theme.colorScheme.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          
          // Options
          if (!isMatching.value && canMigrate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExpansionTile(
                title: Text(
                  l10n.migrationOptions,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  MigrationOptionsWidget(
                    options: migrationOptions,
                    onChanged: (newOptions) {
                      ref
                          .read(migrationOptionsProvider.notifier)
                          .update(newOptions);
                    },
                  ),
                ],
              ),
            ),

        ],
      ),
      bottomNavigationBar: canMigrate
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  onPressed: () {
                    // Start batch migration
                    final pairsToMigrate = <MangaDto, MangaDto>{};
                    for (final entry in matches.value.entries) {
                      if (entry.value != null) {
                        pairsToMigrate[entry.key] = entry.value!;
                      }
                    }
                    
                    // Show progress screen
                    const MigrationBatchProgressRoute().push(context);
                    
                    // Execute
                    ref.read(migrationExecutionProvider.notifier).executeBatchMigration(
                          pairsToMigrate,
                          migrationOptions,
                        );
                  },
                  icon: const Icon(Icons.move_up),
                  label: Text('Migrate $matchedCount mangas'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _MiniMangaCover extends StatelessWidget {
  const _MiniMangaCover({
    required this.manga,
    required this.label,
  });

  final MangaDto manga;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.theme.textTheme.labelSmall?.copyWith(
            color: context.theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 40,
                height: 60,
                child: ServerImage(imageUrl: manga.thumbnailUrl ?? ""),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                manga.title,
                style: context.theme.textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
