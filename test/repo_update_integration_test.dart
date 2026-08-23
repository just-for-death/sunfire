import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('REPO MANAGER UNIT TESTS', () {
    test('1. Compare versions semver logic', () {
      expect(RepoManager.compareVersions('1.1.1', '1.1.0'), greaterThan(0));
      expect(RepoManager.compareVersions('1.0.3', '1.0.2'), greaterThan(0));
      expect(RepoManager.compareVersions('1.0.1', '1.0.0'), greaterThan(0));
      expect(RepoManager.compareVersions('1.0.0', '1.0.0'), equals(0));
      expect(RepoManager.compareVersions('1.0.0', '1.0.1'), lessThan(0));
    });

    test('2. Sanitize repository URLs correctly', () {
      expect(
        RepoManager.normalizeRepoUrl('https://github.com/example/manga-repo'),
        equals('https://raw.githubusercontent.com/example/manga-repo/main/index.json'),
      );
      expect(
        RepoManager.normalizeRepoUrl('https://example.com/custom/index.json'),
        equals('https://example.com/custom/index.json'),
      );
    });
  });
}
