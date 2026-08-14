import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/browse_center/domain/source/source_model.dart';
import '../features/history/domain/history_item.dart';

final tabletBrowseSourceSelectionProvider = StateProvider<
    ({
      String sourceId,
      SourceType sourceType,
      String? query,
    })?>((ref) => null);

final tabletHistorySelectionProvider =
    StateProvider<HistoryItemDto?>((ref) => null);

final tabletLibraryCategorySelectionProvider = StateProvider<int?>(
  (ref) => null,
);
