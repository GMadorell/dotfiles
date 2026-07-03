local wezterm = require 'wezterm'
local config = wezterm.config_builder()


-- Visual settings
config.color_scheme = 'Solarized Dark (Gogh)'
config.font = wezterm.font_with_fallback({
  'FiraCode Nerd Font',
  'Fira Code Nerd Font',
})
config.font_size = 16.0
config.line_height = 1.1
config.cell_width = 0.95

-- Tabless & Minimal UI
config.enable_tab_bar = false
config.window_decorations = "RESIZE" -- Removes title bar but keeps thin border for resizing on macOS

-- Start maximized

-- Automatically maximize the window on the current space when created
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return config
