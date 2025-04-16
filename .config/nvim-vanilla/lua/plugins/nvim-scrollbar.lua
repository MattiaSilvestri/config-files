--- @type LazySpec

return {
	"petertriho/nvim-scrollbar",
	event = "BufEnter",
	opts = {
		show_in_active_only = true,
		show = true,
		excluded_filetypes = {
			"dropbar_menu",
			"dropbar_menu_fzf",
			"DressingInput",
			"cmp_docs",
			"cmp_menu",
			"noice",
			"prompt",
			"TelescopePrompt",
			"NvimTree",
			"snacks_layout_box",
		},
		excluded_buftypes = {
			"terminal",
			"nofile",
		},
		handlers = {
			cursor = false,
			diagnostic = true,
			gitsigns = false, -- Requires gitsigns
			handle = true,
			search = false, -- Requires hlslens
			ale = false, -- Requires ALE
		},
	},
}
