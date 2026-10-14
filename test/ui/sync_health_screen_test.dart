import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/websocket_service.dart';
import 'package:sunfire/src/features/settings/sync_health_screen.dart';

String _next(String id, Map<String, dynamic> data) => jsonEncode({
      'id': id,
      'type': 'next',
      'payload': {'data': data},
    });

void main() {
  testWidgets('UIS6-23: SyncHealthScreen updates with live server sync status', (tester) async {
    final ws = WebSocketService.instance;

    await tester.pumpWidget(const MaterialApp(
      home: SyncHealthScreen(),
    ));
    await tester.pump();

    expect(find.text('Live server sync state'), findsNothing);

    ws.debugHandleMessage(_next('3', {
      'syncStatusChanged': {
        'state': 'MERGING',
        'startDate': '1',
        'endDate': null,
        'errorMessage': null,
        'backupRestoreId': null,
      },
    }));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('Live server sync state'), findsOneWidget);
    expect(find.text('MERGING'), findsOneWidget);
  });
}
