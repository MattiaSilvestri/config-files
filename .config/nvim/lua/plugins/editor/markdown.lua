return {
	{
		"OXY2DEV/markview.nvim",
		enabled = false,
		lazy = false,
		ft = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
		-- For blink.cmp's completion source
		dependencies = {
			"saghen/blink.cmp",
		},
		opts = {
			filetypes = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
			buf_ignore = {},
			max_length = 99999,
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = true,
		-- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			completions = { lsp = { enabled = true } },
		},
	},
}
