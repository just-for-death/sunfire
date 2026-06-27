import '../../tracking/data/tracker_repository.dart';
import 'migration_messages.dart';

Future<({int migrated, List<String> warnings})> migrateTrackingRecords({
  required TrackerRepository trackerRepository,
  required int fromMangaId,
  required int toMangaId,
  required MigrationMessages messages,
}) async {
  final warnings = <String>[];
  var migrated = 0;

  try {
    final records = await trackerRepository.getTrackRecords(fromMangaId);
    for (final record in records) {
      final trackerLabel = record.trackerName ?? record.trackerId.toString();
      try {
        final bound = await trackerRepository.bindTrack(
          toMangaId,
          record.trackerId,
          record.remoteId,
        );
        if (bound != null) {
          try {
            await trackerRepository.updateTrack(
              recordId: bound.id,
              status: record.status,
              lastChapterRead: record.lastChapterRead,
              scoreString: record.displayScore,
              startDate: record.startDate,
              finishDate: record.finishDate,
            );
            await trackerRepository.unbindTrack(
              record.id,
              deleteRemoteTrack: false,
            );
            migrated++;
          } catch (e) {
            try {
              await trackerRepository.unbindTrack(
                bound.id,
                deleteRemoteTrack: false,
              );
            } catch (_) {}
            warnings.add(messages.trackingRecordFailed(trackerLabel, '$e'));
          }
        } else {
          warnings.add(
            messages.trackingRecordFailed(
              trackerLabel,
              messages.trackingBindFailedDetail,
            ),
          );
        }
      } catch (e) {
        warnings.add(messages.trackingRecordFailed(trackerLabel, '$e'));
      }
    }
  } catch (e) {
    warnings.add(messages.trackingMigrationFailed('$e'));
  }

  return (migrated: migrated, warnings: warnings);
}
