-- ./wezterm.lua
-- Pull in the wezterm API
local wezterm = require("wezterm")
local constants = require("constants")
-- local tmux_keys = require("tmux_func")
-- This will hold the configuration.
local config = wezterm.config_builder()

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
config.window_background_opacity = 0.95
config.macos_window_background_blur = 0

-- config.window_background_image = home .. "/.config/wezterm/assets/GL_even_8bit.png"
-- config.window_background_image = constants.bg_img
-- config.window_background_image_hsb = {
-- 	brightness = 0.1,
-- }

config.max_fps = 120

config.prefer_egl = true

-- adjust the columns and row width
config.initial_cols = 90
config.initial_rows = 30

-- and finally, return the configuration to wezterm
return config
