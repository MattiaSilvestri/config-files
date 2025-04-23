--- @type LazySPec
return {
	{ "williamboman/mason.nvim", config = true },
	{ "WhoIsSethDaniel/mason-tool-installer.nvim", config = true },
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
		},
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"pyright",
				"ruff",
				"emmet_ls",
				"eslint",
				"tailwindcss",
				"volar",
				"ts_ls",
				"vuels",
				"html",
				"cssls",
				"css_variables",
			},
			automatic_installation = true,
		},
	},
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile", "VimEnter" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-null-ls").setup({
				ensure_installed = {
					-- "prettier",
					"prettierd",
					"stylua",
					"black",
					"djlint",
					"luasnip",
				},
				methods = {
					diagnostics = true,
					formatting = false,
					code_actions = true,
					completion = true,
					hover = true,
				},
				automatic_installation = false,
				handlers = {},
			})
			require("null-ls").setup({
				sources = {
					-- require("null-ls").builtins.completion.luasnip,
				},
			})
		end,
	},
}
