-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(function(bufnr)
          require("astronvim.utils.buffer").close(
            bufnr)
        end)
      end,
      desc = "Pick to close",
    },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
    ["<leader>mc"] = { "<cmd>!g++ -std=c++20 -fmodules-ts -o %< %<cr>", desc = "Compile C++ code" },
    ["<leader>mr"] = { "<cmd>!%<<cr>", desc = "Run C++ code" },
    ["<leader>r"] = { "<cmd>Ranger<cr>", desc = "Open Ranger file manager" },
    ["<leader>ss"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Telescope fuzzy find" },
    ["<C-s>"] = { "<cmd>Swoop<cr>i", desc = "Swoop finder" },
    ["<S-s>"] = { "<cmd>bd! swoopBuf<cr>", desc = "Close swoop buffer" },
    ["U"] = { "<cmd>redo<cr>", desc = "Redo" },
    ["<leader>st"] = { "<cmd>put =strftime('%c')<cr>kJ", desc = "Insert current date and time" },
    ["<leader>sd"] = { "<cmd>cd %:h<cr>", desc = "Move workdir to current file" },
    ["<leader>a"] = { "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
    ["]p"] =
    { function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end, desc = "Next buffer" },
    ["[p"] = {
      function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Previous buffer",
    }
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
  v = {
    ["p"] = { "\"0p", desc = "Normal paste" },
    ["<"] = { "<gv", desc = "Persistend indent left" },
    [">"] = { ">gv", desc = "Persistend indent right" },
  },
}
