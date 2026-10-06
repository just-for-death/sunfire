import 'package:flutter/foundation.dart';

/// Disposes dialog-owned controllers once the dialog has closed (UIS-12).
///
/// `showDialog<void>`'s future completes when the route is popped, but the dialog
/// is still on screen for its exit transition (150 ms for Material dialogs),
/// so disposal waits a little longer than that.
Future<void> disposeAfterDialog(Iterable<ChangeNotifier> controllers) async {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  for (final c in controllers) {
    c.dispose();
  }
}
