return {
	colorscheme = "nvchad",
	opt = {
		expandtab = true,
		relativenumber = true, -- sets vim.opt.relativenumber
		number = true, -- sets vim.opt.number
		wrap = false, -- LIne wrawpping
		laststatus = 3, -- Statusline spans all splits
		cursorline = true, -- Enable highlighting of the current line
		clipboard = "unnamedplus", -- Allows neovim to access the system clipboard
		tabstop = 2,
		shiftwidth = 0,
		softtabstop = 0,
		copyindent = true,
		fillchars = { eob = " " },
		timeoutlen = 100,
	},
	o = {
		fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:",
		foldcolumn = "1", -- '0' is not bad
		foldlevel = 99, -- Using ufo provider need a large value, feel free to decrease the value
		foldlevelstart = 99,
		foldenable = false,
		foldexpr = "v:lua.vim.lsp.foldexpr()",
		foldmethod = "expr",
	},
	g = {},
}
