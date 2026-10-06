import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/sync/server_session_service.dart';
import '../../ui/widgets/dialog_title.dart';

/// Shows the Suwayomi UI_LOGIN / SIMPLE_LOGIN form (ISS-078 / B2).
///
/// Returns `true` when login succeeded. Pass [authMode] from
/// `settings.authMode` (or omit to use [mode]).
Future<bool> showServerLoginSheet(
  BuildContext context, {
  String? authMode,
  ServerLoginMode? mode,
  String? baseUrl,
  String? initialUsername,
}) async {
  final resolved = mode ?? loginModeForAuthMode(authMode);
  if (resolved == null) return false;
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: _ServerLoginSheet(
        mode: resolved,
        baseUrl: baseUrl,
        initialUsername: initialUsername,
      ),
    ),
  );
  return result == true;
}

class _ServerLoginSheet extends StatefulWidget {
  const _ServerLoginSheet({
    required this.mode,
    this.baseUrl,
    this.initialUsername,
  });

  final ServerLoginMode mode;
  final String? baseUrl;
  final String? initialUsername;

  @override
  State<_ServerLoginSheet> createState() => _ServerLoginSheetState();
}

class _ServerLoginSheetState extends State<_ServerLoginSheet> {
  late final TextEditingController _user;
  late final TextEditingController _pass;
  bool _busy = false;
  String? _error;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _user = TextEditingController(text: widget.initialUsername ?? '');
    _pass = TextEditingController();
  }

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ServerSessionService.instance.login(
      username: _user.text,
      password: _pass.text,
      mode: widget.mode,
      baseUrl: widget.baseUrl,
    );
    if (!mounted) return;
    if (result.success) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _error = result.error ?? 'Login failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = widget.mode == ServerLoginMode.uiLogin ? 'Server login' : 'Simple login';
    final subtitle = widget.mode == ServerLoginMode.uiLogin
        ? 'Sign in with your Suwayomi UI account (JWT).'
        : 'Sign in with the server’s simple login form.';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            DialogTitle(icon: Icons.login_rounded, text: title),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            TextField(
              key: const Key('server_login_username'),
              controller: _user,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('server_login_password'),
              controller: _pass,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => unawaited(_submit()),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, key: const Key('server_login_error'), style: TextStyle(color: cs.error, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('server_login_submit'),
              onPressed: _busy ? null : () => unawaited(_submit()),
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label for login mode tests / About tiles.
String serverLoginModeLabel(ServerLoginMode mode) =>
    mode == ServerLoginMode.uiLogin ? 'UI login' : 'Simple login';
