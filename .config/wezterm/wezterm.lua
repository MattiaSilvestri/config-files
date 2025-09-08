-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()
--
-- -- This is where you actually apply your config choices
--
-- -- For example, changing the color scheme:
-- config.enable_tab_bar = false
-- config.font = wezterm.font("SpaceMono Nerd Font", { weight = "Regular" })
-- config.font_size = 10.8
-- config.line_height = 1.0
-- config.cell_width = 1.0
-- config.window_close_confirmation = "NeverPrompt"
-- config.enable_wayland = false
-- config.use_ime = true

config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "NONE"

-- Custom color scheme
local darkppuccin = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
darkppuccin.background = "#1e1e2e"

-- Theme
config.color_schemes = {
	["darkppuccin"] = darkppuccin,
}
config.color_scheme = "darkppuccin"

-- Fonts
config.font = wezterm.font({ family = "FiraCode Nerd Font" })

config.font_rules = {
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({
			family = "VictorMono Nerd Font",
			weight = "Bold",
			style = "Italic",
		}),
	},
	{
		italic = true,
		intensity = "Half",
		font = wezterm.font({
			family = "VictorMono Nerd Font",
			weight = "DemiBold",
			style = "Italic",
		}),
	},
	{
		italic = true,
		intensity = "Normal",
		font = wezterm.font({
			family = "VictorMono Nerd Font",
			style = "Italic",
		}),
	},
}

config.font_size = 10.8
config.line_height = 1.2
config.cell_width = 1.0

-- and finally, return the configuration to wezterm
return config

-- return {
-- 	color_schemes = {
-- 		["OLEDppuccin"] = darkppuccin,
-- 	},
-- 	color_scheme = "OLEDppuccin",
-- 	enable_tab_bar = false,
-- 	font = wezterm.font("FiraCode Nerd Font", { weight = "Regular" }),
-- 	font_size = 10.8,
-- 	line_height = 1.0,
-- 	cell_width = 1.0,
-- 	window_close_confirmation = "NeverPrompt",
-- }
