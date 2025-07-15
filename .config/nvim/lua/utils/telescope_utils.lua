local telescope = require("telescope.builtin")
local window_picker = require("window-picker")

-- Custom wrapper function
local function open_definition_in_window()
	-- Pick a window (returns window ID)
	local picked_window = window_picker.pick_window({
		include_current_win = false,
	})

	if not picked_window then
		vim.notify("No window selected", vim.log.levels.WARN)
		return
	end

	-- Use Telescope to find definitions
	telescope.lsp_definitions({
		jump_type = "never", -- avoid jumping right away
		attach_mappings = function(_, map)
			map("i", "<CR>", function(prompt_bufnr)
				local entry = require("telescope.actions.state").get_selected_entry()
				require("telescope.actions").close(prompt_bufnr)
				-- Open location in the picked window
				vim.api.nvim_set_current_win(picked_window)
				vim.lsp.util.jump_to_location(entry.value)
			end)
			return true
		end,
	})
end

return {
	open_definition_in_window = open_definition_in_window,
}
