import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../widgets/server_image.dart';
import '../../../browse_center/domain/source/source_model.dart';
import '../../../browse_center/presentation/source/controller/source_controller.dart';
import '../../../library/presentation/category/controller/edit_category_controller.dart';
import '../../../library/presentation/library/controller/library_controller.dart';
import '../../../../routes/router_config.dart';

part 'migration_main_screen.g.dart';

@riverpod
Future<List<({SourceDto source, int count})>> migrationLibrarySources(Ref ref) async {
  final categories = await ref.watch(categoryControllerProvider.future);
  if (categories == null) return [];

  final seenMangaIds = <int>{};
  final sourceMangaCounts = <String, int>{};

  for (final category in categories) {
    final mangas = await ref.watch(categoryMangaListProvider(category.id).future);
    if (mangas != null) {
      for (final manga in mangas) {
        if (seenMangaIds.add(manga.id)) {
          final sourceId = manga.source?.id;
          if (sourceId != null) {
            sourceMangaCounts[sourceId] = (sourceMangaCounts[sourceId] ?? 0) + 1;
          }
        }
      }
    }
  }

  final sourceMapAsync = ref.watch(sourceMapFilteredProvider);
  final sourceMap = sourceMapAsync.valueOrNull;
  if (sourceMap == null || sourceMap.isEmpty) return [];

  final result = <({SourceDto source, int count})>[];
  final allSources = sourceMap.values.expand((v) => v).toList();

  for (final entry in sourceMangaCounts.entries) {
    final source = allSources.where((s) => s.id == entry.key).firstOrNull;
    if (source != null) {
      result.add((source: source, count: entry.value));
    }
  }

  result.sort((a, b) => a.source.name.compareTo(b.source.name));
  return result;
}

class MigrationMainScreen extends HookConsumerWidget {
  const MigrationMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = context.theme;
    
    final sourcesAsync = ref.watch(migrationLibrarySourcesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectSource),
      ),
      body: sourcesAsync.showUiWhenData(
        context,
        (data) {
          if (data.isBlank) {
            return Emoticons(
              title: l10n.noSourcesFound,
              button: TextButton(
                onPressed: () => ref.refresh(migrationLibrarySourcesProvider),
                child: Text(l10n.refresh),
              ),
            );
          }

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = data[index];
              final source = item.source;
              final count = item.count;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ServerImage(
                    imageUrl: source.iconUrl,
                    size: const Size(48, 48),
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  source.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  source.lang.toUpperCase(),
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Text(
                  count.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  MigrationSourceMangaRoute(sourceId: source.id).push(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
