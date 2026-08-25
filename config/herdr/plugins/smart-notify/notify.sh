#!/usr/bin/env bash
# Herdr hook: pane.agent_status_changed.
# Click jumps to the pane; herdr's built-in toast only activates the terminal
# app, not the agent.
set -euo pipefail

herdr="${HERDR_BIN_PATH:-$(command -v herdr)}"
jq_bin="$(command -v jq)"
state_dir="${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}"
plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

status=$("$jq_bin" -r '.data.agent_status // empty' <<<"$HERDR_PLUGIN_EVENT_JSON")
pane_id=$("$jq_bin" -r '.data.pane_id // empty' <<<"$HERDR_PLUGIN_EVENT_JSON")

# pane_id lands in a shell command line (-execute) and an AppleScript string.
# Herdr mints ids like "w8:pR"; reject anything else.
[[ "$pane_id" =~ ^[A-Za-z0-9:_-]+$ ]] || exit 0

case "$status" in
  blocked) title="Agent needs input" ;;
  done)    title="Agent finished" ;;
  *)       exit 0 ;;
esac

# Resolve by name to survive a WezTerm reinstall. osascript is ~200ms: cache it.
cache="$state_dir/wezterm-bundle-id"
if [[ -s "$cache" ]]; then
  wezterm_bundle_id=$(<"$cache")
else
  wezterm_bundle_id=$(osascript -e 'id of app "WezTerm"' 2>/dev/null || echo com.github.wez.wezterm)
  echo "$wezterm_bundle_id" >"$cache"
fi

# -execute runs under a shell with launchd's minimal PATH: absolute, %q-quoted.
execute=$(printf '%q %q %q %q' \
  "$plugin_dir/focus-pane.sh" "$herdr" "$jq_bin" "$pane_id")

# No -sound: herdr's ui.sound already plays the cue.
# -execute only pokes the herdr socket; -activate raises the window.
notify() {
  terminal-notifier \
    -title "$title" \
    -subtitle "$pane_id" \
    -message "Click to jump to this agent" \
    -group "herdr-$pane_id" \
    -activate "$wezterm_bundle_id" \
    -execute "$execute" \
    >/dev/null
}

lsregister=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister

# macOS keys notification auth on bundle id + code identity. Two ways it breaks,
# both silent (no prompt, no error):
#   1. Bad ad-hoc signature in the bottle -> UNUserNotificationCenter denies.
#   2. `brew upgrade` moves the app to a new Cellar path; the old one stays
#      registered and usernoted honors that ghost, refusing the live binary.
# Runs only after a failed send.
repair() {
  local tn_bin tn_app path
  tn_bin="$(command -v terminal-notifier)" || return 0
  # brew's bin/terminal-notifier is a wrapper exec'ing into the .app.
  tn_app="$(grep -m1 -oE '/[^"[:space:]]*terminal-notifier\.app' "$tn_bin" 2>/dev/null || true)"
  [[ -n "$tn_app" && -d "$tn_app" ]] || return 0

  if ! codesign --verify --deep "$tn_app" >/dev/null 2>&1; then
    codesign --force --deep --sign - "$tn_app" >/dev/null 2>&1 || true
  fi

  # Drop ghosts, re-register the live bundle.
  while read -r path; do
    [[ -d "$path" ]] || "$lsregister" -u "$path" >/dev/null 2>&1 || true
  done < <("$lsregister" -dump 2>/dev/null |
    sed -n 's|^path: *\(/.*terminal-notifier\.app\).*|\1|p')
  "$lsregister" -f "$tn_app" >/dev/null 2>&1 || true

  # usernoted caches the auth record; launchd respawns it.
  killall usernoted >/dev/null 2>&1 || true
  sleep 1
}

if ! err=$(notify 2>&1); then
  repair
  if ! err=$(notify 2>&1); then
    # No click-to-jump: osascript notifications carry no action.
    osascript -e "display notification \"$pane_id\" with title \"$title\"" \
      >/dev/null 2>&1 || true
    # Truncate: keep only the latest failure.
    printf '%s %s\n' "$(date -Iseconds)" "$err" >"$state_dir/last-error"
  fi
fi
