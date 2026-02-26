-- Some vimscript options --
vim.cmd([[
let mapleader = " "
]])

local mappings = require("config.mappings") -- Load mappings

-- MAPPINGS --
-- Set keymaps from config/mappings.lua
for mode, mode_mappings in pairs(mappings) do
	for key, map in pairs(mode_mappings) do
		local cmd = map[1] -- First value is the command/action
		local desc = map.desc -- Second value is optional description

		if cmd then
			vim.keymap.set(
				mode,
				key,
				cmd,
				{ desc = desc, noremap = not (map.remap == true), silent = true, expr = map.expr or false }
			)
		end
	end
end
