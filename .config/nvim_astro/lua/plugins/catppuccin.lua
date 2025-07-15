--- @type LazySpec

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    term_colors = true,
    color_overrides = {
      mocha = {
        -- base = "#181825",
        -- mantle = "#11111b",
      },
    },
  },
}
