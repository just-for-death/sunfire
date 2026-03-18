// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../routes/router_config.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../widgets/server_image.dart';
import '../../../../manga_book/data/local_downloads/local_downloads_service.dart';
import '../../../../manga_book/presentation/downloads/controller/local_downloads_controller.dart';
import '../../../presentation/reader/controller/reader_controller.dart';
import '../../manga_details/controller/manga_details_controller.dart';

class LocalDownloadsList extends ConsumerWidget {
  const LocalDownloadsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloaded = ref.watch(localDownloadedChapterIdsProvider);

    return downloaded.when(
      data: (ids) {
        if (ids.isEmpty) {
          return Center(child: Text(context.l10n.noDownloads));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(localDownloadedChapterIdsProvider);
          },
          child: ListView.builder(
            itemCount: ids.length,
            itemBuilder: (context, index) {
              final chapterId = ids[index];
              final chapterAsync =
                  ref.watch(chapterProvider(chapterId: chapterId));

              return chapterAsync.when(
                data: (chapter) {
                  final title = chapter?.name ?? 'Chapter';
                  final mangaId = chapter?.mangaId;
                  final mangaTitleAsync = mangaId == null
                      ? null
                      : ref.watch(mangaWithIdProvider(mangaId: mangaId));
                  final mangaTitle = mangaTitleAsync?.valueOrNull?.title;
                  final chapterNo = chapter?.chapterNumber;
                  final thumbUrl = mangaTitleAsync?.valueOrNull?.thumbnailUrl;
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 44,
                        height: 62,
                        child: (thumbUrl != null && thumbUrl.isNotEmpty)
                            ? ServerImage(
                                imageUrl: thumbUrl,
                                size: const Size(44, 62),
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.download_done_rounded),
                      ),
                    ),
                    title: Text(
                      mangaTitle?.isNotEmpty == true ? mangaTitle! : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: (mangaTitle?.isNotEmpty == true ||
                            (chapterNo != null &&
                                chapterNo.toString().isNotEmpty))
                        ? Text(
                            [
                              if (mangaTitle?.isNotEmpty == true) title,
                              if (chapterNo != null &&
                                  chapterNo.toString().isNotEmpty)
                                'Ch. $chapterNo',
                            ].whereType<String>().join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: (mangaId == null)
                        ? null
                        : () => ReaderRoute(
                              mangaId: mangaId,
                              chapterId: chapterId,
                              showReaderLayoutAnimation: true,
                            ).push(context),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () async {
                        await ref
                            .read(localChapterDownloadProvider(
                                    chapterId: chapterId)
                                .notifier)
                            .delete();
                        ref.invalidate(localDownloadedChapterIdsProvider);
                      },
                    ),
                  );
                },
                loading: () => const ListTile(
                  leading: Icon(Icons.download_done_rounded),
                  title: Text('...'),
                ),
                error: (e, _) => ListTile(
                  leading: const Icon(Icons.download_done_rounded),
                  title: Text('Chapter $chapterId'),
                  subtitle: Text(e.toString()),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

