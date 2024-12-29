--- @type LazySpec
return {
  "stevearc/conform.nvim",
  event = "User AstroFile",
  opts = {
    formatters_by_ft = {
      python = { "black" },
      vue = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  },
}
