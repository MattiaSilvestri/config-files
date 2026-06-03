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

-- SCROLLING --
-- local function layout_bind(bind_table)
-- 	return function()
-- 		local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
--
-- 		if not workspace then
-- 			return
-- 		end
--
-- 		local layout = workspace.tiled_layout
--
-- 		if bind_table[layout] then
-- 			hl.dispatch(bind_table[layout])
-- 		end
-- 	end
-- end
--
-- hl.bind(
-- 	"SUPER + H",
-- 	layout_bind({
-- 		scrolling = hl.dsp.layout("focus left"),
-- 		dwindle = hl.dsp.focus({ direction = "left" }),
-- 		monocle = hl.dsp.focus({ direction = "left" }),
-- 		master = hl.dsp.focus({ direction = "left" }),
-- 	})
-- )
--
-- hl.bind(
-- 	"SUPER + L",
-- 	layout_bind({
-- 		scrolling = hl.dsp.layout("focus right"),
-- 		dwindle = hl.dsp.focus({ direction = "right" }),
-- 		monocle = hl.dsp.focus({ direction = "right" }),
-- 		master = hl.dsp.focus({ direction = "right" }),
-- 	})
-- )

hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("consume_or_expel next"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + R", hl.dsp.layout("colresize +conf"))
-- hl.bind(mainMod .. " + L", hl.dsp.layout("move +col"))
-- hl.bind(mainMod .. " + H", hl.dsp.layout("move -col"))
