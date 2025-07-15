--- @type LazySpec
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    words = {
      ---@field enabled? boolean
      enabled = true,
    },
    scope = {
      ---@field enabled? boolean
      enabled = true,
    },
    lazygit = {
      ---@class snacks.lazygit.Config: snacks.terminal.Opts
      ---@field args? string[]
      ---@field theme? snacks.lazygit.Theme
      ---@field enabled? boolean
      enabled = true,
    },
    toggle = {
      enabled = true,
    },
    explorer = {
      enabled = true,
    },
    picker = { enabled = true },
    notifier = { enabled = true },
  },
}
