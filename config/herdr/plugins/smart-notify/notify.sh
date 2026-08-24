#!/usr/bin/env bash
# Herdr event hook: fires on every pane.agent_status_changed.
# Posts a terminal-notifier notification whose click jumps straight to the
# pane, instead of relying on herdr's built-in "system" toast (which just
# activates the terminal app, not the specific agent).
set -euo pipefail

herdr="${HERDR_BIN_PATH:-$(command -v herdr)}"
jq_bin="$(command -v jq)"

status=$("$jq_bin" -r '.data.agent_status // empty' <<<"$HERDR_PLUGIN_EVENT_JSON")
pane_id=$("$jq_bin" -r '.data.pane_id // empty' <<<"$HERDR_PLUGIN_EVENT_JSON")

[[ -n "$pane_id" ]] || exit 0

case "$status" in
  blocked) title="Agent needs input" ;;
  done)    title="Agent finished" ;;
  *)       exit 0 ;;
esac

# No -sound: herdr's own ui.sound (done_path/request_path) already plays the
# audio cue; adding one here would double it.
# -execute only talks to the herdr socket (updates its internal focus); it
# does not raise the terminal app's window. -activate does that part.
# Bundle id resolved by name (not hardcoded) so this survives a WezTerm
# reinstall or a different install path; falls back to the known id if the
# app can't be looked up (e.g. not installed). osascript takes ~200ms, so
# the result is cached instead of re-resolved on every notification.
cache="${HERDR_PLUGIN_STATE_DIR:-/tmp}/wezterm-bundle-id"
if [[ -s "$cache" ]]; then
  wezterm_bundle_id=$(<"$cache")
else
  wezterm_bundle_id=$(osascript -e 'id of app "WezTerm"' 2>/dev/null || echo com.github.wez.wezterm)
  echo "$wezterm_bundle_id" >"$cache"
fi

# Homebrew's terminal-notifier bottle ships with a broken ad-hoc signature
# (CodeDirectory claims sealed resources but none are present), which makes
# macOS silently deny UNUserNotificationCenter authorization (no prompt, no
# error visible here) -- every `brew upgrade terminal-notifier` reintroduces
# this. Verify-then-repair on each run rather than requiring a manual fix.
herdr_tn_bin="$(command -v terminal-notifier)"
tn_app="$(grep -m1 -oE '/[^"[:space:]]*terminal-notifier\.app' "$herdr_tn_bin" 2>/dev/null || true)"
if [[ -n "$tn_app" && -d "$tn_app" ]] && ! codesign --verify --deep "$tn_app" >/dev/null 2>&1; then
  codesign --force --deep --sign - "$tn_app" >/dev/null 2>&1 || true
fi

plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
terminal-notifier \
  -title "$title" \
  -subtitle "$pane_id" \
  -message "Click to jump to this agent" \
  -group "herdr-$pane_id" \
  -activate "$wezterm_bundle_id" \
  -execute "$plugin_dir/focus-pane.sh $herdr $jq_bin $pane_id" \
  >/dev/null
