-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
      colorscheme = "catppuccin", -- colorscheme at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = false,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = false, -- sets vim.opt.wrap
        guifont = "Inconsolata Nerd Font:h10:w0:#h-normal",
        linespace = 3,
        -- textwidth = 88, -- sets vim.opt.textwidth
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        mkdp_browser = "qutebrowser",
        mkdp_theme = "dark",
        neovide_padding_top = 6,
        neovide_padding_bottom = 4,
        neovide_padding_right = 6,
        neovide_padding_left = 6,
        neovide_floating_blur_amount_x = 5.0,
        neovide_floating_blur_amount_y = 5.0,
        neovide_floating_corner_radius = 0.3,
        neovide_cursor_animation_length = 0,
        neovide_cursor_vfx_mode = "",
        neovide_text_gamma = 1.3,
        neovide_text_contrast = 0.3,
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs with `H` and `L`
        L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },
        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
        ["U"] = { "<cmd>redo<cr>", desc = "Redo" },
        ["<leader>ss"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Telescope fuzzy find" },
        ["<leader>sg"] = { "<cmd>Telescope live_grep<cr>", desc = "Telescope live grep" },
        ["<leader>st"] = { "<cmd>put =strftime('%c')<cr>kJ", desc = "Insert current date and time" },
        ["<leader>sd"] = { "<cmd>cd %:h<cr>", desc = "Move workdir to current file" },
        ["<leader>a"] = { "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
        ["gt"] = {
          function() require("astrocore.buffer").nav(vim.v.count1) end,
          desc = "Next buffer",
        },
        ["gT"] = {
          function() require("astrocore.buffer").nav(-vim.v.count1) end,
          desc = "Previous buffer",
        },
        ["]o"] = { function() vim.cmd.tabnext() end, desc = "Next tab" },
        ["[o"] = { function() vim.cmd.tabprevious() end, desc = "Previous tab" },
        ["-"] = { "^", desc = "Move to first non-blank character of the line" },
        ["tf"] = { '<Cmd>execute v:count . "ToggleTerm direction=float"<CR>', desc = "Toggle terminal float" },
        ["th"] = { '<Cmd>execute v:count . "ToggleTerm direction=horizontal"<CR>', desc = "Toggle terminal horizontal" },
        ["tv"] = { '<Cmd>execute v:count . "ToggleTerm direction=vertical"<CR>', desc = "Toggle terminal vertical" },
        ["<leader>ts"] = { "<Cmd>TermSelect<CR>", desc = "Select terminal" },
        ["~"] = { "Vyp", desc = "Yank and pase to next line" },
        -- ["<leader>r"] = { "<cmd>Ranger<cr>", desc = "Open Ranger file manager" },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },
      v = {
        ["p"] = { '"0p', desc = "Normal paste" },
        ["P"] = { '"*p', desc = "Normal paste from clipboard" },
        ["<"] = { "<gv", desc = "Persistend indent left" },
        [">"] = { ">gv", desc = "Persistend indent right" },
      },
    },
  },
}
