import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../routes/route_redirect.dart';
import '../../routes/router_config.dart';

/// Listens for `catalyst://` deep links and navigates via [GoRouter].
class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({super.key, required this.child});

  final Widget? child;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _subscription = _appLinks.uriLinkStream.listen(_navigateToUri);
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _navigateToUri(uri);
    } catch (_) {
      // Ignore — platform may not support app links.
    }
  }

  void _navigateToUri(Uri uri) {
    final path = deepLinkPathFromUri(uri);
    if (path == null) return;
    final router = ref.read(routerConfigProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      router.go(path);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox.shrink();
}
