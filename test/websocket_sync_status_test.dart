// IMP-006: syncStatusChanged subscription frames reach onSyncStatus.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/websocket_service.dart';

String _next(String id, Map<String, dynamic> data) => jsonEncode({
      'id': id,
      'type': 'next',
      'payload': {'data': data},
    });

void main() {
  final ws = WebSocketService.instance;

  test('syncStatusChanged frame is emitted on onSyncStatus only', () async {
    final sync = <Map<String, dynamic>>[];
    final downloads = <Map<String, dynamic>>[];
    final s1 = ws.onSyncStatus.listen(sync.add);
    final s2 = ws.onDownloadStatus.listen(downloads.add);
    ws.debugHandleMessage(_next('3', {
      'syncStatusChanged': {'state': 'MERGING', 'startDate': '1', 'endDate': null, 'errorMessage': null, 'backupRestoreId': null},
    }));
    await Future<void>.delayed(Duration.zero);
    expect(sync.single['state'], 'MERGING');
    expect(downloads, isEmpty);
    await s1.cancel();
    await s2.cancel();
  });

  test('download frames still route to onDownloadStatus, not onSyncStatus', () async {
    final sync = <Map<String, dynamic>>[];
    final downloads = <Map<String, dynamic>>[];
    final s1 = ws.onSyncStatus.listen(sync.add);
    final s2 = ws.onDownloadStatus.listen(downloads.add);
    ws.debugHandleMessage(_next('2', {
      'downloadStatusChanged': {'state': 'STARTED', 'omittedUpdates': false},
    }));
    await Future<void>.delayed(Duration.zero);
    expect(downloads, hasLength(1));
    expect(sync, isEmpty);
    await s1.cancel();
    await s2.cancel();
  });

  test('malformed or error frames for id 3 are ignored', () async {
    final sync = <Map<String, dynamic>>[];
    final s1 = ws.onSyncStatus.listen(sync.add);
    ws.debugHandleMessage(_next('3', {'syncStatusChanged': 'nope'}));
    ws.debugHandleMessage(jsonEncode({'id': '3', 'type': 'error', 'payload': [{'message': 'Cannot query field'}]}));
    await Future<void>.delayed(Duration.zero);
    expect(sync, isEmpty);
    await s1.cancel();
  });
}
