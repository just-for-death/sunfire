import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

T? usePolling<T>({
  required Duration pollingInterval,
  required FutureOr<T> Function() pollFunction,
  bool delayedStart = false,
}) {
  final data = useState<T?>(null);

  useEffect(() {
    // Cancellation flag — set to true in cleanup to stop the loop.
    bool cancelled = false;

    Future<void> poll() async {
      while (!cancelled) {
        if (delayedStart) {
          await Future.delayed(pollingInterval);
          if (cancelled) return;
        }
        try {
          final result = await pollFunction();
          if (!cancelled) {
            data.value = result;
          }
        } catch (_) {
          // Ignore errors during polling to avoid crashing on widget disposal.
        }
        if (!delayedStart) {
          await Future.delayed(pollingInterval);
        }
      }
    }

    poll();

    // Cleanup: signal the loop to exit on next iteration.
    return () {
      cancelled = true;
    };
  }, []);

  return data.value;
}
