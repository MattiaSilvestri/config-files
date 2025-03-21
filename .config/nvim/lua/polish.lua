-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
-- local which_key = require "wf.builtin.which_key"
-- local register = require "wf.builtin.register"
-- local bookmark = require "wf.builtin.bookmark"
-- local buffer = require "wf.builtin.buffer"
-- local mark = require "wf.builtin.mark"
--
-- -- Register
-- vim.keymap.set(
--   "n",
--   "<Space>wr",
--   -- register(opts?: table) -> function
--   -- opts?: option
--   register(),
--   { noremap = true, silent = true, desc = "[wf.nvim] register" }
-- )
--
-- -- Bookmark
-- vim.keymap.set(
--   "n",
--   "<Space>wbo",
--   -- bookmark(bookmark_dirs: table, opts?: table) -> function
--   -- bookmark_dirs: directory or file paths
--   -- opts?: option
--   bookmark {
--     nvim = "~/.config/nvim",
--     zsh = "~/.zshrc",
--   },
--   { noremap = true, silent = true, desc = "[wf.nvim] bookmark" }
-- )
--
-- -- Buffer
-- vim.keymap.set(
--   "n",
--   "<Space>wbu",
--   -- buffer(opts?: table) -> function
--   -- opts?: option
--   buffer(),
--   { noremap = true, silent = true, desc = "[wf.nvim] buffer" }
-- )
--
-- -- Mark
-- vim.keymap.set(
--   "n",
--   "'",
--   -- mark(opts?: table) -> function
--   -- opts?: option
--   mark(),
--   { nowait = true, noremap = true, silent = true, desc = "[wf.nvim] mark" }
-- )
--
-- -- Which Key
-- vim.keymap.set(
--   "n",
--   "<Space>",
--   -- mark(opts?: table) -> function
--   -- opts?: option
--   which_key { text_insert_in_advance = "<Space>" },
--   { noremap = true, silent = true, desc = "[wf.nvim] which-key /" }
-- )

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
  },
}

require("lspconfig").ltex.setup {
  filetypes = { "latex", "bib", "tex" },
  settings = {
    ltex = {
      language = "it",
      diagnosticSeverity = "warning",
      completionEnabled = true,
      enabled = { "latex", "tex" },
    },
  },
}

-- HTML
require("lspconfig").html.setup {
  init_options = {
    provideFormatter = false,
  },
}

-- eslint
require("lspconfig").eslint.setup {
  bin = "eslint", -- or `eslint_d`
  code_actions = {
    enable = true,
    apply_on_save = {
      enable = true,
      types = { "directive", "problem", "suggestion", "layout" },
    },
    disable_rule_comment = {
      enable = true,
      location = "separate_line", -- or `same_line`
    },
  },
  diagnostics = {
    enable = true,
    report_unused_disable_directives = false,
    run_on = "type", -- or `save`
  },
}
-- local lspconfig = require "lspconfig"
-- local configs = require "lspconfig.configs"
-- configs.html = {
--   default_config = {
--     filetypes = {
--       "html",
--       "css",
--       "scss",
--       "javascript",
--       "javascriptreact",
--       "typescriptreact",
--       "tsx",
--       "xml",
--       "svelte",
--     },
--   },
-- }
