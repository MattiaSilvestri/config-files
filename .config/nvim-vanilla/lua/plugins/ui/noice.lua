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
		presets = {
			lsp_doc_border = true,
		},
		lsp = {
			message = {
				-- Messages shown by lsp servers
				enabled = true,
				view = "notify",
				opts = {},
			},
			signature = {
				enabled = false,
				auto_open = { enabled = false },
				view = "popup",
			},
			override = {
				-- override the default lsp markdown formatter with Noice
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				-- override the lsp markdown formatter with Noice
				["vim.lsp.util.stylize_markdown"] = true,
				-- override cmp documentation with Noice (needs the other options to work)
				["cmp.entry.get_documentation"] = true,
			},
		},
		views = {
			cmdline_popup = {
				border = {
					-- style = "none",
					-- padding = { 1, 2 },
				},
				filter_options = {},
				-- win_options = {
				-- 	winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
				-- },
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
