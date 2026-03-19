import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../constants/db_keys.dart';
import '../../../../constants/endpoints.dart';
import '../../../../features/settings/presentation/server/widget/client/server_port_tile/server_port_tile.dart';
import '../../../../features/settings/presentation/server/widget/client/server_url_tile/server_url_tile.dart';
import '../../../../widgets/emoticons.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../routes/router_config.dart';

part 'server_connectivity.g.dart';

enum ServerStatus { checking, online, offline }

@riverpod
class ServerConnectivity extends _$ServerConnectivity {
  Timer? _retryTimer;

  @override
  ServerStatus build() {
    ref.onDispose(() => _retryTimer?.cancel());
    // Watch server URL changes — recheck whenever it changes
    ref.watch(serverUrlProvider);
    ref.watch(serverPortProvider);
    Future.microtask(checkServer);
    return ServerStatus.checking;
  }

  Future<void> checkServer() async {
    state = ServerStatus.checking;
    try {
      final baseUrl = ref.read(serverUrlProvider) ?? DBKeys.serverUrl.initial;
      final port    = ref.read(serverPortProvider);
      final addPort = true;
      final pingUrl = Endpoints.baseApi(
        baseUrl: baseUrl,
        port: port,
        addPort: addPort,
        appendApiToUrl: true,
        isGraphQl: false,
      );
      final response = await http
          .get(Uri.parse(pingUrl))
          .timeout(const Duration(seconds: 5));
      state = response.statusCode < 500
          ? ServerStatus.online
          : ServerStatus.offline;
    } on SocketException {
      state = ServerStatus.offline;
      _scheduleRetry();
    } on TimeoutException {
      state = ServerStatus.offline;
      _scheduleRetry();
    } catch (_) {
      state = ServerStatus.offline;
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 10), checkServer);
  }
}

/// Wraps a screen — shows an offline banner + retry when server is unreachable.
/// If [blockWhenOffline] is true it replaces the child entirely with the offline UI.
class ServerAwareWrapper extends ConsumerWidget {
  const ServerAwareWrapper({
    super.key,
    required this.child,
    this.blockWhenOffline = false,
  });

  final Widget child;
  final bool blockWhenOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(serverConnectivityProvider);

    if (status == ServerStatus.online) return child;

    if (status == ServerStatus.checking) {
      return blockWhenOffline
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : child;
    }

    // Offline
    if (blockWhenOffline) {
      return Scaffold(
        body: _OfflineBody(
          onRetry: () =>
              ref.read(serverConnectivityProvider.notifier).checkServer(),
          onSettings: () => const ServerSettingsRoute().push(context),
        ),
      );
    }

    // Non-blocking — show child with a dismissible banner at top
    return Stack(
      children: [
        child,
        _OfflineBanner(
          onRetry: () =>
              ref.read(serverConnectivityProvider.notifier).checkServer(),
        ),
      ],
    );
  }
}

class _OfflineBody extends StatelessWidget {
  const _OfflineBody({required this.onRetry, required this.onSettings});
  final VoidCallback onRetry;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 72, color: cs.onSurface.withOpacity(.35)),
            const SizedBox(height: 24),
            Text(
              'Server unreachable',
              style: context.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure Suwayomi Server is running\nand the URL is correct in Settings.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurface.withOpacity(.6)),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Server Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: cs.errorContainer,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 18, color: cs.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Server offline — retrying…',
                  style: context.textTheme.labelMedium
                      ?.copyWith(color: cs.onErrorContainer),
                ),
              ),
              GestureDetector(
                onTap: onRetry,
                child: Icon(Icons.refresh_rounded,
                    size: 18, color: cs.onErrorContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
