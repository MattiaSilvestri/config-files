--- @type LazySpec

return {
	"catppuccin/nvim",
	name = "catppuccin",
	enabled = true,
	priority = 1000,

	opts = {
		term_colors = true,
		flavour = "mocha",
		blink_cmp = {
			style = "bordered",
		},
		snacks = {
			enabled = true,
			indent_scope_color = "", -- catppuccin color (eg. `lavender`) Default: text
		},
		-- integrations = {
		-- 	blink_cmp = true,
		-- },
		color_overrides = {
			mocha = {
				-- 	base = "#181825",
				-- 	mantle = "#11111b",
				-- rosewater = "#f5e0dc",
				-- flamingo = "#f2cdcd",
				-- pink = "#f5c2e7",
				-- mauve = "#d0a9e5",
				-- red = "#f38ba8",
				-- maroon = "#ffa5c3",
				-- peach = "#F8BD96",
				-- yellow = "#ffe9b6",
				-- green = "#ABE9B3",
				-- teal = "#B5E8E0",
				-- sky = "#89dceb",
				-- sapphire = "#74c7ec",
				-- blue = "#89b4fa",
				-- lavender = "#b4befe",
				-- text = "#cdd6f4",
				-- subtext1 = "#bac2de",
				-- subtext0 = "#a6adc8",
				-- overlay2 = "#9399b2",
				-- overlay1 = "#7f849c",
				-- overlay0 = "#6c7086",
				-- surface2 = "#585b70",
				-- surface1 = "#45475a",
				-- surface0 = "#313244",
				-- base = "#1e1e2e",
				-- mantle = "#181825",
				-- crust = "#11111b",
			},
		},
	},
}
