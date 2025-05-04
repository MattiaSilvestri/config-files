--- @type LazySpec

return {
  "petertriho/nvim-scrollbar",
  event = "User AstroFile",
  config = function() require("scrollbar").setup() end,
}
