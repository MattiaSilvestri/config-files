-- customize mason plugins
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      if not opts.ensure_installed then opts.ensure_installed = {} end
      require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
        "jedi_language_server",
        "lua_ls",
        "clangd",
        "ltex",
        "marksman",
        "html",
      })
    end,
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      if not opts.ensure_installed then opts.ensure_installed = {} end
      require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
        "prettier",
        "stylua",
        "clangd-format",
        "clandg_check",
        "black",
      })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      if not opts.ensure_installed then opts.ensure_installed = {} end
      require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
        "python",
        "cppdbg",
      })
    end,
  },
}
