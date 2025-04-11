--- @type LazySpec
return {
	{ "JoosepAlviste/nvim-ts-context-commentstring", config = true },
	{
		"numToStr/Comment.nvim",
		config = true,
	},
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		requires = "nvim-lua/plenary.nvim",
		opts = {},
		keys = {
			{ "<leader>sa", "<cmd>TodoTelescope<cr>", desc = "List TODOs" },
		},
	},
}
