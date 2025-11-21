return {
	colorscheme = "nvchad",
	opt = {
		expandtab = true,
		relativenumber = true,   -- sets vim.opt.relativenumber
		number = true,           -- sets vim.opt.number
		wrap = false,            -- LIne wrawpping
		laststatus = 3,          -- Statusline spans all splits
		cmdheight = 0,
		cursorline = true,       -- Enable highlighting of the current line
		clipboard = "unnamedplus", -- Allows neovim to access the system clipboard
		tabstop = 2,
		shiftwidth = 0,
		softtabstop = 0,
		copyindent = true,
		fillchars = { eob = " " },
		timeoutlen = 100,
		guifont = "FiraCode Nerd Font:h9:w0:#h-normal",
	},
	o = {
		-- fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:",
		foldcolumn = "0",
		foldenable = true,
		-- foldexpr = "nvim_treesitter#foldexpr()",
		foldlevel = 99,
		foldlevelstart = 99,
		foldmethod = "manual",
	},
	g = {
		neovide_padding_top = 6,
		neovide_padding_bottom = 4,
		neovide_padding_right = 6,
		neovide_padding_left = 6,
		neovide_floating_blur_amount_x = 5.0,
		neovide_floating_blur_amount_y = 5.0,
		neovide_floating_corner_radius = 0.3,
		neovide_cursor_animation_length = 0,
		neovide_cursor_vfx_mode = "",
		neovide_text_gamma = 1.3,
		neovide_text_contrast = 0.3,
	},
}
