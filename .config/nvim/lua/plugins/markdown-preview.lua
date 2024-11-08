--- @type LazySpec
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = function()
    require("lazy").load { plugins = { "markdown-preview.nvim" } }
    vim.fn["mkdp#util#install"]()
  end,
  keys = {
    {
      "<leader>cp",
      ft = "markdown",
      "<cmd>MarkdownPreviewToggle<cr>",
      desc = "Markdown Preview",
    },
  },
  config = function()
    vim.cmd [[do FileType]]
    vim.g.mkdp_open_to_the_world = 1
    vim.g.mkdp_open_ip = "127.0.0.1"
    vim.g.mkdp_port = 8001
    vim.g.mkdp_browser = "firefox"
    vim.g.mkdp_echo_preview_url = 1
  end,
}
