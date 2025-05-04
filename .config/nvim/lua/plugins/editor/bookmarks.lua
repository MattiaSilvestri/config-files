--- @type LazySpec
return {
	{
		"otavioschwanck/arrow.nvim",
		lazy = false,
		opts = {
			save_path = function()
				return vim.fn.stdpath("config") .. "/arrow"
			end,
			show_icons = true,
			leader_key = ";", -- Recommended to be a single key
			buffer_leader_key = "m", -- Per Buffer Mappings
			global_bookmarks = true,
		},
	},
}
