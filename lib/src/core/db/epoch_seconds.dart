/// Normalises a server-reported epoch timestamp to the SECONDS unit that every
/// timestamp in local storage uses, or null when [raw] carries no usable value.
///
/// The app stores `lastReadAt`, `fetchedAt` and `inLibraryAt` in epoch seconds
/// (all local writers use `millisecondsSinceEpoch ~/ 1000`). A JS/Node GraphQL
/// server, however, is just as likely to send `Date.now()` — epoch MILLISECONDS.
/// Taking such a value verbatim does not error; it silently produces a timestamp
/// ~1000x in the future, which then sorts permanently to one end of any
/// date-ordered list and never interleaves with locally-written values.
/// `inLibraryAt` was stored exactly that way from the server payload, so any
/// library synced from a millis-reporting server sorted its synced entries away
/// from the ones the user added here.
///
/// The threshold is the standard "1e11 seconds is year 5138" line: any plausible
/// seconds value is below it, any plausible millis value is far above it. Values
/// at or below zero, and anything unparseable, are rejected outright so a
/// null/empty/"null" payload field can never be stored as a real timestamp.
///
/// WHY THIS IS ITS OWN LEAF MODULE.
///
/// It used to live in `sync_engine.dart`, which is where a dozen call sites
/// reached for it. That made it unreachable from `isar_service.dart` — the
/// service imports the engine, so importing back would be a cycle — and the
/// result was a second, hand-rolled copy of the same threshold in the DB layer,
/// which is exactly the drift this function exists to prevent: nine other sites
/// had already carried a local `1e12` variant and disagreed with the `1e11` here
/// for any value in the gap, i.e. any millis timestamp from 1973 to 2001.
///
/// Keeping it here means there is exactly one answer to "is this seconds or
/// millis", reachable from every layer without a cycle. `sync_engine.dart`
/// re-exports it so existing imports keep working.
int? normalizeEpochToSeconds(Object? raw) {
  if (raw == null) return null;
  final parsed = raw is num ? raw.toInt() : int.tryParse(raw.toString().trim());
  if (parsed == null || parsed <= 0) return null;
  return parsed > 100000000000 ? parsed ~/ 1000 : parsed;
}
