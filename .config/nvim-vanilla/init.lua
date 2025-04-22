-- Load custom highlight groups and diagnostics first so they can be used in other files
require("config.diagnostics")
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46_cache/"

-- Load lazy packages
require("config.lazy")

-- Nvui stuff --
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
	dofile(vim.g.base46_cache .. v)
end

local highlights = require("config.highlights")
local options = require("config.options") -- Load options
local mappings = require("config.mappings") -- Load mappings

-- Some vimscript options --
vim.cmd([[
let mapleader = " "
]])

-- Set colorscheme --
vim.cmd.colorscheme(options.colorscheme)

-- HIGHLIGHTS --
for group, color in pairs(highlights) do
	vim.api.nvim_set_hl(0, group, color)
end

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
local wk = require("which-key")
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
		elseif desc then
			wk.add({ key, group = desc }, { mode = mode })
		end
	end
end
