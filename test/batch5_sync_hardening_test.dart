import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/services/server_tls_trust.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  group('isTransientSyncError', () {
    test('network exception types are transient', () {
      expect(isTransientSyncError(const SocketException('Connection refused')), isTrue);
      expect(isTransientSyncError(TimeoutException('slow')), isTrue);
    });

    test('network-style messages are transient', () {
      expect(isTransientSyncError(Exception('Failed host lookup: server.local')), isTrue);
      expect(isTransientSyncError(Exception('Connection reset by peer')), isTrue);
      expect(isTransientSyncError(Exception('Network is unreachable')), isTrue);
      expect(isTransientSyncError(Exception('request timed out')), isTrue);
    });

    test('server-side rejections mentioning "connection" are NOT transient', () {
      // The old bare substring match treated these as network drops and would
      // retry a genuinely rejected mutation forever.
      expect(isTransientSyncError(Exception('GraphQL: connection pool exhausted for tenant')), isFalse);
      expect(isTransientSyncError(Exception('Invalid input: chapter not found')), isFalse);
      expect(isTransientSyncError(const FormatException('bad json')), isFalse);
    });
  });

  group('retry accounting', () {
    test('transient failures do not consume a retry', () {
      expect(retryCountAfterFailure(2, transient: true), 2);
    });

    test('real failures consume one retry', () {
      expect(retryCountAfterFailure(2, transient: false), 3);
    });

    test('abandons at the retry limit', () {
      expect(
        stateAfterFailure(retryCount: kMaxSyncRetries, transient: false, recordAgeSeconds: 0),
        SyncRecordState.abandoned,
      );
      expect(
        stateAfterFailure(retryCount: kMaxSyncRetries - 1, transient: false, recordAgeSeconds: 0),
        SyncRecordState.failed,
      );
    });

    test('a fresh record failing transiently stays retryable', () {
      expect(
        stateAfterFailure(retryCount: 0, transient: true, recordAgeSeconds: 60),
        SyncRecordState.failed,
      );
    });

    test('a record failing transiently past the age ceiling is abandoned', () {
      expect(
        stateAfterFailure(retryCount: 0, transient: true, recordAgeSeconds: kTransientSyncMaxAgeSeconds),
        SyncRecordState.abandoned,
      );
    });

    test('age ceiling does not apply to counted (non-transient) failures below the limit', () {
      expect(
        stateAfterFailure(retryCount: 1, transient: false, recordAgeSeconds: kTransientSyncMaxAgeSeconds * 2),
        SyncRecordState.failed,
      );
    });
  });

  group('isPureChapterProgressPayload', () {
    test('accepts a plain progress payload', () {
      expect(isPureChapterProgressPayload('{"chapterId":5,"isRead":true,"lastPageRead":12}'), isTrue);
    });

    test('rejects a bookmark payload so progress never overwrites it', () {
      expect(isPureChapterProgressPayload('{"chapterId":5,"isBookmarked":true}'), isFalse);
    });

    test('rejects a mixed payload carrying a bookmark change too', () {
      expect(
        isPureChapterProgressPayload('{"chapterId":5,"isRead":true,"lastPageRead":3,"isBookmarked":true}'),
        isFalse,
      );
    });

    test('rejects a payload with no lastPageRead', () {
      expect(isPureChapterProgressPayload('{"chapterId":5,"isRead":true}'), isFalse);
    });

    test('rejects malformed JSON', () {
      expect(isPureChapterProgressPayload('not json'), isFalse);
      expect(isPureChapterProgressPayload('[1,2]'), isFalse);
    });
  });

  group('shouldTrustCertificateForHost', () {
    const server = 'https://manga.example.lan:4567';

    test('trusts the configured server host', () {
      expect(shouldTrustCertificateForHost('manga.example.lan', server), isTrue);
    });

    test('trusts loopback', () {
      expect(shouldTrustCertificateForHost('localhost', null), isTrue);
      expect(shouldTrustCertificateForHost('127.0.0.1', null), isTrue);
      expect(shouldTrustCertificateForHost('::1', ''), isTrue);
    });

    test('does not trust other hosts, including other LAN addresses', () {
      expect(shouldTrustCertificateForHost('evil.example.com', server), isFalse);
      expect(shouldTrustCertificateForHost('192.168.1.50', server), isFalse);
      expect(shouldTrustCertificateForHost('192.168.1.50', null), isFalse);
    });

    test('an unparseable or empty server url trusts nothing but loopback', () {
      expect(shouldTrustCertificateForHost('manga.example.lan', ''), isFalse);
      expect(shouldTrustCertificateForHost('manga.example.lan', 'not a url'), isFalse);
    });
  });
}
