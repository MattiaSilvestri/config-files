--- @type LazySpec
return {
	"neovim/nvim-lspconfig",
	config = function()
		local lsp = require("lspconfig")

		lsp.pyright.setup({})
		lsp.lua_ls.setup({})
	end,
}
