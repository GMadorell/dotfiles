local wezterm = require("wezterm")
local pane_move = require("pane_move")

local config = wezterm.config_builder()
local act = wezterm.action

-- Visual settings
config.color_scheme = "Darcula (base16)"
config.font = wezterm.font_with_fallback({
  "FiraCode Nerd Font",
  "Fira Code Nerd Font",
})
config.font_size = 16.0
config.line_height = 1.1
config.inactive_pane_hsb = {
  brightness = 0.9,
}
config.colors = {
  -- This controls the color of the vertical/horizontal pane split lines
  split = "#bd93f9",
}

-- Minimal UI
config.window_decorations = "RESIZE" -- Removes title bar but keeps thin border for resizing on macOS
-- Pad window to avoid the content to be too close to the border,
-- so it's easier to see and select.
config.window_padding = {
  left = 3,
  right = 3,
  top = 3,
  bottom = 3,
}
-- default to full screen, as the plan is to use herdr for multiplexing
config.enable_tab_bar = false
config.use_fancy_tab_bar = false -- Gives us a clean, flat bar instead of retro 3D tabs
config.tab_bar_at_bottom = true
config.tab_max_width = 26
-- Default is 1s, far too laggy for the leader indicator to feel responsive.
config.status_update_interval = 100

local function get_tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  -- Fallback to the title of the active pane (usually the running process or binary)
  return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config_opts, hover, max_width)
  local index = tab.tab_index + 1

  local title = get_tab_title(tab)
  if tab.active_pane.is_zoomed then
    title = title .. " \u{f004c}"
  end

  local background = "#151515"
  local foreground = "#6272a4"
  local title_foreground = "#6272a4"

  if tab.is_active then
    background = "#282a36"
    foreground = "#50fa7b"
    title_foreground = "#f8f8f2"
  elseif hover then
    background = "#21222c"
    foreground = "#50fa7b"
    title_foreground = "#f8f8f2"
  end

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. index .. " " },
    { Foreground = { Color = title_foreground } },
    { Text = title .. " " },
  }
end)

wezterm.on("update-status", function(window, pane)
  -- pane_move rides on update-status to clean up its placeholder pane.
  pane_move.check_pending_cleanup(window, pane)

  local workspace = window:active_workspace()
  workspace = workspace == "default" and " \u{f085c} main " or " \u{f085c} " .. workspace .. " "
  local date_time = wezterm.strftime(" \u{f1452} %b %d %H:%M ")

  local our_tab = pane:tab()
  local is_zoomed = false
  if our_tab ~= nil then
    for _, pane_attributes in pairs(our_tab:panes_with_info()) do
      is_zoomed = pane_attributes["is_zoomed"] or is_zoomed
    end
  end

  local status_modules = {}

  -- Mirrors herdr's PREFIX badge: shows while the leader is armed.
  if window:leader_is_active() then
    table.insert(status_modules, { Background = { Color = "#bd93f9" } })
    table.insert(status_modules, { Foreground = { Color = "#282a36" } })
    table.insert(status_modules, { Attribute = { Intensity = "Bold" } })
    table.insert(status_modules, { Text = " LEADER " })
    table.insert(status_modules, { Attribute = { Intensity = "Normal" } })
  end

  -- Only inject the styled block if the pane is actively zoomed
  if is_zoomed then
    table.insert(status_modules, { Background = { Color = "#ff5555" } })
    table.insert(status_modules, { Foreground = { Color = "#f8f8f2" } })
    table.insert(status_modules, { Text = " \u{f004c} ZOOMED " })
  end

  -- Workspace section
  table.insert(status_modules, { Background = { Color = "#151515" } })
  table.insert(status_modules, { Foreground = { Color = "#bd93f9" } })
  table.insert(status_modules, { Text = workspace })

  -- Time section
  table.insert(status_modules, { Background = { Color = "#21222c" } })
  table.insert(status_modules, { Foreground = { Color = "#f8f8f2" } })
  table.insert(status_modules, { Text = date_time })

  window:set_right_status(wezterm.format(status_modules))
end)

-- Prompt for a line of input, then run `fn(window, pane, line)` unless cancelled.
local function prompt(description, fn)
  return act.PromptInputLine({
    description = description,
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        fn(window, pane, line)
      end
    end),
  })
end

local function toggle_tab_bar(window, _pane)
  local overrides = window:get_config_overrides() or {}
  overrides.enable_tab_bar = not overrides.enable_tab_bar
  -- Overrides outlive a config reload, so an earlier build of this config that
  -- hid the tabs themselves would keep them hidden forever. Drop those keys.
  overrides.show_tabs_in_tab_bar = nil
  overrides.show_new_tab_button_in_tab_bar = nil
  window:set_config_overrides(overrides)
end

-- wezterm has no "close window" / "close workspace" action, so close every
-- pane that makes them up.
local function close_window(window, _pane)
  for _, tab in ipairs(window:mux_window():tabs()) do
    for _, pane in ipairs(tab:panes()) do
      pane:activate()
      window:perform_action(act.CloseCurrentPane({ confirm = false }), pane)
    end
  end
end

local function close_workspace(window, _pane)
  local workspace = window:active_workspace()
  for _, mux_window in ipairs(wezterm.mux.all_windows()) do
    if mux_window:get_workspace() == workspace then
      for _, tab in ipairs(mux_window:tabs()) do
        for _, pane in ipairs(tab:panes()) do
          window:perform_action(act.CloseCurrentPane({ confirm = false }), pane)
        end
      end
    end
  end
end

config.leader = { key = "Space", mods = "OPT", timeout_milliseconds = 2000 }

config.keys = {
  -- Direction: focus pane
  { mods = "LEADER",       key = "h", action = act.ActivatePaneDirection("Left") },
  { mods = "LEADER",       key = "j", action = act.ActivatePaneDirection("Down") },
  { mods = "LEADER",       key = "k", action = act.ActivatePaneDirection("Up") },
  { mods = "LEADER",       key = "l", action = act.ActivatePaneDirection("Right") },

  -- Direction: move pane into a new slot there. Focus the destination, press
  -- the direction, then pick the pane to move in the swap overlay.
  { mods = "LEADER|SHIFT", key = "H", action = pane_move.move_into("Left") },
  { mods = "LEADER|SHIFT", key = "J", action = pane_move.move_into("Bottom") },
  { mods = "LEADER|SHIFT", key = "K", action = pane_move.move_into("Top") },
  { mods = "LEADER|SHIFT", key = "L", action = pane_move.move_into("Right") },

  -- Verb: n = new
  {
    mods = "LEADER",
    key = "n",
    action = act.SplitPane({ direction = "Right", command = { domain = "CurrentPaneDomain" } }),
  },
  {
    mods = "LEADER|SHIFT",
    key = "N",
    action = act.SplitPane({ direction = "Down", command = { domain = "CurrentPaneDomain" } }),
  },
  { mods = "LEADER|CTRL",     key = "n", action = act.SpawnTab("CurrentPaneDomain") },
  {
    mods = "LEADER|CTRL|ALT",
    key = "n",
    action = prompt("Enter name for new workspace", function(window, pane, line)
      window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
    end),
  },
  { mods = "LEADER|CTRL|SHIFT", key = "N", action = act.SpawnWindow },

  -- Verb: x = close
  { mods = "LEADER",            key = "x", action = act.CloseCurrentPane({ confirm = false }) },
  { mods = "LEADER|CTRL",       key = "x", action = act.CloseCurrentTab({ confirm = true }) },
  { mods = "LEADER|CTRL|ALT",   key = "x", action = wezterm.action_callback(close_workspace) },
  { mods = "LEADER|CTRL|SHIFT", key = "X", action = wezterm.action_callback(close_window) },

  -- Verb: r = rename
  {
    mods = "LEADER|CTRL",
    key = "r",
    action = prompt("Enter new name for tab", function(window, _, line)
      window:active_tab():set_title(line)
    end),
  },
  {
    mods = "LEADER|CTRL|ALT",
    key = "r",
    action = prompt("Enter new name for workspace", function(window, _, line)
      wezterm.mux.rename_workspace(window:active_workspace(), line)
    end),
  },

  -- Verb: f = find
  { mods = "LEADER",          key = "f",   action = act.ShowLauncherArgs({ flags = "FUZZY|TABS|WORKSPACES" }) },
  { mods = "LEADER|CTRL",     key = "f",   action = act.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },
  { mods = "LEADER|CTRL|ALT", key = "f",   action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

  -- Verb: z = zoom
  { mods = "LEADER",            key = "z", action = act.TogglePaneZoomState },
  { mods = "LEADER|CTRL|SHIFT", key = "Z", action = act.ToggleFullScreen },

  -- Tab navigation
  { mods = "LEADER", key = ",", action = act.ActivateTabRelative(-1) },
  { mods = "LEADER", key = ".", action = act.ActivateTabRelative(1) },

  -- Pane cycling
  { mods = "LEADER",          key = "Tab", action = act.ActivatePaneDirection("Next") },
  { mods = "LEADER|SHIFT",    key = "Tab", action = act.ActivatePaneDirection("Prev") },

  -- Singletons
  { mods = "LEADER",          key = "b",   action = wezterm.action_callback(toggle_tab_bar) },
  { mods = "LEADER",          key = "g",   action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 2000 }) },
  { mods = "LEADER",          key = "v",   action = act.ActivateCopyMode },
  { mods = "LEADER|SHIFT",    key = "S",   action = act.ReloadConfiguration },
  { mods = "LEADER|SHIFT",    key = "?",   action = act.ActivateCommandPalette },
  { mods = "LEADER|CTRL",     key = "?",   action = act.ShowLauncherArgs({ flags = "FUZZY|COMMANDS" }) },

  -- Font size
  { mods = "LEADER",          key = "=",   action = act.IncreaseFontSize },
  { mods = "LEADER|SHIFT",    key = "+",   action = act.IncreaseFontSize },
  { mods = "LEADER",          key = "-",   action = act.DecreaseFontSize },
  { mods = "LEADER",          key = "0",   action = act.ResetFontSize },
}

-- Resize mode: prefix+g enters it, hjkl grows/shrinks the focused pane,
-- Escape/Enter exits. Mirrors herdr's resize_mode.
config.key_tables = {
  resize_pane = {
    { key = "h",      action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "j",      action = act.AdjustPaneSize({ "Down", 5 }) },
    { key = "k",      action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "l",      action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  },
}

-- Switch tabs by index, mirroring herdr's `prefix + 1..9`.
for i = 1, 9 do
  table.insert(config.keys, { mods = "LEADER", key = tostring(i), action = act.ActivateTab(i - 1) })
end

-- Start maximized
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return config
