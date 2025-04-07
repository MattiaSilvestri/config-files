--- @type LazySpec
return {
	"lewis6991/gitsigns.nvim",
	config = true,
	opts = {
		signs_staged_enable = true,
		signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
		numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
		linehl = true, -- Toggle with `:Gitsigns toggle_linehl`
		word_diff = true, -- Toggle with `:Gitsigns toggle_word_diff`
	},
}
