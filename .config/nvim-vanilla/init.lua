-- Some vimscript options --
vim.cmd([[
let mapleader = " "
]])

-- Load custom highlight groups first so they can be used in other files
require("config.highlights")

-- Load lazy packages
require("config.lazy")

local options = require("config.options") -- Load options
local mappings = require("config.mappings") -- Load mappings

-- Set colorscheme --
vim.cmd.colorscheme(options.colorscheme)

-- OPTIONS --
-- Read vim options (:set)
if options.opt then
	for k, v in pairs(options.opt) do
		vim.opt[k] = v
	end
end
-- Global options
if options.g then
	for k, v in pairs(options.g) do
		vim.g[k] = v
	end
end

-- MAPPINGS --
-- Set keymaps from config/mappings.lua

for mode, mode_mappings in pairs(mappings) do
	for key, map in pairs(mode_mappings) do
		local cmd = map[1] -- First value is the command/action
		local desc = map[2] -- Second value is optional description

		vim.keymap.set(mode, key, cmd, { desc = desc, noremap = true, silent = true })
	end
end
