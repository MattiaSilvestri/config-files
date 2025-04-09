--- @type LazySpec
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
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		after = "catppuccin",
		config = true,
		opts = {
			highlights = require("catppuccin.groups.integrations.bufferline").get(),
			options = {
				offsets = {
					{
						filetype = "snacks_layout_box",
						text = "󰙅  File Explorer",
						separator = true,
					},
				},
			},
		},
	},
}
