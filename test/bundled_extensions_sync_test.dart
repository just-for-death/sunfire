import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled assets match mangayomi-extensions sources', () {
    final bundled = Directory('assets/extensions');
    final upstream = Directory('../mangayomi-extensions/javascript/manga/src/en');

    expect(bundled.existsSync(), isTrue, reason: 'Sunfire must ship assets/extensions');
    if (!upstream.existsSync()) {
      markTestSkipped('mangayomi-extensions sibling repo not present');
      return;
    }

    final upstreamFiles = upstream
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.js'))
        .toList()
      ..sort((a, b) => a.uri.pathSegments.last.compareTo(b.uri.pathSegments.last));

    expect(upstreamFiles, isNotEmpty);

    for (final src in upstreamFiles) {
      final name = src.uri.pathSegments.last;
      final dest = File('${bundled.path}/$name');
      expect(dest.existsSync(), isTrue, reason: 'Missing bundled copy of $name. Run scripts/sync_bundled_extensions.sh');
      expect(
        dest.readAsStringSync(),
        equals(src.readAsStringSync()),
        reason: '$name drifted from mangayomi-extensions. Run scripts/sync_bundled_extensions.sh',
      );
    }
  });

  test('official index URL is already a canonical index.json', () {
    expect(
      RepoManager.normalizeRepoUrl(RepoManager.officialIndexUrl),
      equals(RepoManager.officialIndexUrl),
    );
    expect(
      RepoManager.normalizeRepoUrl('https://github.com/just-for-death/mangayomi-extensions'),
      equals(RepoManager.officialIndexUrl),
    );
  });
}
