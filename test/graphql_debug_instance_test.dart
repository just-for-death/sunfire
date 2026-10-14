// GraphQLClientService.debugInstance: tests can swap in a fake client.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

class _FakeClient extends GraphQLClientService {
  _FakeClient() : super.forTesting();
  final calls = <int>[];

  @override
  Future<Map<String, dynamic>?> deleteCategory(int categoryId) async {
    calls.add(categoryId);
    return {'ok': true};
  }
}

void main() {
  tearDown(() => GraphQLClientService.debugInstance = null);

  test('instance honours debugInstance and resets to the real singleton', () async {
    final real = GraphQLClientService.instance;
    final fake = _FakeClient();
    GraphQLClientService.debugInstance = fake;
    expect(identical(GraphQLClientService.instance, fake), isTrue);
    expect(await GraphQLClientService.instance.deleteCategory(5), {'ok': true});
    expect(fake.calls, [5]);

    GraphQLClientService.debugInstance = null;
    expect(identical(GraphQLClientService.instance, real), isTrue);
  });

  test('ISS-134 host guard still applies to a fake', () {
    final fake = _FakeClient();
    expect(() => fake.initialize('http://guard-check.invalid:4567'), throwsA(anything));
    fake.initialize('http://127.0.0.1:45999');
    GraphQLClientService.debugInstance = fake; // allowed host installs fine
    expect(GraphQLClientService.instance, same(fake));
  });
}
