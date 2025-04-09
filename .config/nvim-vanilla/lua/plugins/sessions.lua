--- @type LazySpec
return {
	"gennaro-tedesco/nvim-possession",
	dependencies = {
		"ibhagwan/fzf-lua",
	},
	opts = {
		sessions = {
			sessions_path = vim.fn.stdpath("config") .. "/sessions/",
		},
	},
}
