#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST_DIR="$ROOT_DIR/workspace/license"
mkdir -p "$DEST_DIR"

SRC1="${1:-$HOME/dev/bw-lic.json}"
SRC2="${2:-$HOME/dev/bw-inst.md}"

if [ -f "$SRC1" ]; then
  cp "$SRC1" "$DEST_DIR/bw-lic.json"
  echo "Copied $SRC1 -> $DEST_DIR/bw-lic.json"
else
  echo "WARN: license file $SRC1 not found. Please place your bw-lic.json at $DEST_DIR/bw-lic.json"
fi

if [ -f "$SRC2" ]; then
  cp "$SRC2" "$DEST_DIR/bw-inst.md"
  echo "Copied $SRC2 -> $DEST_DIR/bw-inst.md"
else
  echo "(optional) install id/key file $SRC2 not found. If required, copy it to $DEST_DIR/bw-inst.md"
fi
