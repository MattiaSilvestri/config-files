return { -- override nvim-cmp plugin
  "hrsh7th/nvim-cmp",
  -- override the options table that is used in the `require("cmp").setup()` call
  opts = function(_, opts)
    -- opts parameter is the default options table
    -- the function is lazy loaded so cmp is able to be required
    local cmp = require "cmp"
    -- modify the sources part of the options table
    opts.sources = cmp.config.sources {
      { name = "luasnip", priority = 1000 },
      { name = "nvim-html-css", priority = 950 },
      { name = "nvim_lsp", priority = 900 },
      { name = "text", priority = 800 },
      {
        name = "buffer",
        priority = 500,
        option = {
          get_bufnrs = function() return vim.api.nvim_list_bufs() end,
        },
      },
      { name = "path", priority = 250 },
    }
  end,
}
