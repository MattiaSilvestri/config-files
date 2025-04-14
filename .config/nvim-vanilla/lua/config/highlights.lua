-- Define colors --
local theme = require("catppuccin.palettes").get_palette("mocha")
local bg = theme.base
local bg_alt = theme.mantle
local fg = theme.text
local green = theme.green
local red = theme.red
local highlight = theme.surface1

return {
	-- MatchParen --
	MatchParen = { bg = highlight },
	MatchParenCur = { bg = "#282939", underline = false },

	-- Blink.cmp --
	BlinkCmpMenu = { bg = theme.mantle },
	BlinkCmpMenuBorder = { bg = theme.mantle },
	BlinkCmpMenuSelection = { bg = theme.surface0 },
	BlinkCmpScrollBarThumb = { bg = theme.surface0 },
	BlinkCmpScrollBarGutter = { bg = theme.mantle },
	BlinkCmpSource = { bg = theme.mantle },
	BlinkCmpLabelDetail = { bg = theme.mantle },
	BlinkCmpLabelDescription = { bg = theme.mantle },

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
}
