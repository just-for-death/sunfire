import 'package:flutter/widgets.dart';

import '../extensions/custom_extensions.dart';

/// Maps exceptions and API errors to user-readable localized text.
String userFacingError(BuildContext context, Object? error) {
  if (error == null) return context.l10n.errorSomethingWentWrong;
  final raw = error.toString();
  if (raw.contains('401') ||
      raw.contains('Unauthorized') ||
      raw.contains('Not logged in')) {
    return context.l10n.errorSomethingWentWrong;
  }
  if (raw.contains('SocketException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('NetworkException')) {
    return context.l10n.errorSomethingWentWrong;
  }
  if (raw.contains('TimeoutException') || raw.contains('No stream event')) {
    return context.l10n.errorSomethingWentWrong;
  }
  if (raw.contains('FormatException') || raw.contains('Exception:')) {
    return context.l10n.errorSomethingWentWrong;
  }
  // Short, user-authored messages (no stack traces) can pass through.
  if (raw.length <= 120 && !raw.contains('\n')) return raw;
  return context.l10n.errorSomethingWentWrong;
}
