--- @type LazySpec
return {
	{
		"ray-x/lsp_signature.nvim",
		enabled = false,
		event = "InsertEnter",
		config = function()
			require("lsp_signature").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		-- example calling setup directly for each LSP
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local lsp = require("lspconfig")

			lsp.pyright.setup({ capabilities = capabilities })
			lsp.lua_ls.setup({ capabilities = capabilities })
			lsp.emmet_ls.setup({ capabilities = capabilities })
			lsp.eslint.setup({ capabilities = capabilities })
			lsp.tailwindcss.setup({ capabilities = capabilities })
			lsp.volar.setup({
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
				capabilities = capabilities,
			})
			lsp.ts_ls.setup({
				capabilities = capabilities,
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
							languages = { "javascript", "typescript", "vue" },
						},
					},
				},
				filetypes = {
					"javascript",
					"typescript",
					"vue",
				},
			})
		end,
	},
}
