// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../data/tracker_repository.dart';
import '../../domain/tracker_model.dart';
import '../controller/tracker_controller.dart';

class TrackerEditDialog extends HookConsumerWidget {
  const TrackerEditDialog({
    super.key,
    required this.record,
    required this.mangaId,
  });

  final TrackRecordDto record;
  final int mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusValue = useState<int?>(record.status);
    final chapterController = useTextEditingController(
      text: record.lastChapterRead != null
          ? record.lastChapterRead!.toStringAsFixed(0)
          : '',
    );
    final scoreController = useTextEditingController(
      text: (record.displayScore?.isNotEmpty == true &&
              record.displayScore != '0')
          ? record.displayScore!
          : (record.score != null && record.score! > 0
              ? record.score!.toStringAsFixed(1)
              : ''),
    );
    final startDateController = useTextEditingController(
      text: record.startDate ?? '',
    );
    final finishDateController = useTextEditingController(
      text: record.finishDate ?? '',
    );
    final saving = useState(false);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.track_changes_rounded),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              record.trackerName ?? 'Tracker',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title chip
              if (record.title.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.menu_book_rounded, size: 16),
                  label: Text(
                    record.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),

              // Status dropdown — uses tracker's real statuses if available
              Text('Status', style: context.textTheme.labelMedium),
              const SizedBox(height: 4),
              DropdownButtonFormField<int?>(
                value: statusValue.value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('— Not set —')),
                  ...( record.trackerStatuses?.isNotEmpty == true
                    ? record.trackerStatuses!.map((s) =>
                        DropdownMenuItem(value: s.value, child: Text(s.name)))
                    : const [
                        DropdownMenuItem(value: 1, child: Text('Reading')),
                        DropdownMenuItem(value: 2, child: Text('Completed')),
                        DropdownMenuItem(value: 3, child: Text('On Hold')),
                        DropdownMenuItem(value: 4, child: Text('Dropped')),
                        DropdownMenuItem(value: 5, child: Text('Plan to Read')),
                        DropdownMenuItem(value: 6, child: Text('Re-reading')),
                      ]),
                ],
                onChanged: (v) => statusValue.value = v,
              ),
              const SizedBox(height: 12),

              // Last chapter
              Text('Last Chapter Read',
                  style: context.textTheme.labelMedium),
              const SizedBox(height: 4),
              TextField(
                controller: chapterController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  hintText: '0',
                  suffixText: record.totalChapters != null &&
                          record.totalChapters! > 0
                      ? '/ ${record.totalChapters}'
                      : null,
                ),
              ),
              const SizedBox(height: 12),

              // Score
              Text('Score', style: context.textTheme.labelMedium),
              const SizedBox(height: 4),
              record.trackerScores?.isNotEmpty == true
                ? DropdownButtonFormField<String?>(
                    value: record.trackerScores!.contains(scoreController.text)
                        ? scoreController.text
                        : null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('— Not set —')),
                      ...record.trackerScores!.map((s) =>
                          DropdownMenuItem<String?>(value: s, child: Text(s))),
                    ],
                    onChanged: (v) {
                      scoreController.text = v ?? '';
                    },
                  )
                : TextField(
                    controller: scoreController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: '—',
                    ),
                  ),
              const SizedBox(height: 12),

              // Dates row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date',
                            style: context.textTheme.labelMedium),
                        const SizedBox(height: 4),
                        TextField(
                          controller: startDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            hintText: 'YYYY-MM-DD',
                          ),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _parseDate(startDateController.text),
                              firstDate: DateTime(1990),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              startDateController.text =
                                  picked.toIso8601String().substring(0, 10);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Finish Date',
                            style: context.textTheme.labelMedium),
                        const SizedBox(height: 4),
                        TextField(
                          controller: finishDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            hintText: 'YYYY-MM-DD',
                          ),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _parseDate(finishDateController.text),
                              firstDate: DateTime(1990),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              finishDateController.text =
                                  picked.toIso8601String().substring(0, 10);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: saving.value
              ? null
              : () async {
                  saving.value = true;
                  try {
                    await ref.read(trackerRepositoryProvider).updateTrack(
                          recordId: record.id,
                          status: statusValue.value,
                          lastChapterRead: chapterController.text.isNotEmpty
                              ? double.tryParse(chapterController.text)
                              : null,
                          scoreString: scoreController.text.isNotEmpty
                              ? scoreController.text.trim()
                              : null,
                          startDate: startDateController.text.isNotEmpty
                              ? startDateController.text.trim()
                              : null,
                          finishDate: finishDateController.text.isNotEmpty
                              ? finishDateController.text.trim()
                              : null,
                        );
                    ref.invalidate(mangaTrackRecordsProvider(mangaId));
                    if (context.mounted) {
                      Navigator.pop(context, true);
                      // don't reset saving - widget is popped
                    }
                  } catch (e) {
                    if (context.mounted) {
                      saving.value = false;
                      ref.read(toastProvider)?.showError(e.toString());
                    }
                  }
                },
          child: saving.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.save),
        ),
      ],
    );
  }

  DateTime _parseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return DateTime.now();
    }
  }
}
