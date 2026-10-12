// lib/src/features/settings/sync_health_screen.dart
//
// S3.1 / S3.2: Sync health dashboard + cross-device status.

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/sync/cross_device_awareness.dart';
import '../../core/sync/sync_health_service.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../../ui/widgets/sync_ui_actions.dart';

class SyncHealthScreen extends StatefulWidget {
  const SyncHealthScreen({super.key});

  @override
  State<SyncHealthScreen> createState() => _SyncHealthScreenState();
}

class _SyncHealthScreenState extends State<SyncHealthScreen> {
  StreamSubscription<SyncHealth>? _sub;
  SyncHealth _health = SyncHealthService.instance.current;

  @override
  void initState() {
    super.initState();
    SyncHealthService.instance.start();
    CrossDeviceAwarenessService.instance.initialize();
    _health = SyncHealthService.instance.current;
    _sub = SyncHealthService.instance.stream.listen((h) {
      if (mounted) setState(() => _health = h);
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return 'Never';
    return dt.toLocal().toString().split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    final devices = CrossDeviceAwarenessService.instance.devices;
    final pendingConflicts = SyncManager.instance.pendingConflicts;

    return Scaffold(
      appBar: AppBar(
        title: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Sync Health'),
            SunfireBadge.local(),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Last successful sync'),
            subtitle: Text(_fmt(_health.lastSuccessfulSync)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Next scheduled sync'),
            subtitle: Text(_fmt(_health.nextScheduledSync)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pending mutations'),
            subtitle: Text('${_health.pendingCount}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Failed mutations'),
            subtitle: Text(
              '${_health.failedCount} (error rate ${_health.errorRate.toStringAsFixed(1)}%)',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pending conflicts'),
            subtitle: Text('${pendingConflicts.length}'),
            trailing: pendingConflicts.isEmpty
                ? null
                : TextButton(
                    onPressed: () => unawaited(
                      showConflictResolutionDialog(context, pendingConflicts),
                    ),
                    child: const Text('Resolve'),
                  ),
          ),
          const Divider(),
          const Text('Other devices', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (devices.isEmpty)
            const Text('No other devices reported yet.')
          else
            ...devices.map(
              (d) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  d.isCurrentDevice ? Icons.phone_android : Icons.devices_other,
                ),
                title: Text(d.name.isEmpty ? d.id : d.name),
                subtitle: Text(
                  '${d.isCurrentDevice ? "This device · " : ""}'
                  'Last seen ${_fmt(d.lastSeen)} · ${d.recordCount} records',
                ),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => unawaited(
              runSyncWithProgressDialog(
                context,
                title: 'Delta Sync',
                syncFn: () => SyncManager.instance.syncDelta(),
              ),
            ),
            icon: const Icon(Icons.sync),
            label: const Text('Run delta sync now'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => unawaited(
              runSyncWithProgressDialog(
                context,
                title: 'Full Sync',
                syncFn: () => SyncManager.instance.syncFull(),
              ),
            ),
            icon: const Icon(Icons.sync_lock),
            label: const Text('Run full sync'),
          ),
        ],
      ),
    );
  }
}
