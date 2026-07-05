local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Visual settings
config.color_scheme = 'Darcula (base16)'
config.font = wezterm.font_with_fallback({
  'FiraCode Nerd Font',
  'Fira Code Nerd Font',
})
config.font_size = 16.0
config.line_height = 1.1
config.inactive_pane_hsb = {
  brightness = 0.9, 
}
config.colors = {
  -- This controls the color of the vertical/horizontal pane split lines
  split = '#bd93f9', 
}

-- Minimal UI
config.window_decorations = "RESIZE" -- Removes title bar but keeps thin border for resizing on macOS
-- Pad window to avoid the content to be too close to the border,
-- so it's easier to see and select.
config.window_padding = {
  left = 3, right = 3,
  top = 3, bottom = 3,
}

-- Tabs
config.enable_tab_bar = true
config.use_fancy_tab_bar = false -- Gives us a clean, flat bar instead of retro 3D tabs
config.tab_bar_at_bottom = true
config.tab_max_width  = 26
local function get_tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  -- Fallback to the title of the active pane (usually the running process or binary)
  return tab_info.active_pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config_opts, hover, max_width)
  local index = tab.tab_index + 1
  
  local title = get_tab_title(tab)
  if tab.active_pane.is_zoomed then
    title = title .. ' 󰁌'
  end

  local background = '#151515'
  local foreground = '#6272a4'
  local title_foreground = '#6272a4'

  if tab.is_active then
    background = '#282a36'
    foreground = '#50fa7b'
    title_foreground = '#f8f8f2'
  elseif hover then
    background = '#21222c'
    foreground = '#50fa7b'
    title_foreground = '#f8f8f2'
  end

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = ' ' .. index .. ' ' },
    { Foreground = { Color = title_foreground } },
    { Text = title .. ' ' },
  }
end)

-- Workspace info on the bottom bar
wezterm.on('update-status', function(window, pane)
  local workspace = window:active_workspace()
  workspace = workspace == 'default' and ' 󰋜 main ' or ' 󰋜 ' .. workspace .. ' '
  local date_time = wezterm.strftime(' 󱑒 %b %d %H:%M ')

  local our_tab = pane:tab()
  local is_zoomed = false
  if our_tab ~= nil then
      for _, pane_attributes in pairs(our_tab:panes_with_info()) do
          is_zoomed = pane_attributes['is_zoomed'] or is_zoomed
      end
  end

  local status_modules = {}

  -- Only inject the styled block if the pane is actively zoomed
  if is_zoomed then
    table.insert(status_modules, { Background = { Color = '#ff5555' } })
    table.insert(status_modules, { Foreground = { Color = '#f8f8f2' } })
    table.insert(status_modules, { Text = ' 󰁌 ZOOMED ' })
  end

  -- Workspace section
  table.insert(status_modules, { Background = { Color = '#151515' } })
  table.insert(status_modules, { Foreground = { Color = '#bd93f9' } })
  table.insert(status_modules, { Text = workspace })

  -- Time section
  table.insert(status_modules, { Background = { Color = '#21222c' } })
  table.insert(status_modules, { Foreground = { Color = '#f8f8f2' } })
  table.insert(status_modules, { Text = date_time })

  window:set_right_status(wezterm.format(status_modules))
end)

-- Keybindings
config.keys = {
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|OPT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
}

-- Start maximized
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return config
