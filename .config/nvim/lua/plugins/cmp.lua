--- @type LazySpec
return {
  "hrsh7th/nvim-cmp",
  enabled = false,
  dependencies = {
    "tailwind-tools",
    "onsails/lspkind-nvim",
  },
  opts = function()
    -- return {
    --   formatting = {
    --     format = require("lspkind").cmp_format {
    --       before = require("tailwind-tools.cmp").lspkind_format,
    --     },
    --   },
    -- }
  end,
}
