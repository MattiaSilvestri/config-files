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

require("lspconfig").ltex.setup {
  filetypes = { "markdown", "latex", "bib", "tex" },
  settings = {
    ltex = {
      language = "it",
      diagnosticSeverity = "warning",
      completionEnabled = true,
      enabled = { "latex", "markdown", "tex" },
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

-- Telescope
require("telescope").setup {
  extensions = {
    ast_grep = {
      command = {
        "sg",
        "--json=stream",
      }, -- must have --json=stream
      grep_open_files = false, -- search in opened files
      lang = nil, -- string value, specify language for ast-grep `nil` for default
    },
  },
}

-- require("transparent").clear_prefix "BufferLine"
-- require("transparent").clear_prefix "NeoTree"
-- require("transparent").clear_prefix "Heirline"

-- require("dap.ext.vscode").load_launchjs(nil, {})
-- local dap = require "dap"
-- table.insert(dap.configurations.python, {
--   type = "python",
--   request = "launch",
--   name = "Django",
--   program = vim.fn.getcwd() .. "/manage.py", -- NOTE: Adapt path to manage.py as needed
--   args = { "runserver" },
-- })

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
