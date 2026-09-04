import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/download_manager_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/widgets/empty_state_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchServerDownloadStatus();
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Manager', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh server queue',
            onPressed: _fetchServerDownloadStatus,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
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

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Material(
                color: const Color(0x1F2A2A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
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
                            backgroundColor: const Color(0x33FFFFFF),
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('${(task.progress * 100).toInt()}% • Downloading...', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ] else if (task.status == LocalDownloadStatus.completed) ...[
                        const Text('Completed', style: TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      ] else if (task.status == LocalDownloadStatus.queued) ...[
                        const Text('Queued', style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)),
                      ] else ...[
                        Text('Failed: ${task.error ?? "Unknown error"}', style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                      ],
                    ],
                  ),
                  trailing: task.status == LocalDownloadStatus.downloading || task.status == LocalDownloadStatus.queued
                      ? IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                          tooltip: 'Cancel download',
                          onPressed: () => _downloadService.cancelLocalDownload(task.chapterId),
                        )
                      : task.status == LocalDownloadStatus.completed
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                              tooltip: 'Delete downloaded files',
                              onPressed: () => _downloadService.deleteLocalDownload(task.chapterId),
                            )
                          : task.status == LocalDownloadStatus.failed
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.refresh_rounded, color: Colors.amberAccent),
                                      tooltip: 'Retry download',
                                      onPressed: () => _downloadService.enqueueLocalDownload(
                                        chapterId: task.chapterId,
                                        mangaId: task.mangaId,
                                        chapterName: task.chapterName,
                                        mangaTitle: task.mangaTitle,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                                      tooltip: 'Dismiss',
                                      onPressed: () => _downloadService.cancelLocalDownload(task.chapterId),
                                    ),
                                  ],
                                )
                              : null,
                ),
              ),
            );
          },
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
              Icon(Icons.cloud_off_rounded, size: 54, color: Colors.grey.withAlpha(120)),
              const SizedBox(height: 16),
              const Text('No Suwayomi Server Connected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text(
                'Connect a Suwayomi server in Settings to manage remote server downloads, or use the Local Device tab for offline reading.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                label: const Text('Server Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: queue.length,
      itemBuilder: (context, index) {
        final item = queue[index] as Map<String, dynamic>;
        final chMap = item['chapter'] as Map<String, dynamic>?;
        final chName = chMap?['name'] as String? ?? 'Chapter';
        final chId = parseIntSafe(chMap?['id']);
        final progress = parseDoubleSafe(item['progress']);
        final itemState = item['state'] as String? ?? 'QUEUED';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Material(
            color: const Color(0x1F2A2A32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
            ),
            child: ListTile(
              title: Text(chName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress > 0 ? progress : null,
                      minHeight: 4,
                      backgroundColor: const Color(0x33FFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$itemState • ${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () async {
                  await _downloadService.deleteServerDownload(chId);
                  _fetchServerDownloadStatus();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
