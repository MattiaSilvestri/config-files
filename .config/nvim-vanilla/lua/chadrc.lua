local M = {}

-- Import components
-- local components = require("heirline-components.all")
-- local status = require("heirline-components.all").component

M.base46 = {
	theme = "catppuccin",
}

M.ui = {
	statusline = {
		enabled = true,
		theme = "minimal",
	},
	cmp = {
		style = "default",
		format_colors = {
			tailwind = false,
		},
	},
	telescope = { style = "borderless" }, -- borderless / bordered
	tabufline = {
		enabled = false,
		lazyload = true,
		order = { "treeOffset", "buffers", "tabs", "btns" },
		modules = nil,
		bufwidth = 21,
	},

	nvdash = {
		load_on_startup = true,

		header = {
			"                            ",
			"     ▄▄         ▄ ▄▄▄▄▄▄▄   ",
			"   ▄▀███▄     ▄██ █████▀    ",
			"   ██▄▀███▄   ███           ",
			"   ███  ▀███▄ ███           ",
			"   ███    ▀██ ███           ",
			"   ███      ▀ ███           ",
			"   ▀██ █████▄▀█▀▄██████▄    ",
			"     ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀   ",
			"                            ",
			"     Powered By  eovim    ",
			"                            ",
		},

		buttons = {
			{ txt = "  Find File", keys = "Spc f f", cmd = "Telescope find_files" },
			{ txt = "  Recent Files", keys = "Spc f o", cmd = "Telescope oldfiles" },
			-- more... check nvconfig.lua file for full list of buttons
		},
	},

	lsp = { signature = false },
}

return M
