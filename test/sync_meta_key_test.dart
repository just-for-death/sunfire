// Guards the keyed SyncMeta contract used by last-sync timestamp helpers.

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/isar_service.dart';

void main() {
  test('last sync meta key is stable and non-empty', () {
    expect(IsarService.kLastSyncMetaKey, 'last_sync');
    expect(IsarService.kLastSyncMetaKey, isNotEmpty);
  });
}
