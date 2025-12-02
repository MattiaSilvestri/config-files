--- @type LazySpec
return {
	{
		"otavioschwanck/arrow.nvim",
		lazy = false,
		opts = {
			save_path = function()
				return vim.fn.stdpath("config") .. "/arrow"
			end,
			show_icons = true,
			leader_key = ";", -- Recommended to be a single key
			buffer_leader_key = "m", -- Per Buffer Mappings
			global_bookmarks = true,
		},
	},
	{
		"EvWilson/spelunk.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim", -- Optional: for fuzzy search capabilities
			"folke/snacks.nvim", -- Optional: for fuzzy search capabilities
			"ibhagwan/fzf-lua", -- Optional: for fuzzy search capabilities
			"nvim-treesitter/nvim-treesitter", -- Optional: for showing grammar context
		},
		config = function()
			require("spelunk").setup({
				enable_persist = true,
			})
		end,
	},
}
