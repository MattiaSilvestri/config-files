-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.api.nvim_create_autocmd("UIEnter", {
  group = vim.api.nvim_create_augroup("SetGUISettings", { clear = true }),
  callback = function()
    -- Options specifically targeted at Neovide
    if vim.g.neovide then
      vim.o.guifont = "Inconsolata Nerd Font Mono:h11.9:w0"
      vim.g.neovide_paddinng_top = 20
      vim.g.neovide_paddinng_bottom = 0
      vim.g.neovide_paddinng_right = 0
      vim.g.neovide_paddinng_left = 20
      vim.g.neovide_floating_blur_amount_x = 2
      vim.g.neovide_floating_blur_amount_y = 2
      vim.g.neovide_floating_corener_radius = 0.3
      vim.g.neovide_cursor_animation_length = 0
      vim.g.neovide_cursor_vfx_mode = ""
      vim.g.neovide_text_gamma = 1.3
      vim.g.neovide_text_contrast = 0.3
    end
  end,
})

local luasnip = require "luasnip"
local cmp = require "cmp"

cmp.setup {

  -- ... Your other configuration ...

  mapping = {

    -- ... Your other mappings ...
    ["<CR>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if luasnip.expandable() then
          luasnip.expand()
        else
          cmp.confirm {
            select = true,
          }
        end
      else
        fallback()
      end
    end),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

    -- ... Your other mappings ...
  },

  -- ... Your other configuration ...
}

vim.keymap.set("v", "<leader>y", require("osc52").copy_visual, { desc = "Copy to clipboard" })
-- vim.keymap.set(
--   "n",
--   "<leader>gP",
--   require("navigator.definition").definition_preview,
--   { desc = "Go to definition preview" }
-- )
vim.keymap.set(
  "n",
  "<leader>gP",
  require("goto-preview").goto_preview_definition,
  { desc = "Go to definition preview" }
)
--
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

-- require("lspconfig").ltex.setup {
--   filetypes = { "markdown", "latex", "bib", "tex" },
--   settings = {
--     ltex = {
--       language = "it",
--       diagnosticSeverity = "warning",
--       completionEnabled = true,
--       enabled = { "latex", "markdown", "tex" },
--     },
--   },
-- }

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
    advanced_git_search = {
      -- Browse command to open commits in browser. Default fugitive GBrowse.
      -- {commit_hash} is the placeholder for the commit hash.
      browse_command = "GBrowse {commit_hash}",
      -- when {commit_hash} is not provided, the commit will be appended to the specified command seperated by a space
      -- browse_command = "GBrowse",
      -- => both will result in calling `:GBrowse commit`

      -- fugitive or diffview
      diff_plugin = "fugitive",
      -- customize git in previewer
      -- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
      git_flags = {},
      -- customize git diff in previewer
      -- e.g. flags such as { "--raw" }
      git_diff_flags = {},
      -- Show builtin git pickers when executing "show_custom_functions" or :AdvancedGitSearch
      show_builtin_git_pickers = false,
      entry_default_author_or_date = "author", -- one of "author" or "date"
      keymaps = {
        -- following keymaps can be overridden
        toggle_date_author = "<C-w>",
        open_commit_in_browser = "<C-o>",
        copy_commit_hash = "<C-y>",
        show_entire_commit = "<C-e>",
      },
    },
  },
}

local lspconfig = require "lspconfig"

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
