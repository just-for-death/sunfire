import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/custom_extensions.dart';
import '../../../widgets/emoticons.dart';
import 'history_controller.dart';
import 'history_settings_sheet.dart';
import 'ios/ios_home_screen.dart';
import 'widgets/history_group_widget.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // iOS → Aidoku-style glass home screen
    if (!kIsWeb && Platform.isIOS) {
      return const IOSHomeScreen();
    }
    // Android → Catalyst Material You home screen
    return const _AndroidHomeScreen();
  }
}

class _AndroidHomeScreen extends HookConsumerWidget {
  const _AndroidHomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyGroups = ref.watch(filteredHistoryGroupsProvider);
    final historyState = ref.watch(readingHistoryProvider);
    final historyEnabled = ref.watch(historyEnabledProvider) ?? true;
    final hasMore = ref.watch(historyHasMoreProvider);
    final searchQuery = ref.watch(historySearchQueryProvider);
    final searchController = useTextEditingController(text: searchQuery);
    final isLoadingMore = useState(false);

    useEffect(() {
      if (searchController.text != searchQuery) {
        searchController.text = searchQuery;
      }
      return null;
    }, [searchQuery]);

    Future<void> tryLoadMore() async {
      if (!hasMore ||
          isLoadingMore.value ||
          searchQuery.isNotBlank ||
          ref.read(readingHistoryProvider.notifier).isLoadingMore) {
        return;
      }
      isLoadingMore.value = true;
      try {
        await ref.read(readingHistoryProvider.notifier).loadMore();
      } finally {
        isLoadingMore.value = false;
      }
    }

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 240) {
            unawaited(tryLoadMore());
          }
          return false;
        },
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                controller: searchController,
                hintText: context.l10n.searchHistory,
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (searchQuery.isNotBlank)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        searchController.clear();
                        ref
                            .read(historySearchQueryProvider.notifier)
                            .updateQuery('');
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () =>
                        ref.read(readingHistoryProvider.notifier).refresh(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    onPressed: () => showHistorySettingsSheet(context, ref),
                  ),
                ],
                onChanged: (v) => ref
                    .read(historySearchQueryProvider.notifier)
                    .updateQuery(v),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  context.theme.colorScheme.surfaceContainerHigh,
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ),
          historyState.when(
            data: (data) {
              if (!historyEnabled) {
                return SliverFillRemaining(
                  child: _HistoryDisabledState(
                    onOpenSettings: () =>
                        showHistorySettingsSheet(context, ref),
                  ),
                );
              }
              if (data == null || data.isEmpty) {
                return const SliverFillRemaining(child: _HistoryEmptyState());
              }
              if (historyGroups.isEmpty && searchQuery.isNotBlank) {
                return const SliverFillRemaining(child: _HistoryNoResults());
              }
              if (historyGroups.isEmpty) {
                return const SliverFillRemaining(child: _HistoryEmptyState());
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                sliver: SliverList.builder(
                  itemCount: historyGroups.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == historyGroups.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: isLoadingMore.value
                              ? const CircularProgressIndicator()
                              : Text(
                                  context.l10n.historyLoadMore,
                                  style: context.theme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      );
                    }
                    return HistoryGroupWidget(
                      group: historyGroups[i],
                      onRemoveItem: (id) => ref
                          .read(readingHistoryProvider.notifier)
                          .removeFromHistory(id),
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: _HistoryErrorState(
                onRetry: () =>
                    ref.read(readingHistoryProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_rounded,
                size: 64,
                color: context.theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(context.l10n.noHistoryFound,
                style: context.theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(context.l10n.startReadingToSeeHistory,
                style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
}

class _HistoryDisabledState extends StatelessWidget {
  const _HistoryDisabledState({required this.onOpenSettings});
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded,
                size: 64,
                color: context.theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(context.l10n.historyEnabledLabel,
                style: context.theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                context.l10n.historyEnabledDescription,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_rounded),
              label: Text(context.l10n.settings),
            ),
          ],
        ),
      );
}

class _HistoryNoResults extends StatelessWidget {
  const _HistoryNoResults();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64,
                color: context.theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(context.l10n.noSearchResults,
                style: context.theme.textTheme.titleMedium),
          ],
        ),
      );
}

class _HistoryErrorState extends StatelessWidget {
  const _HistoryErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Emoticons(iconData: Icons.error_outline),
            const SizedBox(height: 16),
            Text(context.l10n.errorSomethingWentWrong,
                style: context.theme.textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
                onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      );
}
