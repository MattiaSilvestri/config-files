-- Import modules
local telescope = require("telescope.builtin")
local Snacks = require("snacks")

return {
	n = {
		-- Telescope --
		["<leader>ff"] = {
			function()
				telescope.find_files()
			end,
			desc = "Find files",
		},
		["<leader>fg"] = {
			function()
				telescope.live_grep()
			end,
			desc = "Live grep",
		},

		-- Snacks --
		["<leader>e"] = {
			function()
				Snacks.explorer.open()
			end,
			desc = "Snacks Explorer",
		},
	},
}
