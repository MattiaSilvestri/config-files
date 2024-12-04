-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
-- local config = wezterm.config_builder()
--
-- -- This is where you actually apply your config choices
--
-- -- For example, changing the color scheme:
-- config.color_scheme = "Catppuccin Mocha"
-- config.enable_tab_bar = false
-- config.font = wezterm.font("SpaceMono Nerd Font", { weight = "Regular" })
-- config.font_size = 10.8
-- config.line_height = 1.0
-- config.cell_width = 1.0
-- config.window_close_confirmation = "NeverPrompt"
-- config.enable_wayland = false
-- config.use_ime = true

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#181825"

return {
	color_schemes = {
		["OLEDppuccin"] = custom,
	},
	color_scheme = "OLEDppuccin",
	enable_tab_bar = false,
	font = wezterm.font("SpaceMono Nerd Font", { weight = "Regular" }),
	font_size = 10.8,
	line_height = 1.0,
	cell_width = 1.0,
	window_close_confirmation = "NeverPrompt",
}

-- and finally, return the configuration to wezterm
-- return config
