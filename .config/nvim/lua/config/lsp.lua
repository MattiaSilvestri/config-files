-- Get capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))
capabilities = vim.tbl_deep_extend(
	"force",
	capabilities,
	{ textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } } }
)

-- Disable default signature
vim.lsp.buf.signature_help = {
	silent = true,
}

return {
	["pyright"] = {
		capabilities = vim.tbl_deep_extend("force", capabilities, {}),
		-- on_attach = function(client, bufnr)
		-- 	client.server_capabilities.publishDiagnosticsProvider = false
		-- end,
		settings = {
			pyright = {
				-- Using Ruff's import organizer
				disableOrganizeImports = true,
			},
			python = {
				-- analysis = {
				-- 	-- Ignore all files for analysis to exclusively use Ruff for linting
				-- 	ignore = { "*" },
				-- },
			},
		},
		-- on_attach = function(client, bufnr)
		-- 	-- Disable the *built-in* LSP popup
		-- 	client.handlers["textDocument/signatureHelp"] = function() end
		-- end,
	},
	["ruff"] = {
		capabilities = capabilities,
		init_options = {
			settings = {
				lint = {
					enable = true,
					preview = true,
				},
				organizeImports = true,
			},
		},
	},
	["lua_ls"] = { capabilities = capabilities },
	["emmet_ls"] = { capabilities = capabilities },
	["eslint"] = { capabilities = capabilities },
	["tailwindcss"] = { capabilities = capabilities },
	["html"] = { capabilities = capabilities },
	["cssls"] = { capabilities = capabilities },
	["css_variables"] = { capabilities = capabilities },
	["vue_ls"] = {
		capabilities = capabilities,
		init_options = {
			vue = {
				hybridMode = true,
			},
		},
		settings = {
			typescript = {
				inlayHints = {
					enumMemberValues = {
						enabled = true,
					},
					functionLikeReturnTypes = {
						enabled = true,
					},
					propertyDeclarationTypes = {
						enabled = true,
					},
					parameterTypes = {
						enabled = true,
						suppressWhenArgumentMatchesName = true,
					},
					variableTypes = {
						enabled = true,
					},
				},
			},
		},
	},
	["ts_ls"] = {
		capabilities = capabilities,
		init_options = {
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vim.fn.stdpath("data")
								.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
						languages = { "vue" },
					},
				},
			},
			settings = {
				typescript = {
					tsserver = {
						useSyntaxServer = false,
					},
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		},
	},
}
