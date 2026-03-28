import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/app_sizes.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../../../widgets/emoticons.dart';
import '../../../manga_book/widgets/update_status_popup_menu.dart';
import '../category/controller/edit_category_controller.dart';
import 'category_manga_list.dart';
import 'controller/library_controller.dart';
import 'widgets/library_manga_organizer.dart';

class LibraryScreen extends HookConsumerWidget {
  const LibraryScreen({super.key, required this.categoryId});
  final int categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toast = ref.watch(toastProvider);
    final categoryList = ref.watch(nonZeroCategoryListProvider);
    final showSearch = useState(false);
    useEffect(() {
      categoryList.showToastOnError(toast, withMicrotask: true);
      return;
    }, [categoryList.valueOrNull]);

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
        return DefaultTabController(
          length: data!.length,
          initialIndex:
              min(categoryId.getValueOnNullOrNegative(), data.length - 1),
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              titleSpacing: 16,
              title: !showSearch.value
                  ? Text(context.l10n.library,
                      style: context.theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700))
                  : SearchBar(
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
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                    data.length > 1 ? 96 : 48),
                child: Column(
                  children: [
                    // Futon-style filter chips
                    _LibraryFilterChips(ref: ref),
                    if (data.length > 1)
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: data.map((e) => Tab(text: e.name)).toList(),
                        dividerColor: Colors.transparent,
                      ),
                  ],
                ),
              ),
              actions: showSearch.value
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
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: KBorderRadius.rT16.radius,
                                ),
                                clipBehavior: Clip.hardEdge,
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
                .update(!( isDownloaded ?? false)),
          ),
          const SizedBox(width: 8),
          _chip(
            context,
            label: context.l10n.unread,
            icon: Icons.fiber_new_rounded,
            selected: isUnread == true,
            onTap: () => widgetRef
                .read(libraryMangaFilterUnreadProvider.notifier)
                .update(!(isUnread ?? false)),
          ),
          const SizedBox(width: 8),
          _chip(
            context,
            label: context.l10n.completed,
            icon: Icons.check_circle_outline_rounded,
            selected: isCompleted == true,
            onTap: () => widgetRef
                .read(libraryMangaFilterCompletedProvider.notifier)
                .update(!(isCompleted ?? false)),
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
    );
  }
}
