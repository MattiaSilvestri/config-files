--- @type LazySpec
return {
	"nvim-lua/plenary.nvim",
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{
		"nvchad/ui",
		enabled = true,
		config = function()
			require("nvchad")
		end,
	},
	{
		"nvchad/base46",
		enabled = true,
		lazy = true,
		build = function()
			require("base46").load_all_highlights()
		end,
	},
	"nvchad/volt", -- optional, needed for theme switcher
	-- or just use Telescope themes
}
