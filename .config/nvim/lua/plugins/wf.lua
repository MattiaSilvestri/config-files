--- @type LazySpec
return {
  "Cassin01/wf.nvim",
  enenabled = false,
  lazy = false,
  version = "*",
  config = function() require("wf").setup() end,
}
