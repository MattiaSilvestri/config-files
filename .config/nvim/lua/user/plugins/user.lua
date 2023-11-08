return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- {
  --   'chipsenkbeil/distant.nvim',
  --   lazy = false,
  --   branch = 'v0.2',
  --   config = function()
  --     require('distant').setup {
  --       ['*'] = {
  --         max_timeout = 10000 * 10000
  --       }
  --       -- Applies Chip's personal settings to every machine you connect to
  --       --
  --       -- 1. Ensures that distant servers terminate with no connections
  --       -- 2. Provides navigation bindings for remote directories
  --       -- 3. Provides keybinding to jump into a remote file's parent directory
  --       -- ['*'] = require('distant.settings').chip_default()
  --     }
  --   end
  -- }
  { "francoiscabrol/ranger.vim", cmd = "Ranger" },
  { "rbgrouleff/bclose.vim", lazy = false },
  { "dyng/ctrlsf.vim", event = "User AstroFile" },
  { "pelodelfuego/vim-swoop", cmd = "Swoop" },
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
  { "catppuccin/nvim", name = "catppuccin" },
  { "lervag/vimtex" },
  {
    "Exafunction/codeium.vim",
    event = "User AstroFile",
    config = function()
      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set("i", "<C-l>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    cmd = "MarkdownPreview",
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
  -- {
  --   "ldelossa/nvim-ide",
  --   lazy = false,
  --   config = function()
  --     local bufferlist = require "ide.components.bufferlist"
  --     local explorer = require "ide.components.explorer"
  --     local outline = require "ide.components.outline"
  --     local callhierarchy = require "ide.components.callhierarchy"
  --     local timeline = require "ide.components.timeline"
  --     local terminal = require "ide.components.terminal"
  --     local terminalbrowser = require "ide.components.terminal.terminalbrowser"
  --     local changes = require "ide.components.changes"
  --     local commits = require "ide.components.commits"
  --     local branches = require "ide.components.branches"
  --     local bookmarks = require "ide.components.bookmarks"
  --
  --     require("ide").setup {
  --       log_level = "debug",
  --       components = {
  --         Explorer = {
  --           show_file_permissions = false,
  --           default_height = 30,
  --         },
  --       },
  --       panel_groups = {
  --         explorer = { explorer.Name, outline.Name, bookmarks.Name, callhierarchy.Name },
  --         terminal = { terminal.Name },
  --         git = { changes.Name, commits.Name, timeline.Name, branches.Name },
  --       },
  --       workspaces = {
  --         auto_open = "none",
  --       },
  --     }
  --   end,
  --   keys = {
  --     -- set keys based on the components you configured in setup
  --     { "<leader>Wl", "<cmd>Workspace LeftPanelToggle<cr>", desc = "Toggle Left Panel" },
  --     { "<leader>Wr", "<cmd>Workspace RightPanelToggle<cr>", desc = "Right Left Panel" },
  --     { "<leader>We", "<cmd>Workspace Explorer Focus<cr>", desc = "Focus Explorer" },
  --     { "<leader>e", "<cmd>Workspace Explorer Focus<cr>", desc = "Focus Explorer" },
  --     { "<leader>Wo", "<cmd>Workspace Outline Focus<cr>", desc = "Focus Outline" },
  --     { "<leader>Wbb", "<cmd>Workspace Bookmarks Focus<cr>", desc = "Focus Bookmarks" },
  --     { "<leader>Wbo", "<cmd>Workspace Bookmarks OpenNotebook<cr>", desc = "Open Notebook" },
  --     { "<leader>Wbc", "<cmd>Workspace Bookmarks CreateBookmark<cr>", desc = "Create Bookmark" },
  --     { "<leader>Wgs", "<cmd>Workspace Changes Focus<cr>", desc = "Focus Changed Files" },
  --     { "<leader>Wgc", "<cmd>Workspace Commits Focus<cr>", desc = "Focus Commits" },
  --     { "<leader>Wgt", "<cmd>Workspace Timeline Focus<cr>", desc = "Focus Timeline" },
  --     { "<leader>Wgb", "<cmd>Workspace Branches Focus<cr>", desc = "Focus Branches" },
  --   },
  -- },
}
