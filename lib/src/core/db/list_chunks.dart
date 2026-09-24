/// Splits [items] into consecutive chunks of at most [size] elements, keeping
/// order. Used to bound the size of a single Isar `anyOf` filter, which is
/// compiled into one query and gets slow with thousands of OR branches.
List<List<T>> chunkList<T>(List<T> items, int size) {
  if (size <= 0) throw ArgumentError.value(size, 'size', 'must be positive');
  final chunks = <List<T>>[];
  for (var i = 0; i < items.length; i += size) {
    chunks.add(items.sublist(i, i + size > items.length ? items.length : i + size));
  }
  return chunks;
}
