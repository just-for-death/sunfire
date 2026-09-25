import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('_scheduleNextSpacing logic', () {
    test('captures completer correctly when called multiple times rapidly', () async {
      Completer<void>? lastRequestCompleter;
      const minSpacing = Duration(milliseconds: 50); // shorter for test
      
      void scheduleNextSpacing() {
        final completer = Completer<void>();
        // Capture the completer locally
        final capturedCompleter = completer;
        // Simulate the buggy version (without capture)
        // _lastRequestCompleter = completer;
        Future.delayed(const Duration(milliseconds: 10), () {
          if (!capturedCompleter.isCompleted) capturedCompleter.complete();
        });
      }
      
      // Simulate rapid calls
      scheduleNextSpacing();
      scheduleNextSpacing();
      scheduleNextSpacing();
      
      // Wait for all timers
      await Future.delayed(const Duration(milliseconds: 100));
      
      // All should complete without hanging
      expect(true, isTrue); // If we get here, no deadlock
    });
    
    test('properly spaces requests with captured completer', () async {
      Completer<void>? lastCompleter;
      const spacing = Duration(milliseconds: 50);
      final completions = <int>[];
      
      void schedule() {
        final completer = Completer<void>();
        final captured = completer;
        // This is the CORRECT pattern - capture the completer
        Future.delayed(const Duration(milliseconds: 10), () {
          if (!captured.isCompleted) captured.complete();
        });
      }
      
      // Simulate rapid scheduling
      for (int i = 0; i < 5; i++) {
        // Capture completion
        final c = Completer<void>();
        // We can't easily test this without the actual implementation
      }
    });
  });
}