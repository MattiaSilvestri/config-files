-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

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

local original_notify = vim.notify

vim.notify = function(msg, level, opts)
  -- Suppress specific warning
  if msg:match "offset_encoding is required, using the offset_encoding from the first client" then return end

  -- Call the original notify function for other messages
  original_notify(msg, level, opts)
end

local original_notify = vim.notify

vim.notify = function(msg, level, opts)
  if msg:match "format request failed, no matching language servers" then return end
  original_notify(msg, level, opts)
end

-- require("lspconfig").ltex.setup {
--   filetypes = { "latex", "bib", "tex" },
--   settings = {
--     ltex = {
--       language = "it",
--       diagnosticSeverity = "warning",
--       completionEnabled = true,
--       enabled = { "latex", "tex" },
--     },
--   },
-- }
--
-- -- HTML
-- require("lspconfig").html.setup {
--   init_options = {
--     provideFormatter = false,
--   },
-- }
--
-- -- eslint
-- require("lspconfig").eslint.setup {
--   bin = "eslint", -- or `eslint_d`
--   code_actions = {
--     enable = true,
--     apply_on_save = {
--       enable = true,
--       types = { "directive", "problem", "suggestion", "layout" },
--     },
--     disable_rule_comment = {
--       enable = true,
--       location = "separate_line", -- or `same_line`
--     },
--   },
--   diagnostics = {
--     enable = true,
--     report_unused_disable_directives = false,
--     run_on = "type", -- or `save`
--   },
-- }
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
