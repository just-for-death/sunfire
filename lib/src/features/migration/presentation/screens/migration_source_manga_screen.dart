import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../widgets/manga_cover/grid/manga_cover_grid_tile.dart';
import '../../../library/presentation/category/controller/edit_category_controller.dart';
import '../../../library/presentation/library/controller/library_controller.dart';
import '../../../manga_book/domain/manga/manga_model.dart';
import '../../domain/migration_models.dart';

part 'migration_source_manga_screen.g.dart';

@riverpod
Future<List<MangaDto>> migrationSourceMangaList(Ref ref, String sourceId) async {
  final categories = await ref.watch(categoryControllerProvider.future);
  if (categories == null) return [];

  final seenMangaIds = <int>{};
  final result = <MangaDto>[];

  for (final category in categories) {
    final mangas = await ref.watch(categoryMangaListProvider(category.id).future);
    if (mangas != null) {
      for (final manga in mangas) {
        if (manga.source?.id == sourceId && seenMangaIds.add(manga.id)) {
          result.add(manga);
        }
      }
    }
  }

  result.sort((a, b) => a.title.compareTo(b.title));
  return result;
}

class MigrationSourceMangaScreen extends HookConsumerWidget {
  const MigrationSourceMangaScreen({
    super.key,
    required this.sourceId,
  });

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mangasAsync = ref.watch(migrationSourceMangaListProvider(sourceId));
    // Track by ID to avoid object-identity issues with Freezed DTOs
    final selectedIds = useState<Set<int>>({});

    void toggleSelection(MangaDto manga) {
      final newSet = Set<int>.from(selectedIds.value);
      if (newSet.contains(manga.id)) {
        newSet.remove(manga.id);
      } else {
        newSet.add(manga.id);
      }
      selectedIds.value = newSet;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIds.value.isEmpty 
            ? l10n.selectManga 
            : '${selectedIds.value.length} Selected'),
        actions: [
          if (selectedIds.value.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                final allMangas = mangasAsync.valueOrNull ?? [];
                if (selectedIds.value.length == allMangas.length) {
                  selectedIds.value = {};
                } else {
                  selectedIds.value = {for (final m in allMangas) m.id};
                }
              },
            ),
        ],
      ),
      floatingActionButton: selectedIds.value.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                final allMangas = mangasAsync.valueOrNull ?? [];
                final selectedMangas = allMangas
                    .where((m) => selectedIds.value.contains(m.id))
                    .toList();
                MigrationSourceSelectionRoute(
                  $extra: MigrationRouteData(sourceMangas: selectedMangas),
                ).push(context);
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text('Migrate (${selectedIds.value.length})'),
            )
          : null,
      body: mangasAsync.showUiWhenData(
        context,
        (data) {
          if (data.isBlank) {
            return Emoticons(
              title: l10n.noMangaFound,
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              childAspectRatio: 0.65,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final manga = data[index];
              final isSelected = selectedIds.value.contains(manga.id);
              
              return MangaCoverGridTile(
                manga: manga,
                isSelected: isSelected,
                onLongPress: () => toggleSelection(manga),
                onPressed: () {
                  if (selectedIds.value.isNotEmpty) {
                    toggleSelection(manga);
                  } else {
                    MigrationSourceSelectionRoute(
                      $extra: MigrationRouteData(sourceMangas: [manga]),
                    ).push(context);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
