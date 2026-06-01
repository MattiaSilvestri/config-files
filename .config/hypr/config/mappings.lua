local mainMod = "SUPER" -- Sets "Windows" key as main modifier
-------------------
---- HYMISION ----
------------------

hl.plugin.hymission.gesture({
	fingers = 4,
	direction = "vertical",
	action = "toggle",
	args = "forceall",
})

hl.plugin.hymission.gesture({
	fingers = 4,
	direction = "vertical",
	action = "toggle",
	recommand = true,
})

hl.plugin.hymission.gesture({
	fingers = 4,
	direction = "vertical",
	action = "open",
	scope = "onlycurrentworkspace",
})

hl.plugin.hymission.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "scroll",
	mode = "layout",
})

-- Native alternative:
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "scroll_move" })

hl.plugin.hymission.gesture({
	fingers = 3,
	direction = "vertical",
	action = "workspace",
})

hl.bind("SUPER + S", hl.plugin.hymission.toggle)
hl.bind("SUPER + A", function()
	hl.plugin.hymission.toggle("forceall")
end)
hl.bind("SUPER + TAB", function()
	hl.plugin.hymission.toggle("onlycurrentworkspace")
end)
hl.bind("SUPER + Escape", hl.plugin.hymission.close)

-- SCROLLING
hl.bind(mainMod .. " + R", hl.dsp.layout("colresize +conf"))
