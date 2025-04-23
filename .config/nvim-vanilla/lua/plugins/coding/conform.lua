--- @type LazySpec
-- I keep this plugin just because it allows to easily enable format on save,
-- the formatters are actually managed by mason-null-ls
return {
	"stevearc/conform.nvim",
	enabled = true,
	event = "BufEnter",
	opts = {
		formatters_by_ft = {
			python = { "ruff" },
			htmldjango = { "djlint" },
			vue = { "prettierd" },
			lua = { "stylua" },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		format_on_save = {
			timeout_ms = 1000,
			lsp_format = "fallback",
		},
	},
}
