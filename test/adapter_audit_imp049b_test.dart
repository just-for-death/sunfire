// IMP-049b: every optional adapter/service has a live entry point.
// Construction only; no network.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/kavita_adapter.dart';
import 'package:sunfire/src/core/sync/mihon_adapter.dart';
import 'package:sunfire/src/core/sync/multi_server_manager.dart';
import 'package:sunfire/src/core/sync/server_type.dart';

ServerConfig _cfg(ServerType t) => ServerConfig(id: 't', name: 't', type: t, baseUrl: 'http://127.0.0.1:9');

void main() {
  test('MultiServerManager builds the Kavita/Mihon adapters the settings screen offers', () {
    final m = MultiServerManager.instance;
    expect(m.debugCreateAdapter(_cfg(ServerType.kavita)), isA<KavitaAdapter>());
    expect(m.debugCreateAdapter(_cfg(ServerType.mihon)), isA<MihonAdapter>());
    expect(m.debugCreateAdapter(_cfg(ServerType.suwayomi)), isNotNull);
  });

  test('types without an adapter return null (not offered in the UI)', () {
    final m = MultiServerManager.instance;
    expect(m.debugCreateAdapter(_cfg(ServerType.opds)), isNull);
    expect(m.debugCreateAdapter(_cfg(ServerType.custom)), isNull);
  });
}
