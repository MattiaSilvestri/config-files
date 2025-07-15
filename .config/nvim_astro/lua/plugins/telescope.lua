local actions = require "telescope.actions"

return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "jonarrien/telescope-cmdline.nvim",
  },
  keys = {
    { "Q", "<cmd>Telescope cmdline<cr>", desc = "Cmdline" },
    { "<leader><leader>", "<cmd>Telescope cmdline<cr>", desc = "Cmdline" },
  },
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
      },
    },
    extensions = {
      cmdline = {},
    },
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension "cmdline"
  end,
}
