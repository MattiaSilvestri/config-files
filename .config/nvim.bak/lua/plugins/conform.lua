--- @type LazySpec
return {
  "stevearc/conform.nvim",
  event = "User AstroFile",
  opts = {
    formatters_by_ft = {
      python = { "black" },
      htmldjango = { "djlint" },
    },
    default_format_opts = {
      lsp_format = "never",
    },
    format_on_save = {
      timeout_ms = 7000,
      lsp_format = "never",
    },
  },
}
