--- @type LazySpec
return {
	"gennaro-tedesco/nvim-possession",
	dependencies = {
		{ "ibhagwan/fzf-lua" },
		{
			"tiagovla/scope.nvim",
			lazy = false,
			config = true,
		},
	},
	config = function()
		require("nvim-possession").setup({
			sessions = {
				sessions_path = vim.fn.stdpath("config") .. "/sessions/",
			},
			autoload = false,
			autoswitch = {
				enable = true,
			},
			save_hook = function()
				vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
			end,
			post_hook = function()
				vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
			end,
		})
	end,
}
