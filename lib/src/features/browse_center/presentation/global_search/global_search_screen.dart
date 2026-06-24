// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../widgets/search_field.dart';
import '../source/controller/source_controller.dart';
import 'controller/source_quick_search_controller.dart';
import 'widgets/source_short_search.dart';

class GlobalSearchScreen extends HookConsumerWidget {
  const GlobalSearchScreen({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryInput = useState(initialQuery);
    final debouncedQuery = useState<String?>(initialQuery?.trim());

    useEffect(() {
      final trimmed = queryInput.value?.trim();
      final timer = Timer(const Duration(milliseconds: 400), () {
        debouncedQuery.value =
            (trimmed == null || trimmed.isEmpty) ? null : trimmed;
      });
      return timer.cancel;
    }, [queryInput.value]);

    final searchQuery = debouncedQuery.value;
    final quickSearchResult =
        ref.watch(quickSearchResultsProvider(query: searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.globalSearch),
        bottom: PreferredSize(
          preferredSize: kCalculateAppBarBottomSize([true]),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SearchField(
                  initialText: queryInput.value,
                  onChanged: (value) => queryInput.value = value,
                  onSubmitted: (value) => queryInput.value = value,
                ),
              ),
            ],
          ),
        ),
      ),
      body: searchQuery == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  context.l10n.globalSearchHint,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : quickSearchResult.showUiWhenData(
              context,
              (data) => data.isBlank
                  ? Emoticons(
                      title: context.l10n.noSearchResults,
                      button: TextButton(
                        onPressed: () => ref.invalidate(sourceListProvider),
                        child: Text(context.l10n.refresh),
                      ),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return SourceShortSearch(
                          source: data[index].source,
                          mangaList: data[index].mangaList,
                          query: searchQuery,
                        );
                      },
                      itemCount: data.length,
                    ),
            ),
    );
  }
}
