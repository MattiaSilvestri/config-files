return {
	get_current_selection = function()
		return table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos(".")), "\n")
	end,
}
