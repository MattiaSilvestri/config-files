--- @type LazySpec
return {
	{
		"catgoose/nvim-colorizer.lua",
		enabled = false,
		event = "BufReadPre",
	},
	{ "norcalli/nvim-colorizer.lua", enabled = false, event = "BufEnter", config = true },
	{ "brenoprata10/nvim-highlight-colors", event = "BufEnter", config = true },
}
