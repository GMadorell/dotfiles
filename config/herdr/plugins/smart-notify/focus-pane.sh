#!/usr/bin/env bash
# Invoked by terminal-notifier's -execute when the notification is clicked:
# focus-pane.sh <herdr-bin> <jq-bin> <pane-id>
# Jumps to the target pane. If the tab was zoomed on a *different* pane,
# drop the zoom (landing zoomed on a pane you never zoomed into is jarring).
# If the tab was already zoomed on this exact pane, leave it zoomed.
set -euo pipefail

herdr="$1"
jq="$2"
pane_id="$3"

before=$("$herdr" pane layout --pane "$pane_id")
was_zoomed=$("$jq" -r '.result.layout.zoomed' <<<"$before")
prev_focused=$("$jq" -r '.result.layout.focused_pane_id' <<<"$before")

"$herdr" agent focus "$pane_id" >/dev/null

if [[ "$was_zoomed" == "true" && "$prev_focused" != "$pane_id" ]]; then
  "$herdr" pane zoom --pane "$pane_id" --off >/dev/null
fi
