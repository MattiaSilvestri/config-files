--- @type LazySPec
return {
	{ "williamboman/mason.nvim", config = true },
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "lua_ls", "pyright" },
			automatic_installation = true,
		},
	},
}
