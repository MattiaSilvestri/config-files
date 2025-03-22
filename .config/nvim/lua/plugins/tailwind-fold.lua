--- @type LazySpec
return {
  "razak17/tailwind-fold.nvim",
  opts = {},
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "User AstroFile",
  config = function() require("tailwind-fold").setup { ft = { "html", "twig" } } end,
}
