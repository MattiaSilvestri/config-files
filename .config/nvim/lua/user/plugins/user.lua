return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },
  {"francoiscabrol/ranger.vim", cmd = "Ranger"},
  "rbgrouleff/bclose.vim",
  {"dyng/ctrlsf.vim", lazy = false},
  {"pelodelfuego/vim-swoop", cmd = "Swoop"},
  {"mg979/vim-visual-multi", lazy = false},
  {"tpope/vim-surround", lazy = false},
  {"folke/trouble.nvim", cmd = {"Trouble", "TroubleToggle"}},
  {"catppuccin/nvim", name = "catppuccin"}
}
