--- @type LazySpec
return {
	{
		"gennaro-tedesco/nvim-possession",
		enabled = true,
		lazy = false,
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
					sessions_path = vim.fn.stdpath("data") .. "/sessions/",
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
	},
	{
		"rmagatti/auto-session",
		lazy = false,
		enabled = false,
		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			session_lens = {
				picker = "snacks", -- "telescope"|"snacks"|"fzf"|"select"|nil Pickers are detected automatically but you can also set one manually. Falls back to vim.ui.select
				previewer = "summary", -- 'summary'|'active_buffer'|function - How to display session preview. 'summary' shows a summary of the session, 'active_buffer' shows the contents of the active buffer in the session, or a custom function
			},
		},
	},
}
