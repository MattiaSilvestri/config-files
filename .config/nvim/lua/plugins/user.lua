-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " █████  ███████ ████████ ██████   ██████",
        "██   ██ ██         ██    ██   ██ ██    ██",
        "███████ ███████    ██    ██████  ██    ██",
        "██   ██      ██    ██    ██   ██ ██    ██",
        "██   ██ ███████    ██    ██   ██  ██████",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },
  { "kevinhwang91/nvim-ufo", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  -- { "francoiscabrol/ranger.vim", cmd = "Ranger" },
  {
    "kelly-lin/ranger.nvim",
    lazy = false,
    config = function()
      require("ranger-nvim").setup {
        replace_netrw = true,
        ui = {
          border = "none",
          height = 1,
          width = 1,
          x = 0.5,
          y = 0.5,
        },
      }
      vim.api.nvim_set_keymap("n", "<leader>sr", "", {
        noremap = true,
        callback = function() require("ranger-nvim").open(true) end,
      })
    end,
  },
  { "rbgrouleff/bclose.vim", lazy = false },
  { "dyng/ctrlsf.vim", event = "User AstroFile" },
  { "mg979/vim-visual-multi", event = "User AstroFile" },
  -- { "tpope/vim-surround" },
  { "ixru/nvim-markdown", event = "User AstroFile" },
  { "christoomey/vim-tmux-navigator", lazy = false },
  { "kevinhwang91/rnvimr", cmd = "RnvimrToggle" },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    requires = "nvim-lua/plenary.nvim",
    opts = {},
    keys = {
      { "<leader>sa", "<cmd>TodoTelescope<cr>", desc = "List TODOs" },
    },
  },
  { "folke/trouble.nvim", cmd = { "Trouble", "TroubleToggle" } },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
  {
    "lervag/vimtex",
    event = "User AstroFile",
    init = function()
      -- vim.g['vimtex_view_method'] = 'zathura'     -- main variant with xdotool (requires X11; not compatible with wayland)
      vim.g["vimtex_view_method"] = "zathura_simple" -- for variant without xdotool to avoid errors in wayland
      vim.g["vimtex_quickfix_mode"] = 0 -- suppress error reporting on save and build
      vim.g["vimtex_mappings_enabled"] = 0 -- Ignore mappings
      vim.g["vimtex_indent_enabled"] = 0 -- Auto Indent
      vim.g["tex_flavor"] = "latex" -- how to read tex files
      vim.g["tex_indent_items"] = 0 -- turn off enumerate indent
      vim.g["tex_indent_brace"] = 0 -- turn off brace indent
      vim.g["vimtex_context_pdf_viewer"] = "okular" -- external PDF viewer run from vimtex menu command
      vim.g["vimtex_log_ignore"] = { -- Error suppression:
        "Underfull",
        "Overfull",
        "specifier changed to",
        "Token not allowed in a PDF string",
      }
      vim.g.maplocalleader = ","
    end,
  },
  {
    "Exafunction/codeium.vim",
    event = "User AstroFile",
    config = function()
      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set("i", "<C-l>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
    end,
  },
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    config = function()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
    cmd = {
      "PeekOpen",
      "PeekClose",
    },
    opts = {
      app = "firefox",
    },
  },
  -- {
  --   "mfussenegger/nvim-dap",
  --   cmd = "VeryLazy",
  --   config = function()
  --     local dap = require "dap"
  --     dap.configurations.python = {
  --       {
  --         name = "Neovim default",
  --         type = "python",
  --         request = "launch",
  --         program = "${file}",
  --         justMyCode = false,
  --         pythonPath = function()
  --           local venv_path = os.getenv "VIRTUAL_ENV"
  --           if venv_path then return venv_path .. "/bin/python" end
  --           return "/usr/bin/python3"
  --         end,
  --       },
  --     }
  --   end,
  -- },
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    requires = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },
  {
    "folke/neodev.nvim",
    event = "VeryLazy",
    opts = { library = { plugins = { "nvim-dap-ui" }, types = true } },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "User AstroFile",
    config = function()
      local rainbow_delimiters = require "rainbow-delimiters"

      require("rainbow-delimiters.setup").setup {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
  {
    "ray-x/web-tools.nvim",
    event = "User AstroFile",
    config = function()
      require("web-tools").setup {
        -- your configuration
        keymaps = {
          rename = nil, -- by default use same setup of lspconfig
          repeat_rename = ".", -- . to repeat
        },
        hurl = { -- hurl default
          show_headers = false, -- do not show http headers
          floating = false, -- use floating windows (need guihua.lua)
          json5 = false, -- use json5 parser require json5 treesitter
          formatters = { -- format the result by filetype
            json = { "jq" },
            html = { "prettier", "--parser", "html" },
          },
        },
      }
    end,
  },
  {
    "wolandark/vim-live-server",
    event = "User AstroFile",
  },
  {
    "MunifTanjim/prettier.nvim",
    event = "User AstroFile",
    config = function()
      require("prettier").setup {
        bin = "prettier", -- or `'prettierd'` (v0.23.3+)
        filetypes = {
          "css",
          "graphql",
          "html",
          "javascript",
          "javascriptreact",
          "json",
          "less",
          "markdown",
          "scss",
          "typescript",
          "typescriptreact",
          "yaml",
        },
      }
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "User AstroFile",
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = "User AstroFile",
    enabled = false,
    init = require("colorizer").setup(),
    config = function()
      require("colorizer").setup {
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          RRGGBBAA = true,
          AARRGGBB = true,
          rgb_fn = true,
          hsl_fn = true,
          css = true,
          css_fn = true,
          mode = "background",
        },
      }
    end,
  },
  {
    "otavioschwanck/arrow.nvim",
    lazy = false,
    opts = {
      save_path = function() return vim.fn.stdpath "config" .. "/arrow" end,
      show_icons = true,
      leader_key = ";", -- Recommended to be a single key
      buffer_leader_key = "m", -- Per Buffer Mappings
      global_bookmarks = true,
    },
  },
  -- {
  --   "ldelossa/nvim-ide",
  --   lazy = false,
  --   config = function() require("nvim-ide").setup {} end,
  -- },
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>yy",
        function() require("yazi").yazi() end,
        desc = "Open the file manager",
      },
      {
        -- Open in the current working directory
        "<leader>yw",
        function() require("yazi").yazi(nil, vim.fn.getcwd()) end,
        desc = "Open the file manager in nvim's working directory",
      },
    },
    ---@type YaziConfig
    opts = {
      open_for_directories = false,
    },
  },
  -- {
  --   "OXY2DEV/markview.nvim",
  --   lazy = false, -- Recommended
  --   -- ft = "markdown" -- If you decide to lazy-load anyway
  --
  --   dependencies = {
  --     -- You will not need this if you installed the
  --     -- parsers manually
  --     -- Or if the parsers are in your $RUNTIMEPATH
  --     "nvim-treesitter/nvim-treesitter",
  --
  --     "nvim-tree/nvim-web-devicons",
  --   },
  -- },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {},
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  },
}
