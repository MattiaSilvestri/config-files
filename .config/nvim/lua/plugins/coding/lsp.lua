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
		-- config = function(),
		-- local lsp = require("lspconfig")
		-- local capabilities = vim.lsp.protocol.make_client_capabilities()
		--
		-- capabilities =
		-- 	vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))

		-- lsp.pyright.setup({
		-- 	capabilities = vim.tbl_deep_extend("force", capabilities, {}),
		-- 	settings = {
		-- 		pyright = {
		-- 			-- Using Ruff's import organizer
		-- 			disableOrganizeImports = true,
		-- 		},
		-- 		python = {
		-- 			analysis = {
		-- 				-- Ignore all files for analysis to exclusively use Ruff for linting
		-- 				ignore = { "*" },
		-- 			},
		-- 		},
		-- 	},
		-- 	-- on_attach = function(client, bufnr)
		-- 	-- 	-- Disable the *built-in* LSP popup
		-- 	-- 	client.handlers["textDocument/signatureHelp"] = function() end
		-- 	-- end,
		-- })
		-- lsp.ruff.setup({
		-- 	capabilities = vim.tbl_deep_extend("force", capabilities, {}),
		-- 	init_options = {
		-- 		settings = {
		-- 			lint = {
		-- 				enable = false,
		-- 				preview = true,
		-- 			},
		-- 		},
		-- 	},
		-- })
		-- 		lsp.lua_ls.setup({ capabilities = capabilities })
		-- 		lsp.emmet_ls.setup({ capabilities = capabilities })
		-- 		lsp.eslint.setup({ capabilities = capabilities })
		-- 		lsp.tailwindcss.setup({ capabilities = capabilities })
		-- 		lsp.html.setup({ capabilities = capabilities })
		-- 		lsp.cssls.setup({ capabilities = capabilities })
		-- 		lsp.css_variables.setup({ capabilities = capabilities })
		-- 		lsp.volar.setup({
		-- 			init_options = {
		-- 				vue = {
		-- 					hybridMode = true,
		-- 				},
		-- 			},
		-- 			settings = {
		-- 				typescript = {
		-- 					inlayHints = {
		-- 						enumMemberValues = {
		-- 							enabled = true,
		-- 						},
		-- 						functionLikeReturnTypes = {
		-- 							enabled = true,
		-- 						},
		-- 						propertyDeclarationTypes = {
		-- 							enabled = true,
		-- 						},
		-- 						parameterTypes = {
		-- 							enabled = true,
		-- 							suppressWhenArgumentMatchesName = true,
		-- 						},
		-- 						variableTypes = {
		-- 							enabled = true,
		-- 						},
		-- 					},
		-- 				},
		-- 			},
		-- 			capabilities = capabilities,
		-- 		})
		-- 		lsp.ts_ls.setup({
		-- 			capabilities = capabilities,
		-- 			init_options = {
		-- 				plugins = {
		-- 					{
		-- 						name = "@vue/typescript-plugin",
		-- 						location = vim.fn.stdpath("data")
		-- 							.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
		-- 						languages = { "vue" },
		-- 					},
		-- 				},
		-- 			},
		-- 			settings = {
		-- 				typescript = {
		-- 					tsserver = {
		-- 						useSyntaxServer = false,
		-- 					},
		-- 					inlayHints = {
		-- 						includeInlayParameterNameHints = "all",
		-- 						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
		-- 						includeInlayFunctionParameterTypeHints = true,
		-- 						includeInlayVariableTypeHints = true,
		-- 						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
		-- 						includeInlayPropertyDeclarationTypeHints = true,
		-- 						includeInlayFunctionLikeReturnTypeHints = true,
		-- 						includeInlayEnumMemberValueHints = true,
		-- 					},
		-- 				},
		-- 			},
		-- 		})
		-- end,
	},
}
