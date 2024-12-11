--- @type LazySpec

return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    term_colors = true,
    flavour = "mocha",
    priority = 1000,
    transparent_background = false,
    color_overrides = {
      mocha = {
        base = "#181825",
        mantle = "#11111b",
      },
    },
  },
}
