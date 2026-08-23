import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/download_manager_service.dart';
import '../../core/sync/graphql_client_service.dart';

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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_done_rounded, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No local downloads active or queued.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
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
                          onPressed: () => _downloadService.cancelLocalDownload(task.chapterId),
                        )
                      : task.status == LocalDownloadStatus.completed
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                              onPressed: () => _downloadService.deleteLocalDownload(task.chapterId),
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
    if (_isLoadingServer) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    final queue = _serverStatus?['queue'] as List<dynamic>? ?? [];
    final state = _serverStatus?['state'] as String? ?? 'STOPPED';

    if (queue.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_done_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Server Downloader is $state.\nQueue is empty.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
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
