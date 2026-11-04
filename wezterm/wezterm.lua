-- ./wezterm.lua
-- Pull in the wezterm API
local wezterm = require("wezterm")
local constants = require("constants")
require("gui_startup")
-- local tmux_keys = require("tmux_func")
-- This will hold the configuration.
local config = wezterm.config_builder()
-- config.term = "xterm-kitty"

-- Load tmux-style leader and keys
-- config.leader = tmux_keys.leader
-- config.keys = tmux_keys.keys

-- This is where you actually apply your config choices

local home = wezterm.home_dir

config.color_scheme = "Tokyo Night Moon"
-- coolnight colorscheme

-- config.colors = {
-- 	foreground = "#CBE0F0",
-- 	background = "#011423",
-- 	cursor_bg = "#47FF9C",
-- 	cursor_border = "#47FF9C",
-- 	cursor_fg = "#011423",
-- 	selection_bg = "#033259",
-- 	selection_fg = "#CBE0F0",
-- 	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
-- 	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
-- }

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16
config.line_height = 1

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_frame = {
	border_left_width = 0,
	border_right_width = 0,
	border_bottom_height = 0,
	border_top_height = 0,
}
config.window_background_opacity = 0.95
config.macos_window_background_blur = 1

-- config.window_background_image = home .. "/.config/wezterm/assets/GL_even_8bit.png"
-- config.window_background_image = constants.bg_img
-- config.window_background_image_hsb = {
-- 	brightness = 0.1,
-- }

config.max_fps = 120

config.prefer_egl = true

config.keys = {
  {
    key = "r",
    mods = "CMD|CTRL|ALT",
    action = wezterm.action_callback(function(window)
      local ok, message = pcall(function()
        local dimensions = window:get_dimensions()
        local grid = window:active_tab():get_size()
        local cell_width = grid.pixel_width / grid.cols
        local cell_height = grid.pixel_height / grid.rows
        local effective_config = window:effective_config()
        -- Keep padding and unused edge pixels, replacing only the tab's grid.
        local target_width = dimensions.pixel_width - grid.pixel_width
          + effective_config.initial_cols * cell_width
        local target_height = dimensions.pixel_height - grid.pixel_height
          + effective_config.initial_rows * cell_height
        -- Capture failures instead of silently losing the helper's output.
        -- This API awaits asynchronously, allowing the GUI to service AX requests.
        local success, stdout, stderr = wezterm.run_child_process({
          wezterm.home_dir .. "/.config/shell_tool/bin/window-tool",
          "wezterm-grid",
          tostring(dimensions.pixel_width),
          tostring(dimensions.pixel_height),
          tostring(target_width),
          tostring(target_height),
        })
        if not success then
          error(tostring(stdout) .. tostring(stderr))
        end
      end)
      if not ok then
        wezterm.log_error("Window reset failed: " .. tostring(message))
        window:toast_notification("Window reset failed", tostring(message), nil, 10000)
      end
    end),
  },
}

-- adjust the columns and row width
config.initial_cols = 120
config.initial_rows = 42

-- Modify ApplePressAndHoldEnabled
-- config.use_ime = false

-- and finally, return the configuration to wezterm
return config
