import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/download_manager_service.dart';
import '../../core/sync/download_status_merge.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/websocket_service.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../ui/design_system/sunfire_theme.dart';
import '../../ui/shell/sunfire_breakpoints.dart';

class DownloadQueueScreen extends StatefulWidget {
  const DownloadQueueScreen({super.key});

  @override
  State<DownloadQueueScreen> createState() => _DownloadQueueScreenState();
}

class _DownloadQueueScreenState extends State<DownloadQueueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DownloadManagerService _downloadService = DownloadManagerService.instance;

  Map<String, dynamic>? _serverStatus;
  bool _isLoadingServer = false;
  StreamSubscription<Map<String, dynamic>>? _wsDownloadSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    unawaited(_fetchServerDownloadStatus());
    // Live server queue (ISS-061): status used to be fetched once at open.
    _wsDownloadSub = WebSocketService.instance.onDownloadStatus.listen((event) {
      if (!mounted) return;
      final merged = mergeDownloadStatusEvent(_serverStatus, event);
      setState(() {
        _serverStatus = merged.status;
        _isLoadingServer = false;
      });
      if (merged.needsRefetch) {
        unawaited(_fetchServerDownloadStatus());
      }
    });
  }

  @override
  void dispose() {
    unawaited(_wsDownloadSub?.cancel());
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchServerDownloadStatus() async {
    if (!GraphQLClientService.instance.isConfigured) return;
    setState(() => _isLoadingServer = true);
    try {
      final data = await GraphQLClientService.instance.fetchDownloadStatus();
      if (mounted) {
        setState(() {
          _serverStatus = data?['downloadStatus'] as Map<String, dynamic>?;
          _isLoadingServer = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingServer = false);
    }
  }

  Future<void> _applyDownloadMutation(Map<String, dynamic>? res) async {
    if (!mounted) return;
    final status = downloadStatusFromMutation(res);
    if (status != null) {
      setState(() {
        _serverStatus = status;
        _isLoadingServer = false;
      });
      return;
    }
    await _fetchServerDownloadStatus();
  }

  Future<void> _dequeueServerItem(int chapterId) async {
    if (chapterId <= 0) return;
    final res = await GraphQLClientService.instance.dequeueChapterDownload(chapterId);
    await _applyDownloadMutation(res);
  }

  Future<void> _reorderServerItem(int chapterId, int to) async {
    if (chapterId <= 0) return;
    final res = await GraphQLClientService.instance.reorderChapterDownload(chapterId, to);
    await _applyDownloadMutation(res);
  }

  Future<void> _retryServerItem(int chapterId) async {
    if (chapterId <= 0) return;
    // Re-enqueue; server treats this as a retry for ERROR/queued items.
    await GraphQLClientService.instance.enqueueChapterDownload(chapterId);
    await _fetchServerDownloadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isTablet = MediaQuery.of(context).size.width >= SunfireBreakpoints.narrowTabletMaxWidth;
    final isServerTab = _tabController.index == 1;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isTablet ? 64.0 : kToolbarHeight,
        title: const Text('Download Manager', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/more');
            }
          },
        ),
        actions: isServerTab
            ? [
                if (GraphQLClientService.instance.isConfigured) ...[
                  IconButton(
                    icon: Icon(
                      (_serverStatus?['state'] as String? ?? 'STOPPED') == 'RUNNING'
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    tooltip: (_serverStatus?['state'] as String? ?? 'STOPPED') == 'RUNNING'
                        ? 'Pause server downloader'
                        : 'Start server downloader',
                    onPressed: () async {
                      if ((_serverStatus?['state'] as String? ?? 'STOPPED') == 'RUNNING') {
                        await GraphQLClientService.instance.stopDownloader();
                      } else {
                        await GraphQLClientService.instance.startDownloader();
                      }
                      await _fetchServerDownloadStatus();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear_all_rounded),
                    tooltip: 'Clear server queue',
                    onPressed: () async {
                      await GraphQLClientService.instance.clearDownloader();
                      await _fetchServerDownloadStatus();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cleared server download queue')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh server queue',
                    onPressed: _fetchServerDownloadStatus,
                  ),
                ],
              ]
            : [
                ListenableBuilder(
                  listenable: _downloadService,
                  builder: (context, _) {
                    final isPaused = _downloadService.isQueuePaused;
                    final hasActive = _downloadService.localTasks.any(
                      (t) => t.status == LocalDownloadStatus.downloading || t.status == LocalDownloadStatus.queued || t.status == LocalDownloadStatus.paused,
                    );
                    if (!hasActive) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                      tooltip: isPaused ? 'Resume queue' : 'Pause queue',
                      onPressed: () {
                        if (isPaused) {
                          unawaited(_downloadService.resumeLocalQueue());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Resumed download queue'), duration: Duration(seconds: 2)),
                          );
                        } else {
                          unawaited(_downloadService.pauseLocalQueue());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Paused download queue'), duration: Duration(seconds: 2)),
                          );
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all_rounded),
                  tooltip: 'Clear completed',
                  onPressed: () {
                    _downloadService.clearCompletedDownloads();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cleared completed downloads')),
                    );
                  },
                ),
              ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Local Device'),
            Tab(text: 'Suwayomi Server'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocalDownloadsTab(primaryColor),
          _buildServerDownloadsTab(primaryColor),
        ],
      ),
    );
  }

  Widget _buildLocalDownloadsTab(Color primaryColor) {
    return ListenableBuilder(
      listenable: _downloadService,
      builder: (context, _) {
        final tasks = _downloadService.localTasks;
        if (tasks.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.download_done_rounded,
            title: 'No Active Downloads',
            subtitle: 'There are no local downloads currently active or queued.',
          );
        }

        final waitingForCharger = _downloadService.isWaitingForCharger;
        final queueList = ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            SunfireBreakpoints.scrollBottomPadding(context),
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Material(
                color: SunfireTheme.tileSurface(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: SunfireTheme.tileBorder(context), width: 0.8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(task.mangaTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(task.chapterName, style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      if (task.status == LocalDownloadStatus.downloading) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: task.progress,
                            minHeight: 4,
                            backgroundColor: SunfireTheme.overlayFill(context),
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(task.progress * 100).toInt()}% • Downloading...',
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ] else if (task.status == LocalDownloadStatus.completed) ...[
                        Text('Completed', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.bold)),
                      ] else if (task.status == LocalDownloadStatus.queued) ...[
                        Text('Queued', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                      ] else if (task.status == LocalDownloadStatus.paused) ...[
                        Text('Paused', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                      ] else ...[
                        Text(
                          'Failed: ${task.error ?? "Unknown error"}',
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                  trailing: task.status == LocalDownloadStatus.downloading || task.status == LocalDownloadStatus.queued || task.status == LocalDownloadStatus.paused
                      ? IconButton(
                          icon: Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
                          tooltip: 'Cancel download',
                          onPressed: () => _downloadService.cancelLocalDownload(task.chapterId),
                        )
                      : task.status == LocalDownloadStatus.completed
                          ? IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              tooltip: 'Delete downloaded files',
                              onPressed: () => _downloadService.deleteLocalDownload(task.chapterId),
                            )
                          : task.status == LocalDownloadStatus.failed
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.refresh_rounded, color: Theme.of(context).colorScheme.secondary),
                                      tooltip: 'Retry download',
                                      onPressed: () => _downloadService.enqueueLocalDownload(
                                        chapterId: task.chapterId,
                                        mangaId: task.mangaId,
                                        chapterName: task.chapterName,
                                        mangaTitle: task.mangaTitle,
                                        chapterNumber: task.chapterNumber,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      tooltip: 'Dismiss',
                                      onPressed: () => _downloadService.dismissLocalTask(task.chapterId),
                                    ),
                                  ],
                                )
                              : null,
                ),
              ),
            );
          },
        );

        if (!waitingForCharger) return queueList;
        return Column(
          children: [
            Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: SunfireTheme.tileSurface(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.secondary.withValues(alpha: 0.45), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.battery_charging_full_rounded, color: cs.secondary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Queue paused — "Download only while charging" is on. Downloads resume when the device is plugged in.',
                          style: TextStyle(fontSize: 12.5, color: cs.secondary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(child: queueList),
          ],
        );
      },
    );
  }

  Widget _buildServerDownloadsTab(Color primaryColor) {
    if (!GraphQLClientService.instance.isConfigured) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 54, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(120)),
              const SizedBox(height: 16),
              const Text('No Suwayomi Server Connected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Connect a Suwayomi server in Settings to manage remote server downloads, or use the Local Device tab for offline reading.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.onPrimary),
                label: Text('Server Settings', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                onPressed: () => context.push('/settings/server'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingServer) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    final queue = _serverStatus?['queue'] as List<dynamic>? ?? [];
    final state = _serverStatus?['state'] as String? ?? 'STOPPED';

    if (queue.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.cloud_done_rounded,
        title: 'Server Queue Empty',
        subtitle: 'Server Downloader is $state.',
      );
    }

    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        SunfireBreakpoints.scrollBottomPadding(context),
      ),
      itemCount: queue.length,
      onReorderItem: (oldIndex, newIndex) {
        // onReorderItem already adjusts newIndex for the removed slot.
        if (oldIndex == newIndex) return;
        final rawItem = queue[oldIndex];
        if (rawItem is! Map<String, dynamic>) return;
        final chMap = rawItem['chapter'] as Map<String, dynamic>?;
        final chId = parseIntSafe(chMap?['id']);
        if (chId <= 0) return;
        // Optimistic local reorder so the drag feels instant.
        final mutable = List<dynamic>.from(queue);
        final moved = mutable.removeAt(oldIndex);
        mutable.insert(newIndex, moved);
        setState(() {
          _serverStatus = {
            ...?_serverStatus,
            'queue': mutable,
          };
        });
        unawaited(_reorderServerItem(chId, newIndex));
      },
      itemBuilder: (context, index) {
        final rawItem = queue[index];
        if (rawItem is! Map<String, dynamic>) {
          return SizedBox.shrink(key: ValueKey('server_dl_bad_$index'));
        }
        final item = rawItem;
        final chMap = item['chapter'] as Map<String, dynamic>?;
        final chName = chMap?['name'] as String? ?? 'Chapter';
        final chId = parseIntSafe(chMap?['id']);
        final progress = parseDoubleSafe(item['progress']);
        final itemState = item['state'] as String? ?? 'QUEUED';

        final mangaMap = item['manga'] as Map<String, dynamic>?;
        final mangaTitle = (mangaMap?['title'] as String?)?.trim();
        final tries = downloadItemTries(item);
        final isError = isDownloadItemError(item) ||
            itemState.toUpperCase().contains('FAIL');
        final cs = Theme.of(context).colorScheme;
        final statusLine = serverDownloadStatusLabel(
          state: itemState,
          progress: progress,
          tries: tries,
        );
        final rowKey = ValueKey('server_download_row_${chId}_$index');

        return Padding(
          key: rowKey,
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Material(
            color: SunfireTheme.tileSurface(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isError ? cs.error.withValues(alpha: 0.55) : SunfireTheme.tileBorder(context),
                width: 0.8,
              ),
            ),
            child: ListTile(
              leading: ReorderableDragStartListener(
                index: index,
                child: Icon(Icons.drag_handle_rounded, color: cs.onSurfaceVariant),
              ),
              title: Text(
                (mangaTitle != null && mangaTitle.isNotEmpty) ? mangaTitle : chName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mangaTitle != null && mangaTitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      chName,
                      style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress > 0 && !isError ? progress : null,
                      minHeight: 4,
                      backgroundColor: SunfireTheme.overlayFill(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isError ? cs.error : primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusLine,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isError ? FontWeight.w600 : FontWeight.normal,
                      color: isError ? cs.error : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isError)
                    IconButton(
                      key: Key('server_download_retry_$chId'),
                      icon: Icon(Icons.refresh_rounded, color: primaryColor),
                      tooltip: 'Retry download',
                      onPressed: () => unawaited(_retryServerItem(chId)),
                    ),
                  IconButton(
                    key: Key('server_download_dequeue_$chId'),
                    icon: Icon(Icons.close_rounded, color: cs.error),
                    tooltip: 'Remove from server queue',
                    onPressed: () => unawaited(_dequeueServerItem(chId)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


/// Status line for a live server-queue row (ISS-067 / Q3).
String serverDownloadStatusLabel({
  required String state,
  required double progress,
  int tries = 0,
}) {
  final upper = state.toUpperCase();
  final pct = (progress * 100).toInt();
  final base = upper.contains('ERROR') || upper.contains('FAIL')
      ? 'ERROR • $pct%'
      : '$state • $pct%';
  if (tries > 0) return '$base • $tries tries';
  return base;
}


/// Pull `downloadStatus` from a dequeue/reorder GraphQL mutation map (ISS-080).
Map<String, dynamic>? downloadStatusFromMutation(Map<String, dynamic>? res) {
  if (res == null) return null;
  final direct = res['downloadStatus'];
  if (direct is Map) return Map<String, dynamic>.from(direct);
  for (final value in res.values) {
    if (value is! Map) continue;
    final nested = value['downloadStatus'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    if (value.containsKey('queue') && value.containsKey('state')) {
      return Map<String, dynamic>.from(value);
    }
  }
  return null;
}
