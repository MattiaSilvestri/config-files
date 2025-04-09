--- @type LazySpec
return {
	"stevearc/conform.nvim",
	event = "BufEnter",
	opts = {
		formatters_by_ft = {
			python = { "black" },
			vue = { "prettierd" },
		},
		format_on_save = {
			timeout_ms = 1000,
			lsp_format = "fallback",
		},
	},
}
