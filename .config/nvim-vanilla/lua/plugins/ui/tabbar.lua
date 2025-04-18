--- @type LazySpec
local theme = require("catppuccin.palettes").get_palette("mocha")
local bg = "#232232"

return {
	{ "tiagovla/scope.nvim", config = true },
	{
		"romgrk/barbar.nvim",
		enabled = false,
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		config = true,
		opts = {
			-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
			animation = true,
			insert_at_start = true,
			icons = {
				separator = { left = "▎", right = "" },
				separator_at_end = false,
			},
		},
		version = "^1.0.0", -- optional: only update when a new 1.x version is released
	},
	{
		"akinsho/bufferline.nvim",
		enabled = true,
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		after = "catppuccin",
		config = true,
		opts = {
			highlights = require("catppuccin.groups.integrations.bufferline").get({
				custom = {
					all = {
						fill = { bg = bg },
						tab = { bg = bg },
						background = { bg = bg },
						buffer_visible = { bg = bg },
						close_button = { bg = bg },
						close_button_visible = { bg = bg },
						close_button_selected = { bg = theme.base },
						modified_selected = { bg = theme.base },
						modified_visible = { bg = bg },
						modified = { bg = bg },
						indicator_visible = { bg = bg },
						offset_separator = { bg = bg },
						tab_separator = { bg = bg },
						separator = { bg = bg },
						separator_selected = { bg = bg },
						separator_visible = { bg = bg },
						duplicate_visible = { bg = bg },
						duplicate = { bg = bg },
					},
					mocha = {
						-- background = { bg = theme.base },
					},
				},
			}),
			options = {
				offsets = {
					{
						filetype = "snacks_layout_box",
						text = "󰙅  File Explorer",
						separator = true,
					},
					{
						filetype = "NvimTree",
						text = "󰙅  File Explorer",
						separator = true,
					},
					{
						filetype = "neo-tree",
						text = "󰙅  File Explorer",
						separator = true,
					},
				},
				-- indicator = {
				-- 	style = "underline",
				-- },
			},
		},
	},
}
