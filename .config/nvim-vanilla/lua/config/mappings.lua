local telescope = require("telescope.builtin")

return {
	n = {
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
	},
}
