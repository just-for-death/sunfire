import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../global_providers/global_providers.dart';
import '../../../../global_providers/tablet_selection_providers.dart';
import '../../../../routes/router_config.dart';
import '../../../../theme/catalyst_ui_tokens.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../../../utils/platform/platform_ui.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../widgets/layout/tablet_split_layout.dart';
import '../../../../widgets/shell/ios/glass_app_bar.dart';
import '../../../manga_book/data/local_downloads/local_downloads_service.dart';
import '../../../manga_book/widgets/update_status_popup_menu.dart';
import '../../domain/category/category_model.dart';
import '../category/controller/edit_category_controller.dart';
import 'category_manga_list.dart';
import 'controller/library_controller.dart';
import 'widgets/library_manga_organizer.dart';

String _categoryLabel(BuildContext context, CategoryDto category) {
  if (category.id == kOfflineLibraryCategoryId) {
    return context.l10n.downloads;
  }
  return category.name;
}

class LibraryScreen extends HookConsumerWidget {
  const LibraryScreen({super.key, required this.categoryId});
  final int categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toast = ref.watch(toastProvider);
    final categoryList = ref.watch(nonZeroCategoryListProvider);
    final showSearch = useState(false);
    final libraryQuery = ref.watch(libraryQueryProvider) ?? '';
    final searchController = useTextEditingController(text: libraryQuery);
    // A query that outlives the search field would filter the library with no
    // visible cause, so the field stays up for as long as the query does.
    final showSearchField = showSearch.value || libraryQuery.isNotBlank;

    useEffect(() {
      categoryList.showToastOnError(toast, withMicrotask: true);
      return;
    }, [categoryList.valueOrNull]);

    useEffect(() {
      if (searchController.text != libraryQuery) {
        searchController.text = libraryQuery;
      }
      return null;
    }, [libraryQuery]);

    return categoryList.showUiWhenData(
      context,
      (data) {
        if (data.isBlank) {
          return Emoticons(
            title: context.l10n.noCategoriesFound,
            button: TextButton(
              onPressed: () => ref.refresh(categoryControllerProvider.future),
              child: Text(context.l10n.refresh),
            ),
          );
        }
        if (TabletSplitLayout.shouldUse(context)) {
          return _LibraryTabletSplit(
            categories: data!,
            initialCategoryId: categoryId,
            showSearch: showSearch,
            showSearchField: showSearchField,
            searchController: searchController,
          );
        }
        return DefaultTabController(
          // initialIndex only applies on first build, so a deep link to another
          // category while the library is already alive needs a fresh
          // controller — otherwise the tabs stay put while the route moves on.
          key: ValueKey(categoryId),
          length: data!.length,
          initialIndex: () {
            final idx = data.indexWhere((c) => c.id == categoryId);
            if (idx >= 0) return idx;
            return 0;
          }(),
          child: Scaffold(
            backgroundColor: isCupertinoPlatform
                ? context.theme.scaffoldBackgroundColor
                : null,
            extendBodyBehindAppBar: isCupertinoPlatform,
            appBar: adaptiveGlassAppBar(
              context: context,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(data.length > 1 ? 96 : 48),
                child: Column(
                  children: [
                    _LibraryFilterChips(ref: ref),
                    if (data.length > 1)
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: data
                            .map((e) => Tab(text: _categoryLabel(context, e)))
                            .toList(),
                        dividerColor: Colors.transparent,
                      ),
                  ],
                ),
              ),
              centerTitle: false,
              titleSpacing: 16,
              title: !showSearchField
                  ? Text(context.l10n.library,
                      style: context.theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700))
                  : SearchBar(
                      controller: searchController,
                      hintText: context.l10n.library,
                      leading: const Icon(Icons.search_rounded),
                      onChanged: (val) =>
                          ref.read(libraryQueryProvider.notifier).update(val),
                      trailing: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            ref.read(libraryQueryProvider.notifier).update('');
                            showSearch.value = false;
                          },
                        )
                      ],
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: WidgetStatePropertyAll(
                        context.theme.colorScheme.surfaceContainerHigh,
                      ),
                    ),
              actions: showSearchField
                  ? [const SizedBox.shrink()]
                  : [
                      IconButton(
                        onPressed: () => showSearch.value = true,
                        icon: const Icon(Icons.search_rounded),
                      ),
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () {
                            if (context.isTablet) {
                              Scaffold.of(context).openEndDrawer();
                            } else {
                              showAdaptiveBottomSheet(
                                context: context,
                                builder: (_) => const LibraryMangaOrganizer(),
                              );
                            }
                          },
                          icon: const Icon(Icons.tune_rounded),
                        ),
                      ),
                      Builder(
                        builder: (context) => UpdateStatusPopupMenu(
                          getCategory: () => data.isNotBlank
                              ? data[DefaultTabController.of(context).index]
                              : null,
                        ),
                      ),
                    ],
            ),
            endDrawerEnableOpenDragGesture: false,
            endDrawer: const Drawer(
              width: kDrawerWidth,
              shape: RoundedRectangleBorder(),
              child: LibraryMangaOrganizer(),
            ),
            body: Padding(
              padding: KEdgeInsets.h8.size,
              child: TabBarView(
                children: data
                    .map((e) => CategoryMangaList(
                          categoryId: e.id.getValueOnNullOrNegative(),
                        ))
                    .toList(),
              ),
            ),
          ),
        );
      },
      refresh: () => ref.refresh(categoryControllerProvider.future),
      wrapper: (body) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.library)),
        body: body,
      ),
    );
  }
}

class _LibraryFilterChips extends ConsumerWidget {
  const _LibraryFilterChips({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final isDownloaded = widgetRef.watch(libraryMangaFilterDownloadedProvider);
    final isUnread = widgetRef.watch(libraryMangaFilterUnreadProvider);
    final isCompleted = widgetRef.watch(libraryMangaFilterCompletedProvider);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _chip(
            context,
            label: context.l10n.downloaded,
            icon: Icons.download_done_rounded,
            selected: isDownloaded == true,
            onTap: () => widgetRef
                .read(libraryMangaFilterDownloadedProvider.notifier)
                .update(isDownloaded == true ? null : true),
          ),
          const SizedBox(width: 8),
          _chip(
            context,
            label: context.l10n.unread,
            icon: Icons.fiber_new_rounded,
            selected: isUnread == true,
            onTap: () => widgetRef
                .read(libraryMangaFilterUnreadProvider.notifier)
                .update(isUnread == true ? null : true),
          ),
          const SizedBox(width: 8),
          _chip(
            context,
            label: context.l10n.completed,
            icon: Icons.check_circle_outline_rounded,
            selected: isCompleted == true,
            onTap: () => widgetRef
                .read(libraryMangaFilterCompletedProvider.notifier)
                .update(isCompleted == true ? null : true),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: CatalystUiTokens.chipRadius),
    );
  }
}

class _LibraryTabletSplit extends HookConsumerWidget {
  const _LibraryTabletSplit({
    required this.categories,
    required this.initialCategoryId,
    required this.showSearch,
    required this.showSearchField,
    required this.searchController,
  });

  final List<CategoryDto> categories;
  final int initialCategoryId;
  final ValueNotifier<bool> showSearch;
  final bool showSearchField;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stored = ref.watch(tabletLibraryCategorySelectionProvider);
    // Whether the URL names a category that actually exists (a real deep link)
    // rather than the default/fallback id.
    final routeMatched = categories.any((c) => c.id == initialCategoryId);
    final routeId = routeMatched ? initialCategoryId : categories.first.id;
    final storedValid = stored != null && categories.any((c) => c.id == stored);

    // Detect a genuine route change since the last build.
    final lastRoute = useRef<int?>(null);
    final routeChanged = lastRoute.value != initialCategoryId;

    // A real deep link wins immediately (no one-frame flash of the old
    // category); otherwise keep the user's stored pick so re-tapping the
    // Library tab — which resets the URL to the default — doesn't lose it.
    final int selectedId;
    if (routeChanged && routeMatched) {
      selectedId = routeId;
    } else if (storedValid) {
      selectedId = stored;
    } else {
      selectedId = routeId;
    }

    final prefs = ref.watch(sharedPreferencesProvider);
    final railExpanded =
        useState(prefs.getBool(_kCategoryRailPrefKey) ?? false);
    void toggleRail() {
      railExpanded.value = !railExpanded.value;
      prefs.setBool(_kCategoryRailPrefKey, railExpanded.value);
    }

    // Keep the provider mirror in step with the resolved selection.
    useEffect(() {
      lastRoute.value = initialCategoryId;
      if (categories.isEmpty) return null;
      Future.microtask(() {
        if (ref.read(tabletLibraryCategorySelectionProvider) != selectedId) {
          ref.read(tabletLibraryCategorySelectionProvider.notifier).state =
              selectedId;
        }
      });
      return null;
    }, [initialCategoryId, selectedId, categories]);

    return Scaffold(
      backgroundColor: isCupertinoPlatform
          ? context.theme.scaffoldBackgroundColor
          : null,
      extendBodyBehindAppBar: isCupertinoPlatform,
      appBar: adaptiveGlassAppBar(
        context: context,
        centerTitle: false,
        titleSpacing: 16,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _LibraryFilterChips(ref: ref),
        ),
        title: !showSearchField
            ? Text(context.l10n.library,
                style: context.theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700))
            : SearchBar(
                controller: searchController,
                hintText: context.l10n.library,
                leading: const Icon(Icons.search_rounded),
                onChanged: (val) =>
                    ref.read(libraryQueryProvider.notifier).update(val),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      ref.read(libraryQueryProvider.notifier).update('');
                      showSearch.value = false;
                    },
                  ),
                ],
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  context.theme.colorScheme.surfaceContainerHigh,
                ),
              ),
        actions: showSearchField
            ? [const SizedBox.shrink()]
            : [
                IconButton(
                  onPressed: () => showSearch.value = true,
                  icon: const Icon(Icons.search_rounded),
                ),
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ),
                UpdateStatusPopupMenu(
                  getCategory: () =>
                      categories.where((c) => c.id == selectedId).firstOrNull,
                ),
              ],
      ),
      endDrawer: const Drawer(
        width: kDrawerWidth,
        shape: RoundedRectangleBorder(),
        child: LibraryMangaOrganizer(),
      ),
      endDrawerEnableOpenDragGesture: false,
      body: TabletSplitLayout(
        masterWidth: railExpanded.value
            ? _kCategoryRailExpandedWidth
            : _kCategoryRailCollapsedWidth,
        master: _LibraryCategoryRail(
          categories: categories,
          selectedId: selectedId,
          expanded: railExpanded.value,
          onToggleExpanded: toggleRail,
          onSelect: (category) {
            ref.read(tabletLibraryCategorySelectionProvider.notifier).state =
                category.id;
            LibraryRoute(categoryId: category.id).go(context);
          },
        ),
        detail: CategoryMangaList(
          key: ValueKey(selectedId),
          categoryId: selectedId.getValueOnNullOrNegative(),
        ),
        showDetail: true,
      ),
    );
  }
}

const double _kCategoryRailExpandedWidth = 260;
const double _kCategoryRailCollapsedWidth = 84;
const String _kCategoryRailPrefKey = 'library_category_rail_expanded';

/// Category picker for the library master pane. Collapses to an icon-only rail
/// so the manga grid gets the space back.
class _LibraryCategoryRail extends StatelessWidget {
  const _LibraryCategoryRail({
    required this.categories,
    required this.selectedId,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onSelect,
  });

  final List<CategoryDto> categories;
  final int selectedId;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<CategoryDto> onSelect;

  static String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    return trimmed.characters.first.toUpperCase();
  }

  /// Categories sharing an initial ("Manga" and "Manhwa") are otherwise
  /// indistinguishable once the labels are hidden, so tint them by name.
  static Color _avatarColor(String name, bool isDark) => HSLColor.fromAHSL(
        1,
        (name.hashCode.abs() % 360).toDouble(),
        0.4,
        isDark ? 0.32 : 0.78,
      ).toColor();

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final toggle = IconButton(
      onPressed: onToggleExpanded,
      tooltip: expanded
          ? context.l10n.collapseSidebar
          : context.l10n.expandSidebar,
      icon: Icon(
        expanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: expanded ? 8 : 0),
          child: Align(
            alignment: expanded ? Alignment.centerRight : Alignment.center,
            child: toggle,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 8 : 12,
              vertical: 4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final category = categories[i];
              final selected = category.id == selectedId;
              final count = category.mangas.totalCount;

              if (expanded) {
                return ListTile(
                  selected: selected,
                  shape: const RoundedRectangleBorder(
                    borderRadius: CatalystUiTokens.listItemRadius,
                  ),
                  title: Text(
                    _categoryLabel(context, category),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text('$count'),
                  onTap: () => onSelect(category),
                );
              }

              final isDark = context.isDarkMode;
              final label = _categoryLabel(context, category);
              final tint = _avatarColor(label, isDark);
              return MergeSemantics(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: '$label, $count',
                  child: Tooltip(
                    message: '$label ($count)',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        borderRadius: CatalystUiTokens.listItemRadius,
                        onTap: () => onSelect(category),
                        child: SizedBox(
                          height: 52,
                          child: Center(
                            child: Badge.count(
                              count: count,
                              isLabelVisible: count > 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    selected ? cs.primary : tint,
                                child: Text(
                                  _initial(label),
                                  style:
                                      context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? cs.onPrimary
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
