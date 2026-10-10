local wezterm = require("wezterm")

wezterm.on("gui-startup", function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()
  local screen = wezterm.gui.screens().main
  local dimensions = gui_window:get_dimensions()
  -- NSScreen.visibleFrame excludes the 30-point macOS menu bar.
  local menu_bar_center_offset = 15 * dimensions.dpi / 72

  gui_window:set_position(
    math.floor(screen.x + (screen.width - dimensions.pixel_width) / 2),
    math.floor(screen.y + (screen.height - dimensions.pixel_height) / 2 + menu_bar_center_offset)
  )
end)
