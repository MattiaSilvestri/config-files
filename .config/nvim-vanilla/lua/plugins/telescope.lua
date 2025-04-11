--- @type LazySpec
local actions = require("telescope.actions")

return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"jonarrien/telescope-cmdline.nvim",
	},
	opts = {
		defaults = {
			border = true,
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					height = 0.8,
					width = 0.8,
					preview_width = 0.5,
				},
				vertical = {
					height = 0.99,
					width = 0.99,
					preview_height = 0.5,
				},
				cursor = {
					height = 0.8,
					width = 0.8,
					preview_height = 0.5,
					preview_width = 0.5,
				},
			},
			mappings = {
				i = {
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
				},
			},
		},
		extensions = {
			cmdline = {},
		},
	},
	config = function(_, opts)
		require("telescope").setup(opts)
		require("telescope").load_extension("cmdline")
	end,
}
