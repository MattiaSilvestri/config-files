-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

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
  { "rbgrouleff/bclose.vim", lazy = false },
  { "dyng/ctrlsf.vim", event = "User AstroFile" },
  { "mg979/vim-visual-multi", event = "User AstroFile" },
  -- { "tpope/vim-surround" },
  { "ixru/nvim-markdown", event = "User AstroFile" },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  { "aserowy/tmux.nvim", lazy = false },
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
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    lazy = false,
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
  },
  {
    "mfussenegger/nvim-dap",
    cmd = "VeryLazy",
    config = function()
      local dap = require "dap"
      dap.configurations.python = {
        {
          name = "Python: Django",
          type = "python",
          request = "launch",
          program = "${workspaceFolder}/manage.py",
          args = { "runserver", "--noreload", "9000" },
          django = true,
          justMyCode = true,
          pythonPath = function()
            local venv_path = os.getenv "VIRTUAL_ENV"
            if venv_path then return venv_path .. "/bin/python" end
            return "/usr/bin/python3"
          end,
        },
        {
          name = "Python: Chirpstack",
          type = "python",
          request = "launch",
          program = "${workspaceFolder}/src/chirpstack.py",
          args = { "configure", "-id=dd962157-6467-44ab-a982-679c06358361", "--all" },
          justMyCode = true,
          pythonPath = function()
            local venv_path = os.getenv "VIRTUAL_ENV"
            if venv_path then return venv_path .. "/bin/python" end
            return "/usr/bin/python3"
          end,
        },
        {
          name = "Python: Jarvisui",
          type = "python",
          request = "launch",
          program = "${workspaceFolder}/manage.py",
          args = { "runserver", "--noreload", "0:8000" },
          django = true,
          justMyCode = true,
          pythonPath = function()
            local venv_path = os.getenv "VIRTUAL_ENV"
            if venv_path then return venv_path .. "/bin/python" end
            return "/usr/bin/python3"
          end,
        },
      }
    end,
  },
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
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   event = "User AstroFile",
  --   init = require("colorizer").setup(),
  --   config = function()
  --     require("colorizer").setup {
  --       filetypes = { "*" },
  --       user_default_options = {
  --         RGB = true,
  --         RRGGBB = true,
  --         names = false,
  --         RRGGBBAA = true,
  --         AARRGGBB = true,
  --         rgb_fn = true,
  --         hsl_fn = true,
  --         css = true,
  --         css_fn = true,
  --         mode = "background",
  --       },
  --     }
  --   end,
  -- },
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
  --   "DreamMaoMao/yazi.nvim",
  --   dependencies = {
  --     "nvim-telescope/telescope.nvim",
  --     "nvim-lua/plenary.nvim",
  --   },
  --
  --   keys = {
  --     { "<leader>yy", "<cmd>Yazi<CR>", desc = "Toggle Yazi" },
  --   },
  -- },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>yz",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>yw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        "<leader>yy",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    enabled = false,
    opts = {},
    config = function()
      require("lsp_signature").setup {
        debug = false, -- set to true to enable debug logging
        log_path = vim.fn.stdpath "cache" .. "/lsp_signature.log", -- log dir when debug is on
        -- default is  ~/.cache/nvim/lsp_signature.log
        verbose = false, -- show debug line number

        bind = true, -- This is mandatory, otherwise border config won't get registered.
        -- If you want to hook lspsaga or other signature handler, pls set to false
        doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
        -- set to 0 if you DO NOT want any API comments be shown
        -- This setting only take effect in insert mode, it does not affect signature help in normal
        -- mode, 10 by default

        max_height = 12, -- max height of signature floating_window
        max_width = 80, -- max_width of signature floating_window, line will be wrapped if exceed max_width
        -- the value need >= 40
        wrap = true, -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
        floating_window = true, -- show hint in a floating window, set to false for virtual text only mode

        floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
        -- will set to true when fully tested, set to false will use whichever side has more space
        -- this setting will be helpful if you do not want the PUM and floating win overlap

        floating_window_off_x = 1, -- adjust float windows x position.
        -- can be either a number or function
        floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines
        -- can be either number or function, see examples

        close_timeout = 4000, -- close floating window after ms when laster parameter is entered
        fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
        hint_enable = false, -- virtual hint enable
        -- hint_prefix = "🐼 ", -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
        -- or, provide a table with 3 icons
        hint_prefix = {
          above = "↙ ", -- when the hint is on the line above the current line
          current = "← ", -- when the hint is on the same line
          below = "↖ ", -- when the hint is on the line below the current line
        },
        hint_scheme = "String",
        hint_inline = function() return false end, -- should the hint be inline(nvim 0.10 only)?  default false
        -- return true | 'inline' to show hint inline, return 'eol' to show hint at end of line, return false to disable
        -- return 'right_align' to display hint right aligned in the current line
        hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
        handler_opts = {
          border = "rounded", -- double, rounded, single, shadow, none, or a table of borders
        },

        always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

        auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
        extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
        zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

        padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc

        transparency = 100, -- disabled by default, allow floating win transparent value 1~100
        shadow_blend = 36, -- if you using shadow as border use this set the opacity
        shadow_guibg = "Black", -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
        timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
        toggle_key = "<M-x>", -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
        toggle_key_flip_floatwin_setting = false, -- true: toggle floating_windows: true|false setting after toggle key pressed
        -- false: floating_windows setup will not change, toggle_key will pop up signature helper, but signature
        -- may not popup when typing depends on floating_window setting

        select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
        move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating window
        -- e.g. move_cursor_key = '<M-p>',
        -- once moved to floating window, you can use <M-d>, <M-u> to move cursor up and down
        keymaps = {}, -- relate to move_cursor_key; the keymaps inside floating window
        -- e.g. keymaps = { 'j', '<C-o>j' } this map j to <C-o>j in floating window
        -- <M-d> and <M-u> are default keymaps to move cursor up and down
      }
    end,
  },
  {
    "m4xshen/autoclose.nvim",
    event = "User AstroFile",
    config = function() require("autoclose").setup() end,
  },
  {
    "echasnovski/mini.move",
    version = "*",
    event = "User Astrofile",
    config = function() require("mini.move").setup() end,
  },
  {
    "nvim-neorg/neorg",
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {},
          ["core.dirman"] = {
            config = {
              workspaces = {
                work = "~/Notes/Neorg/Work",
              },
            },
          },
        },
      }
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- Recommended
    -- ft = "markdown" -- If you decide to lazy-load anyway

    dependencies = {
      -- You will not need this if you installed the
      -- parsers manually
      -- Or if the parsers are in your $RUNTIMEPATH
      "nvim-treesitter/nvim-treesitter",

      "nvim-tree/nvim-web-devicons",
    },
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = false,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "work",
          path = "~/Notes/Obsidian/Work",
        },
      },
    },
  },
  {
    "aaronhallaert/advanced-git-search.nvim",
    cmd = { "AdvancedGitSearch" },
    config = function()
      -- optional: setup telescope before loading the extension
      require("telescope").setup {}
      require("telescope").load_extension "advanced_git_search"
    end,
    dependencies = { "tpope/vim-fugitive", "tpope/vim-rhubarb" },
  },
  { "wakatime/vim-wakatime", lazy = false },
  {
    "numToStr/Comment.nvim",
    opts = {
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      -- pre_hook = function(ctx)
      --   -- Only change `commentstring` for htmldjango files
      --   if vim.bo.filetype == "htmldjango" then vim.bo.commentstring = "{# %s #}" end
      -- end,
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua", -- optional
      "echasnovski/mini.pick", -- optional
    },
    config = true,
  },

  --   {
  --   "folke/ts-comments.nvim",
  --   opts = {
  --       lang = {
  --         htmldjango = "{# %s #}"
  --       }
  --     },
  --   event = "VeryLazy",
  --   enabled = vim.fn.has("nvim-0.10.0") == 1,
  -- }
  -- {
  --   "xiyaowong/transparent.nvim",
  --   lazy = false,
  --   config = function()
  --     require("transparent").setup {
  --       groups = { -- table: default groups
  --         "Normal",
  --         "NormalNC",
  --         "Comment",
  --         "Constant",
  --         "Special",
  --         "Identifier",
  --         "Statement",
  --         "PreProc",
  --         "Type",
  --         "Underlined",
  --         "Todo",
  --         "String",
  --         "Function",
  --         "Conditional",
  --         "Repeat",
  --         "Operator",
  --         "Structure",
  --         "LineNr",
  --         "NonText",
  --         "SignColumn",
  --         "StatusLine",
  --         "StatusLineNC",
  --         "EndOfBuffer",
  --       },
  --       extra_groups = {}, -- table: additional groups that should be cleared
  --       exclude_groups = { "NotifyBackground" }, -- table: groups you don't want to clear
  --     }
  --   end,
  -- },
  -- {
  --   "ldelossa/nvim-ide",
  --   lazy = false,
  --   config = function() require("ide").setup {} end,
  -- },
}
