// IMP-030: typed ServerResult classification.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/server_result.dart';

class _Fake extends GraphQLClientService {
  _Fake(this.reply, this.transport) : super.forTesting();
  final Map<String, dynamic>? reply;
  final bool transport;
  @override
  bool get isConfigured => true;
  @override
  Future<Map<String, dynamic>?> deleteCategory(int categoryId) async {
    lastRequestWasTransportFailure = transport;
    return reply;
  }
}

void main() {
  test('ok / transport / rejected are distinguished', () async {
    final ok = await _Fake({'x': 1}, false).deleteCategoryResult(1);
    expect(ok, isA<ServerOk<Map<String, dynamic>>>());
    expect(ok.valueOrNull, {'x': 1});

    final t = await _Fake(null, true).deleteCategoryResult(1);
    expect(t.failureOrNull!.kind, ServerFailureKind.transport);
    expect(t.failureOrNull!.isRetryable, isTrue);

    final r = await _Fake(null, false).deleteCategoryResult(1);
    expect(r.failureOrNull!.kind, ServerFailureKind.rejected);
    expect(r.failureOrNull!.message, 'deleteCategory');
  });

  test('unconfigured client never calls through', () async {
    final c = GraphQLClientService.forTesting();
    final res = await c.deleteCategoryResult(1);
    expect(res.failureOrNull!.kind, ServerFailureKind.notConfigured);
  });

  test('legacy record converts and map() keeps failures', () {
    final rec = (data: null, wasTransportFailure: true);
    final res = rec.toServerResult(label: 'x');
    expect(res.map((m) => m.length).failureOrNull!.kind, ServerFailureKind.transport);
    expect((data: <String, dynamic>{'a': 1}, wasTransportFailure: false).toServerResult().map((m) => m.length).valueOrNull, 1);
  });
}
