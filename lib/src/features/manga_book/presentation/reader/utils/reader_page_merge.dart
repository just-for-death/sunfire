// Copyright (c) 2026 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:math';

/// Combines locally downloaded pages with the server's page list.
///
/// [localPages] is aligned to the download manifest — index `i` is always
/// manifest page `i`, and a `null` means that file is missing from disk. Those
/// holes are filled from [remotePages] at the same index. Collapsing the holes
/// out instead would shift every later page onto the wrong index.
///
/// Returns an empty list if a page is available from neither side, since a
/// chapter cannot have a gap in the middle of it.
List<String> mergeLocalAndRemotePages(
  List<String?>? localPages,
  List<String> remotePages,
) {
  if (localPages == null) return List<String>.from(remotePages);

  final merged = <String>[];
  final length = max(remotePages.length, localPages.length);
  for (var i = 0; i < length; i++) {
    final local = i < localPages.length ? localPages[i] : null;
    final remote = i < remotePages.length ? remotePages[i] : null;
    final page = local ?? remote;
    if (page == null) break;
    merged.add(page);
  }
  return merged;
}

/// Pages readable with no server available: only the ones actually on disk.
List<String> offlineOnlyPages(List<String?>? localPages) =>
    localPages == null ? const [] : localPages.nonNulls.toList();
