#!/usr/bin/env bash
# End-to-end check: run real mpv with only this script on real files, and
# print the audio/sub tracks it ends up playing.
# Usage: e2e_test.sh FILE...   (needs `mpv` CLI: brew install mpv)
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
for f in "$@"; do
  echo "== $(basename "$f")"
  mpv --no-config --script="$dir" --vo=null --ao=null --end=2 \
    --term-playing-msg='PLAYING aid=${aid} (${current-tracks/audio/lang}) | sid=${sid} (${current-tracks/sub/lang})' \
    "$f" 2>&1 | grep '^PLAYING' || { echo "no PLAYING line"; exit 1; }
done
