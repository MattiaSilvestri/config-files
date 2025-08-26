--- @type LazySpec
return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && yarn install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
	end,
	ft = { "markdown" },
	keys = {
		{
			"<leader>mp",
			ft = "markdown",
			"<cmd>MarkdownPreviewToggle<cr>",
			desc = "Markdown Preview",
		},
	},
	config = function()
		-- vim.cmd [[do FileType]]
		-- vim.g.mkdp_open_to_the_world = 1
		-- vim.g.mkdp_open_ip = "127.0.0.1"
		-- vim.g.mkdp_port = 8001
		vim.g.mkdp_browser = "microsoft-edge-stable"
		vim.g.mkdp_echo_preview_url = 1
		vim.g.mkdp_auto_close = 0
		vim.g.mkdp_auto_start = 1
	end,
}
