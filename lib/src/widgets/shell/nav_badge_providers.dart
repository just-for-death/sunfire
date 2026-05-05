import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/manga_book/data/updates/updates_repository.dart';

final navUpdatesBadgeCountProvider = Provider<int>((ref) {
  final status = ref.watch(updatesSocketProvider).valueOrNull;
  if (status == null) return 0;
  return status.completeJobs.mangas.totalCount.toInt();
});
