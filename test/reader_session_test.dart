import 'package:catalyst/src/features/manga_book/presentation/reader/utils/reader_session.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int disableCount;

  setUp(() {
    disableCount = 0;
    WakelockPlusBridge.register(
      enable: () {},
      disable: () => disableCount++,
    );
  });

  /// A frame has to actually run for [ReaderSession.beginTransition]'s
  /// post-frame callback to fire. In the app the rebuild caused by navigation
  /// schedules one; the test harness only pumps when a frame is pending.
  Future<void> runFrame(WidgetTester tester) async {
    SchedulerBinding.instance.scheduleFrame();
    await tester.pump();
  }

  testWidgets('closing the reader restores the wakelock', (tester) async {
    ReaderSession.enter();
    ReaderSession.leave();
    await runFrame(tester);

    expect(disableCount, 1);
  });

  testWidgets('a chapter change keeps the session open, and exit still ends it',
      (tester) async {
    // Chapter changes use pushReplacement: the guard holds the session open
    // while the outgoing screen is disposed, then balances itself.
    ReaderSession.enter(); // chapter A open
    ReaderSession.beginTransition(); // navigating to chapter B
    ReaderSession.enter(); // chapter B mounts
    ReaderSession.leave(); // chapter A disposes
    await runFrame(tester);

    expect(
      disableCount,
      0,
      reason: 'the wakelock must stay on across a chapter change',
    );

    ReaderSession.leave(); // user closes the reader
    await runFrame(tester);

    expect(
      disableCount,
      1,
      reason: 'session depth must reach zero after leaving the reader',
    );
  });

  testWidgets('repeated chapter changes do not leak session depth',
      (tester) async {
    ReaderSession.enter();
    for (var i = 0; i < 5; i++) {
      ReaderSession.beginTransition();
      ReaderSession.enter();
      ReaderSession.leave();
      await runFrame(tester);
    }
    expect(disableCount, 0);

    ReaderSession.leave();
    await runFrame(tester);

    expect(disableCount, 1);
  });
}
