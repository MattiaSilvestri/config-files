local theme = require("catppuccin.palettes").get_palette("mocha")

return {
	-- MatchParen --
	MatchParen = { bg = theme.base },
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
}
