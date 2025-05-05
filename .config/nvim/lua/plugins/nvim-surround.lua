--- @type LazySpec
return {
	"kylechui/nvim-surround",
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	config = function()
		require("nvim-surround").setup({
			-- Configuration here, or leave empty to use defaults
			keymaps = {
				insert = "<C-g>s",
				insert_line = "<C-g>S",
				normal = "<leader>ys",
				normal_cur = "<leader>ya$",
				normal_line = "<leader>yS",
				normal_cur_line = "<leader>ySS",
				visual = "S",
				visual_line = "gS",
				delete = "<leader>yds",
				change = "<leader>ycs",
				change_line = "<leader>ycS",
			},
			surrounds = {
				["("] = {
					add = { "( ", " )" },
				},
				[")"] = {
					add = { "(", ")" },
				},
				["{"] = {
					add = { "{ ", " }" },
				},
				["}"] = {
					add = { "{", "}" },
				},
				["<"] = {
					add = { "< ", " >" },
				},
				[">"] = {
					add = { "<", ">" },
				},
				["["] = {
					add = { "[ ", " ]" },
				},
				["]"] = {
					add = { "[", "]" },
				},
				["'"] = {
					add = { "'", "'" },
				},
				['"'] = {
					add = { '"', '"' },
				},
				["`"] = {
					add = { "`", "`" },
				},
				["%"] = {
					add = { "{% ", " %}" },
				},
			},
		})
	end,
}
