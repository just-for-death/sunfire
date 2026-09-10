#!/usr/bin/env bash
# Copy JS sources from the sibling mangayomi-extensions repo into Sunfire assets.
# Run from anywhere; paths are resolved relative to this script.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUNFIRE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_ROOT="$(cd "$SUNFIRE_ROOT/.." && pwd)"
SRC="$WORKSPACE_ROOT/mangayomi-extensions/javascript/manga/src/en"
DST="$SUNFIRE_ROOT/assets/extensions"

if [[ ! -d "$SRC" ]]; then
  echo "Missing extension sources at $SRC" >&2
  echo "Clone just-for-death/mangayomi-extensions next to sunfire." >&2
  exit 1
fi

mkdir -p "$DST"
copied=0
for src_file in "$SRC"/*.js; do
  name="$(basename "$src_file")"
  cp "$src_file" "$DST/$name"
  copied=$((copied + 1))
  echo "synced $name"
done

echo "Copied $copied extension(s) to $DST"
