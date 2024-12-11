-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "catppuccin-mocha"
config.enable_tab_bar = false
config.font = wezterm.font("FiraCode Nerd Font", { weight = "Regular" })
config.font_size = 10
config.line_height = 1.1
config.cell_width = 1.0
config.window_close_confirmation = "NeverPrompt"
-- config.enable_wayland = false
-- config.use_ime = true

-- and finally, return the configuration to wezterm
return config
