-- Define colors --
local theme = require("catppuccin.palettes").get_palette("mocha")
local bg = theme.base
local bg_alt = theme.mantle
local fg = theme.text
local green = theme.green
local red = theme.red
local highlight = theme.surface0
local line = theme.surface1
local cursorline = "#252434"
local visual = "#252434"

return {
	-- Neovim builtin --
	CursorLine = { bg = cursorline },
	Visual = { bg = highlight },

	-- MatchParen --
	MatchParen = { bg = highlight },
	MatchParenCur = { bg = highlight, underline = false },

	-- Blink.cmp --
	BlinkCmpMenu = { bg = bg },
	BlinkCmpMenuBorder = { fg = line, bg = bg },
	BlinkCmpMenuSelection = { fg = bg, bg = theme.teal },
	BlinkCmpScrollBarThumb = { bg = line },
	BlinkCmpScrollBarGutter = { bg = bg },
	BlinkCmpSource = { bg = bg },
	BlinkCmpLabelDetail = { bg = bg },
	BlinkCmpLabelDescription = { bg = bg },
	BlinkCmpSignatureHelpActiveParameter = { bg = line },

	-- Telescope --
	TelescopeBorder = { fg = bg_alt, bg = bg },
	TelescopeNormal = { bg = bg },
	TelescopePreviewBorder = { fg = bg, bg = bg },
	TelescopePreviewNormal = { bg = bg },
	TelescopePreviewTitle = { fg = bg, bg = green },
	TelescopePromptBorder = { fg = bg_alt, bg = bg_alt },
	TelescopePromptNormal = { fg = fg, bg = bg_alt },
	TelescopePromptPrefix = { fg = red, bg = bg_alt },
	TelescopePromptTitle = { fg = bg, bg = red },
	TelescopeResultsBorder = { fg = bg, bg = bg },
	TelescopeResultsNormal = { bg = bg },
	TelescopeResultsTitle = { fg = bg, bg = bg },

	-- Neotree --
	NeoTreeNormal = { bg = bg_alt },
	NeoTreeNormalNC = { bg = bg_alt },

	-- Noice --
	NoiceCmdlinePopup = { bg = bg },
	NoiceCmdlinePopupTitle = { bg = bg },
	NoiceCmdlinePopupBorder = { fg = line, bg = bg },
	NoiceCmdlinePrompt = { bg = bg },
	NoicePopup = { bg = bg },
	NoicePopupBorder = { fg = line, bg = bg },
}
