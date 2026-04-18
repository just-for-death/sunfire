import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../constants/db_keys.dart';
import '../../../../constants/endpoints.dart';
import '../../../../features/settings/presentation/server/widget/client/server_port_tile/server_port_tile.dart';
import '../../../../features/settings/presentation/server/widget/client/server_url_tile/server_url_tile.dart';
import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import 'server_connectivity_config.dart';

part 'server_connectivity.g.dart';

enum ServerStatus { checking, online, offline }

/// HTTP GET for server reachability checks. Override in tests to mock responses.
@riverpod
Future<http.Response> Function(Uri uri) serverConnectivityHttpGet(Ref ref) {
  return (uri) => http.get(uri).timeout(const Duration(seconds: 5));
}

@riverpod
class ServerConnectivity extends _$ServerConnectivity {
  Timer? _retryTimer;

  /// When true, [build] does not schedule the initial [checkServer] microtask.
  /// Used by tests that call [checkServer] explicitly to avoid overlapping work.
  static bool debugSkipInitialMicrotaskPing = false;

  @override
  ServerStatus build() {
    ref.onDispose(() => _retryTimer?.cancel());
    ref.watch(serverUrlProvider);
    ref.watch(serverPortProvider);
    ref.watch(serverPortToggleProvider);
    ref.watch(serverConnectivityHttpGetProvider);
    if (!debugSkipInitialMicrotaskPing) {
      Future.microtask(checkServer);
    }
    return ServerStatus.checking;
  }

  Future<void> checkServer() async {
    state = ServerStatus.checking;
    try {
      final baseUrl = ref.read(serverUrlProvider) ?? DBKeys.serverUrl.initial;
      final port = ref.read(serverPortProvider);
      final addPort = ref.read(serverPortToggleProvider).ifNull();
      final pingUrl = Endpoints.baseApi(
        baseUrl: baseUrl,
        port: port,
        addPort: addPort,
        appendApiToUrl: true,
        isGraphQl: false,
      );
      final get = ref.read(serverConnectivityHttpGetProvider);
      final response = await get(Uri.parse(pingUrl));
      if (response.statusCode < 500) {
        _retryTimer?.cancel();
        state = ServerStatus.online;
      } else {
        state = ServerStatus.offline;
        _scheduleRetry();
      }
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
    final delay = ref.read(serverConnectivityRetryDelayProvider);
    _retryTimer = Timer(delay, checkServer);
  }
}

/// Wraps a screen — shows an offline banner + retry when server is unreachable.
/// If [blockWhenOffline] is true it replaces the child entirely with the offline UI.
class ServerAwareWrapper extends HookConsumerWidget {
  const ServerAwareWrapper({
    super.key,
    required this.child,
    this.blockWhenOffline = false,
  });

  final Widget child;
  final bool blockWhenOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerDismissed = useState(false);
    final status = ref.watch(serverConnectivityProvider);

    ref.listen(serverConnectivityProvider, (previous, next) {
      if (next == ServerStatus.online) bannerDismissed.value = false;
    });

    if (status == ServerStatus.online) return child;

    if (status == ServerStatus.checking) {
      return blockWhenOffline
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : child;
    }

    if (blockWhenOffline) {
      return Scaffold(
        body: _OfflineBody(
          onRetry: () =>
              ref.read(serverConnectivityProvider.notifier).checkServer(),
          onSettings: () => const ServerSettingsRoute().push(context),
        ),
      );
    }

    if (bannerDismissed.value) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        _OfflineBanner(
          onRetry: () =>
              ref.read(serverConnectivityProvider.notifier).checkServer(),
          onDismiss: () => bannerDismissed.value = true,
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
            Icon(
              Icons.cloud_off_rounded,
              size: 72,
              color: cs.onSurface.withValues(alpha: .35),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.serverUnreachableTitle,
              style: context.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.serverUnreachableBody,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurface.withValues(alpha: .6)),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.serverRetryButton),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
              label: Text(context.l10n.serverOpenSettingsButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry, required this.onDismiss});
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: cs.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.serverOfflineBanner,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium
                      ?.copyWith(color: cs.onErrorContainer),
                ),
              ),
              IconButton(
                onPressed: onRetry,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: cs.onErrorContainer,
                ),
                tooltip: context.l10n.serverOfflineRetryA11y,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  color: cs.onErrorContainer,
                ),
                tooltip: context.l10n.serverOfflineDismissA11y,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
