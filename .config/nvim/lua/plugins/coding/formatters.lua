--- @type LazySpec
return {
	{
		"MunifTanjim/prettier.nvim",
		event = "BufEnter",
		config = function()
			require("prettier").setup({
				bin = "prettierd", -- or `'prettierd'` (v0.23.3+)
				filetypes = {
					"css",
					"graphql",
					"html",
					"javascript",
					"javascriptreact",
					"json",
					"less",
					"markdown",
					"scss",
					"typescript",
					"typescriptreact",
					"yaml",
				},
			})
		end,
	},
}
