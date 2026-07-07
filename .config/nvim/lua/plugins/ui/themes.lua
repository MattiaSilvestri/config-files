--- @type LazySpec
local base46 = dofile(vim.g.base46_cache .. "colors")

return {
	{
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
					base = base46.black,
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
	},
	{
		"ydkulks/cursor-dark.nvim",
		lazy = false,
		enabled = false,
		priority = 1000,
		config = function()
			-- vim.cmd.colorscheme("cursor-dark-midnight")
			require("cursor-dark").setup({
				-- For theme
				style = "dark-midnight",
				-- For a transparent background
				transparent = true,
				-- If you have dashboard-nvim plugin installed
				dashboard = true,
			})
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		opts = {
			transparent = false, -- do not set background color
			undercurl = false,
			theme = "dragon", -- Load "wave" theme
			background = { -- map the value of 'background' option to a theme
				dark = "dragon", -- try "dragon" !
			},
		},
	},
	{
		"vague-theme/vague.nvim",
		opts = {
			transparent = false, -- If true, background is not set
			bold = true, -- Disable bold globally
			italic = true, -- Disable italic globally
			on_highlights = function(hl, colors) end,
			colors = {
				bg = "#141415",
				inactiveBg = "#1c1c24",
				fg = "#cdcdcd",
				floatBorder = "#878787",
				line = "#252530",
				comment = "#606079",
				builtin = "#b4d4cf",
				func = "#c48282",
				string = "#e8b589",
				number = "#e0a363",
				property = "#c3c3d5",
				constant = "#aeaed1",
				parameter = "#bb9dbd",
				visual = "#333738",
				error = "#d8647e",
				warning = "#f3be7c",
				hint = "#7e98e8",
				operator = "#90a0b5",
				keyword = "#6e94b2",
				type = "#9bb4bc",
				search = "#405065",
				plus = "#7fa563",
				delta = "#f3be7c",
			},
		},
	},
	{
		"nyoom-engineering/oxocarbon.nvim",
	},
}
