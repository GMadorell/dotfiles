-- Move a pane into a different split slot, preserving its process/content.
-- wezterm has no scriptable "swap pane A with pane B by id", so this drives
-- the built-in interactive PaneSelect swap picker instead:
--   1. move_into(direction): split the focused (destination) pane in `direction`,
--      remember the new empty pane's id, then open the swap picker on it.
--   2. Pick the pane to move in the picker overlay (content lands, focused, in
--      the new slot).
-- Cleanup of the leftover placeholder rides on `update-status` (already used
-- for this config's status bar): once the active pane differs from the
-- placeholder AND has a real foreground process (the overlay pane itself has
-- none), the picker must have completed or been cancelled, so it's safe to
-- kill the placeholder. Call check_pending_cleanup(window, pane) from your
-- update-status handler. The "done" reading must repeat on a second tick
-- before it's trusted, since update-status fires once synchronously off the
-- split's own repaint, reporting stale pre-split state.

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local pending_move_pane_id = nil
local mismatch_streak = 0

function M.move_into(direction)
  return wezterm.action_callback(function(window, pane)
    local new_pane = pane:split({ direction = direction, size = 0.5 })
    pending_move_pane_id = new_pane:pane_id()
    mismatch_streak = 0
    window:perform_action(act.PaneSelect({ mode = "SwapWithActive" }), new_pane)
  end)
end

-- GUI apps get a minimal PATH from launchd (no /opt/homebrew/bin), so
-- run_child_process can't find a bare "wezterm" — use the running binary's
-- own directory instead.
local wezterm_cli = wezterm.executable_dir .. "/wezterm"

local function kill_pane(id)
  local ok, _, stderr = wezterm.run_child_process({ wezterm_cli, "cli", "kill-pane", "--pane-id", tostring(id) })
  if not ok then
    wezterm.log_error("pane_move: failed to kill placeholder pane " .. id .. ": " .. stderr)
  end
end

function M.check_pending_cleanup(window, pane)
  if not pending_move_pane_id then
    return
  end
  local active_id = pane:pane_id()
  local fg = pane:get_foreground_process_name()
  if fg == nil or active_id == pending_move_pane_id then
    mismatch_streak = 0
    return
  end
  mismatch_streak = mismatch_streak + 1
  if mismatch_streak >= 2 then
    local id_to_kill = pending_move_pane_id
    pending_move_pane_id = nil
    mismatch_streak = 0
    kill_pane(id_to_kill)
  end
end

return M
