--- @type LazySpec

return {
	"catppuccin/nvim",
	name = "catppuccin",
	enabled = true,
	priority = 1000,
	opts = {
		blink_cmp = true,
		term_colors = true,
		integrations = {
			blink_cmp = true,
		},
		color_overrides = {
			-- mocha = {
			-- 	base = "#181825",
			-- 	mantle = "#11111b",
			-- },
		},
	},
}
