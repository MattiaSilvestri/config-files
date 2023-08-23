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
  { "francoiscabrol/ranger.vim",      cmd = "Ranger" },
  { "rbgrouleff/bclose.vim",          lazy = false },
  { "dyng/ctrlsf.vim",                event = "User AstroFile" },
  { "pelodelfuego/vim-swoop",         cmd = "Swoop" },
  { "mg979/vim-visual-multi",         event = "User AstroFile" },
  -- { "tpope/vim-surround" },
  { "ixru/nvim-markdown",             event = "User AstroFile" },
  { "christoomey/vim-tmux-navigator", lazy = false },
  { "kevinhwang91/rnvimr",            cmd = "RnvimrToggle" },
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
  { "catppuccin/nvim",    name = "catppuccin" },
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
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    requires = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },
  {
    "folke/neodev.nvim",
    event = "VeryLazy",
    opts = { library = { plugins = { "nvim-dap-ui" }, types = true } },
  },
}
