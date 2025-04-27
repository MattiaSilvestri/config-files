local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))

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
}
