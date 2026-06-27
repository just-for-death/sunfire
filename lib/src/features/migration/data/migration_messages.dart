import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/extensions/custom_extensions.dart';

/// Localized user-facing migration warning and error strings.
class MigrationMessages {
  MigrationMessages(this._l10n);

  final AppLocalizations? _l10n;

  factory MigrationMessages.fromContext(BuildContext? context) =>
      MigrationMessages(context?.l10n);

  String get completedWithErrors =>
      _l10n?.migrationCompletedWithErrors ?? 'Migration completed with errors';

  String get migrationFailedGeneric =>
      _l10n?.migrationFailedGeneric ?? 'Migration failed';

  String get errorFetchingSourceManga =>
      _l10n?.errorFetchingSourceManga ?? 'Failed to fetch source manga';

  String get errorSourceMangaNotFound =>
      _l10n?.errorSourceMangaNotFound ?? 'Source manga not found';

  String get errorFetchingTargetManga =>
      _l10n?.errorFetchingTargetManga ?? 'Failed to fetch target manga';

  String get errorTargetMangaNotFound =>
      _l10n?.errorTargetMangaNotFound ?? 'Target manga not found';

  String addToLibraryFailed(String detail) =>
      _l10n?.migrationWarnAddToLibraryFailed(detail) ??
      'Failed to add target manga to library: $detail';

  String categoriesFailed(String detail) =>
      _l10n?.migrationWarnCategoriesFailed(detail) ??
      'Failed to migrate categories: $detail';

  String categoryMigrationFailed(String detail) =>
      _l10n?.migrationWarnCategoryMigrationFailed(detail) ??
      'Category migration failed: $detail';

  String chapterMigrateFailed(int chapterId, String detail) =>
      _l10n?.migrationWarnChapterMigrateFailed(chapterId, detail) ??
      'Failed to migrate chapter $chapterId: $detail';

  String get noMatchingChapters =>
      _l10n?.migrationWarnNoMatchingChapters ??
      'No matching chapters found for read status migration. '
          'This may be due to different chapter numbering between sources.';

  String chapterMigrationFailed(String detail) =>
      _l10n?.migrationWarnChapterMigrationFailed(detail) ??
      'Chapter migration failed: $detail';

  String clearCategoriesFailed(String detail) =>
      _l10n?.migrationWarnClearCategoriesFailed(detail) ??
      'Failed to clear categories for source manga: $detail';

  String removeSourceFailed(String detail) =>
      _l10n?.migrationWarnRemoveSourceFailed(detail) ??
      'Failed to remove source manga from library: $detail';

  String get removedSourceFromLibrary =>
      _l10n?.migrationWarnRemovedSourceFromLibrary ??
      'Removed original manga from library';

  String downloadsMigrationFailed(String detail) =>
      _l10n?.migrationWarnDownloadsMigrationFailed(detail) ??
      'Offline download migration failed: $detail';

  String downloadChapterSkipped(int chapterId) =>
      _l10n?.migrationWarnDownloadChapterSkipped(chapterId) ??
      'Could not migrate offline download for chapter $chapterId';

  String trackingMigrationFailed(String detail) =>
      _l10n?.migrationWarnTrackingMigrationFailed(detail) ??
      'Tracking migration failed: $detail';

  String trackingRecordFailed(String tracker, String detail) =>
      _l10n?.migrationWarnTrackingRecordFailed(tracker, detail) ??
      'Failed to migrate tracking for $tracker: $detail';

  String get trackingBindFailedDetail =>
      _l10n?.migrationWarnTrackingBindFailed ??
      'Could not bind to target manga';

  String partialFailure(int success, int total, int failed) =>
      _l10n?.migrationPartialFailure(success, total, failed) ??
      '$success/$total succeeded ($failed failed)';

  String migrationFailed(String detail) =>
      _l10n?.migrationFailedWithDetail(detail) ??
      'Migration failed: $detail';
}
