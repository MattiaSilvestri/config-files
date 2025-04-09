--- LSP diagnostic signs ---
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }

vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = false,
	-- virtual_text = {
	-- 	prefix = "●",
	-- },
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = signs.Error,
			[vim.diagnostic.severity.WARN] = signs.Warn,
			[vim.diagnostic.severity.INFO] = signs.Info,
			[vim.diagnostic.severity.HINT] = signs.Hint,
		},
	},
	float = {
		border = "rounded",
		header = "",
		source = true,
		prefix = function(_, i, total)
			return tostring(i) .. "/" .. tostring(total) .. " ", "DiagnosticPrefix"
		end,
	},
})
