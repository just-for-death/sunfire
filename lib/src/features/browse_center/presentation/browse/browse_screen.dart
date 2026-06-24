import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../routes/router_config.dart';
import '../../../../theme/komikku_ui_tokens.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/server_image.dart';
import '../../domain/source/source_model.dart';
import '../extension/controller/extension_controller.dart';
import '../extension/widgets/extension_language_filter_dialog.dart';
import '../extension/widgets/install_extension_file.dart';
import '../source/controller/source_controller.dart' hide SourceLanguageFilter;
import '../source/widgets/source_language_filter.dart';

class BrowseScreen extends HookConsumerWidget {
  const BrowseScreen({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.children,
  });
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController =
        useTabController(initialLength: 2, initialIndex: currentIndex);
    final syncingFromShell = useRef(false);

    useEffect(() {
      if (currentIndex != tabController.index) {
        syncingFromShell.value = true;
        tabController.animateTo(currentIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          syncingFromShell.value = false;
        });
      }
      return null;
    }, [currentIndex]);

    useEffect(() {
      void onTabChanged() {
        if (syncingFromShell.value || tabController.indexIsChanging) return;
        if (tabController.index != currentIndex) {
          onDestinationSelected(tabController.index);
        }
      }

      tabController.addListener(onTabChanged);
      return () => tabController.removeListener(onTabChanged);
    }, [currentIndex, tabController]);

    useListenable(tabController);

    final showSearch = useState(false);
    final cs = context.theme.colorScheme;
    final isExtensions = tabController.index == 1;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            forceElevated: innerBoxIsScrolled,
            titleSpacing: 16,
            title: showSearch.value
                ? SearchBar(
                    hintText: isExtensions
                        ? context.l10n.extensions
                        : context.l10n.sources,
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => showSearch.value = false,
                      )
                    ],
                    onChanged: isExtensions
                        ? (val) => ref
                            .read(extensionQueryProvider.notifier)
                            .update(val)
                        : null,
                    onSubmitted: isExtensions
                        ? null
                        : (v) {
                            if (v.isNotBlank) {
                              GlobalSearchRoute(query: v).push(context);
                            }
                          },
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor:
                        WidgetStatePropertyAll(cs.surfaceContainerHigh),
                  )
                : Text(
                    context.l10n.browse,
                    style: context.theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
            actions: showSearch.value
                ? []
                : [
                    IconButton(
                      onPressed: () => showSearch.value = true,
                      icon: Icon(isExtensions
                          ? Icons.search_rounded
                          : Icons.travel_explore_rounded),
                    ),
                    if (isExtensions) const InstallExtensionFile(),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => isExtensions
                            ? const ExtensionLanguageFilterDialog()
                            : const SourceLanguageFilter(),
                      ),
                      icon: const Icon(Icons.translate_rounded),
                    ),
                  ],
            bottom: TabBar(
              controller: tabController,
              onTap: onDestinationSelected,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: context.l10n.sources),
                Tab(text: context.l10n.extensions),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: tabController,
          children: [
            _SourcesBranchTab(branch: children[0]),
            children.length > 1 ? children[1] : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _SourcesBranchTab extends StatelessWidget {
  const _SourcesBranchTab({required this.branch});
  final Widget branch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: _QuickActionGrid(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text(
                context.l10n.sources,
                style: context.theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => BrowseSourceRoute().go(context),
                child: Text(context.l10n.seeAll),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            child: _PinnedSourcesGrid(),
          ),
        ),
        Expanded(child: branch),
      ],
    );
  }
}

class _QuickActionGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final actions = [
      (
        icon: Icons.storage_rounded,
        label: context.l10n.sources,
        onTap: () => BrowseSourceRoute().go(context),
      ),
      (
        icon: Icons.bookmark_outline_rounded,
        label: context.l10n.migrate,
        onTap: () => const MigrationMainRoute().push(context),
      ),
      (
        icon: Icons.travel_explore_rounded,
        label: context.l10n.globalSearch,
        onTap: () => const GlobalSearchRoute(query: '').push(context),
      ),
      (
        icon: Icons.download_outlined,
        label: context.l10n.downloads,
        onTap: () => const DownloadsRoute().push(context),
      ),
    ];

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
      children: actions
          .map((a) => SizedBox(
                height: 36,
                child: Material(
                  color: cs.surfaceContainerHigh,
                  borderRadius: KomikkuUiTokens.chipRadius,
                  child: InkWell(
                    borderRadius: KomikkuUiTokens.chipRadius,
                    onTap: a.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(a.icon, size: 16, color: cs.primary),
                          const SizedBox(width: 6),
                          Text(
                            a.label,
                            style:
                                context.theme.textTheme.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
      ),
    );
  }
}

class _PinnedSourcesGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceMapData = ref.watch(sourceMapFilteredProvider);
    final sourceMap = {...?sourceMapData.valueOrNull};
    sourceMap.remove('localsourcelang');
    final lastUsed = sourceMap.remove('lastUsed') ?? [];
    final pinned = [
      ...lastUsed,
      ...sourceMap.values.expand((v) => v),
    ].take(8).toList();

    if (pinned.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100,
          childAspectRatio: 0.95,
          crossAxisSpacing: 4,
          mainAxisSpacing: 8,
        ),
        itemCount: pinned.length,
        itemBuilder: (context, i) {
          final source = pinned[i];
          return Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ref.read(sourceLastUsedProvider.notifier).update(source.id);
                  SourceTypeRoute(
                    sourceId: source.id,
                    sourceType: SourceType.POPULAR,
                  ).go(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ServerImage(
                          imageUrl: source.iconUrl,
                          size: const Size.square(46),
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        source.name,
                        style: context.theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
