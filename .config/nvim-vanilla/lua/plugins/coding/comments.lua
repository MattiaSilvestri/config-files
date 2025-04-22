--- @type LazySpec
return {
	{ "JoosepAlviste/nvim-ts-context-commentstring", config = true },
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
		-- opts = function(_, opts)
		-- 	opts = {
		-- 		ft.set("htmldjango", "{#%s#}"),
		-- 	}
		-- 	return opts
		-- end,
	},
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		requires = "nvim-lua/plenary.nvim",
		keys = {
			{ "<leader>sa", "<cmd>TodoTelescope<cr>", desc = "List TODOs" },
		},
	},
}
