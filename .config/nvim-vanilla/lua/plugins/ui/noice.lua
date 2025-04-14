local cmdline = require("blink.cmp.config.modes.cmdline")
--- @type LazySpec
return {
	"folke/noice.nvim",
	enabled = true,
	event = "VeryLazy",
	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
		},
		messages = {
			enabled = true,
		},
		lsp = {
			signature = {
				auto_open = { enabled = false },
			},
		},
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
}
